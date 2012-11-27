module ScheduleStrategies
  class Weighted
    class << self
      def hosts
        Host.with_available_slots.sort do |a,b|
          capacity(b) <=> capacity(a)
        end
      end

      def capacity(host)
        return host.available_slots if host.weight.blank?

        jobs = host.jobs.scheduled + host.jobs.accepted + host.jobs.processing
        job_load = jobs.inject(0)  { |sum, job| sum + job.preset.weight.to_i }

        host.weight - job_load
      end

      def jobs(limit)
        Job.scheduled.unlocked.order("priority DESC, created_at ASC").limit(limit).sort do |a,b| 
          b.preset.try(:weight) <=> a.preset.try(:weight)
        end
      end
    end
  end
end


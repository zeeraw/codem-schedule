module ScheduleStrategies
  class Simple
    def hosts
      Host.with_available_slots
    end

    def self.jobs(limit)
      Job.scheduled.unlocked.order("priority DESC, created_at ASC").limit(limit)
    end
  end
end


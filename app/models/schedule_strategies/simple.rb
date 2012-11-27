module ScheduleStrategies
  class Simple
    class << self
      def hosts
        Host.with_available_slots
      end

      def jobs(limit)
        Job.scheduled.unlocked.order("priority DESC, created_at ASC").limit(limit)
      end
    end
  end
end


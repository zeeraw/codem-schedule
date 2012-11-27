require 'spec_helper'

describe ScheduleStrategies::Simple do
  def strategy
    ScheduleStrategies::Simple
  end

  it "should return the correct hosts" do
    Host.should_receive(:with_available_slots).and_return 'hosts'
    strategy.hosts.should == 'hosts'
  end


  it "should return the correct jobs" do
    Job.stub_chain(:scheduled, :unlocked, :order, :limit).and_return j
    ScheduleStrategies::Simple.jobs(10).should == j
  end
end


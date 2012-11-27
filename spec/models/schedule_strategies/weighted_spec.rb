require 'spec_helper'

describe ScheduleStrategies::Weighted do
  before(:each) do
    Schedule.stub!(:schedule_strategy).and_return ScheduleStrategies::Weighted

    @host1 = double("Host 1", weight: 50, available_slots: 3)
    @host2 = double("Host 2", weight: 50, available_slots: 3)

    @host1.stub_chain(:jobs, :accepted).and_return []
    @host2.stub_chain(:jobs, :accepted).and_return []

    @host1.stub_chain(:jobs, :processing).and_return []
    @host2.stub_chain(:jobs, :processing).and_return []

    @host1.stub_chain(:jobs, :scheduled).and_return []
    @host2.stub_chain(:jobs, :scheduled).and_return []

    @preset_a = double("Preset A", weight: 10)
    @preset_b = double("Preset B", weight: 9)
    @preset_c = double("Preset C", weight: 8)
    @preset_d = double("Preset D", weight: 6)
    @preset_e = double("Preset E", weight: 5)
    @preset_f = double("Preset F", weight: 4)

    @job1 = double("Job 1", preset: @preset_a)
    @job2 = double("Job 2", preset: @preset_b)
    @job3 = double("Job 3", preset: @preset_c)
    @job4 = double("Job 4", preset: @preset_d)
    @job5 = double("Job 5", preset: @preset_e)
    @job6 = double("Job 6", preset: @preset_f)

    @strategy = ScheduleStrategies::Weighted

    Host.stub!(:with_available_slots).and_return [ @host2, @host1 ]
  end

  def hosts(job)
    @strategy.hosts
  end

  def capacity(host)
    @strategy.capacity(host)
  end

  it "should schedule step 1 correctly" do
    hosts(@job1).should == [ @host2, @host1 ]

    @host2.stub_chain(:jobs, :scheduled).and_return [@job1]

    capacity(@host1).should == 50
    capacity(@host2).should == 40
  end

  it "should schedule step 2 correctly" do
    @host1.stub_chain(:jobs, :scheduled).and_return [@job1]
    @host2.stub_chain(:jobs, :scheduled).and_return []

    hosts(@job2).should == [ @host2, @host1 ]

    @host2.stub_chain(:jobs, :scheduled).and_return [@job2]

    capacity(@host1).should == 40
    capacity(@host2).should == 41
  end

  it "should schedule step 3 correctly" do
    @host1.stub_chain(:jobs, :scheduled).and_return [@job1]
    @host2.stub_chain(:jobs, :scheduled).and_return [@job2]

    hosts(@job3).should == [ @host2, @host1 ]

    @host2.stub_chain(:jobs, :scheduled).and_return [@job2, @job3]

    capacity(@host1).should == 40
    capacity(@host2).should == 33
  end

  it "should schedule step 4 correctly" do
    @host1.stub_chain(:jobs, :scheduled).and_return [@job1]
    @host2.stub_chain(:jobs, :scheduled).and_return [@job2, @job3]

    hosts(@job4).should == [ @host1, @host2 ]

    @host1.stub_chain(:jobs, :scheduled).and_return [@job1, @job4]

    capacity(@host1).should == 34
    capacity(@host2).should == 33
  end

  it "should schedule step 5 correctly" do
    @host1.stub_chain(:jobs, :scheduled).and_return [@job1, @job4]
    @host2.stub_chain(:jobs, :scheduled).and_return [@job2, @job3]

    hosts(@job5).should == [ @host1, @host2 ]

    @host1.stub_chain(:jobs, :scheduled).and_return [@job1, @job4, @job5]

    capacity(@host1).should == 29
    capacity(@host2).should == 33
  end

  it "should schedule step 6 correctly" do
    @host1.stub_chain(:jobs, :scheduled).and_return [@job1, @job4, @job5]
    @host2.stub_chain(:jobs, :scheduled).and_return [@job2, @job3]

    hosts(@job6).should == [ @host2, @host1 ]

    @host2.stub_chain(:jobs, :scheduled).and_return [@job2, @job3, @job6]

    capacity(@host1).should == 29
    capacity(@host2).should == 29
  end
end

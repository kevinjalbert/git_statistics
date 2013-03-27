require 'spec_helper'

include GitStatistics

describe Log do

  let(:log) { Class.new(Log) }

  context "initializes instance" do
    it "should acts as singleton" do
      log.instance.should == log.instance
    end

    it "should have a logger" do
      log.instance.logger.should be_a Logger
    end

    it "should be a Log (FakeLog)" do
      log.class.should eq Log.class
    end

    it "should react to Logger methods" do
      Logger.public_instance_methods.each do |method|
        log.valid_method?(method).should be_true
      end
    end
  end

  context "#use_debug" do
    it "logger's progname before" do
      log.progname.should be_nil
    end

    it "logger's progname after" do
      log.use_debug
      log.progname.should_not be_nil
    end
  end

  context "#parse_caller" do
    context "with nothing" do
      it {log.parse_caller(nil).should be_nil}
    end

    context "with jumble (random text)" do
      it {log.parse_caller("asdaacsdc").should be_nil}
    end

    context "with valid caller" do
      it {log.parse_caller("git_statistics/lib/git_statistics/log.rb:45:in `respond_to_missing?'").should eq "git_statistics/lib/git_statistics/log.rb:45"}
    end
  end

end

require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Collector do
  describe "#collect_branches" do
    context "with many branches" do
      collector = Collector.new(false)
      branches = collector.collect_branches(fixture("git_many_branches.txt"))
      it {branches.size.should == 2 }
      it {branches[0].should == "issue_2" }
      it {branches[1].should == "master" }
    end

    context "with zero branches" do
      collector = Collector.new(false)
      branches = collector.collect_branches(fixture("git_zero_branches.txt"))
      it {branches.size.should == 1 }
      it {branches[0].should == "master" }
    end
  end
end

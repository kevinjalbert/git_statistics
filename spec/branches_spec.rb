require 'spec_helper'
include GitStatistics

describe Branches do
  subject { described_class }

  before do
    subject.stub(:pipe) { fixture(branches) }
  end

  context "with many branches" do
    let(:branches) {"git_many_branches.txt"}
    its(:all) { should have(2).items }
    its(:all) { should include "issue_2" }
    its(:all) { should include "master" }
    its(:current) { should == "issue_2" }
    its(:detached?) { should be_false }
  end

  context "with zero branches" do
    let(:branches) {"git_zero_branches.txt"}
    its(:all) { should have(1).items }
    its(:all) { should include "master" }
    its(:current) { should == "master" }
    its(:detached?) { should be_false }
  end

  context "with many branches in detached state" do
    let(:branches) {"git_many_branches_detached_state.txt"}
    its(:all) { should have(2).items }
    its(:all) { should include "issue_2" }
    its(:all) { should include "master" }
    its(:current) { should == "(none)" }
    its(:detached?) { should be_true }
  end

  context "with zero branches in detached state" do
    let(:branches) {"git_zero_branches_detached_state.txt"}
    its(:all) { should have(1).items }
    its(:all) { should include "master" }
    its(:current) { should == "(none)" }
    its(:detached?) { should be_true }
  end
end

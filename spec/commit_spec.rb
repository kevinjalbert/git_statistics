require 'spec_helper'
include GitStatistics

describe Commit do

  let(:sha) { "bf09a64b0e0f801d3e7fe4e002cbd1bf517340a7" }
  let(:repo) { Utilities.get_repository }
  subject(:commit) { Commit.new(repo.commit(sha)) }

  its(:__getobj__) { should be_a Grit::Commit }

  context "without a merge" do
    it { should_not be_a_merge }
  end

  context "with a removed file" do
    let(:sha) { "4ce86b844458a1fd77c6066c9297576b9520f97e" }
    its(:removed_files) { should == 2 }
  end

  context "without a removed file" do
    let(:sha) { "b808b3a9d4ce2d8a1d850f2c24d2d1fb00e67727" }
    its(:removed_files) { should == 0 }
  end

  context "with a new file" do
    let(:sha) { "8b1941437a0ff8cf6a35a46d4f5df8b6587c346f" }
    its(:new_files) { should == 19 }
  end

  context "without a new file" do
    let(:sha) { "52f9f38cbe4ba90edd607298cb2f9b1aec26bcf1" }
    its(:new_files) { should == 0 }
  end

  context "with a merge" do
    let(:sha) { "9d31467f6759c92f8535038c470d24a37ae93a9d" }
    it { should be_a_merge }
  end

  context "net, additions, and deletions" do
    its(:additions) { should == 10 }
    its(:deletions) { should == 27 }
    its(:net) { should == -17 }
  end

end

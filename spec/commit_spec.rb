require 'spec_helper'
include GitStatistics

describe Commit do

  let(:sha) { "bf09a64b0e0f801d3e7fe4e002cbd1bf517340a7" }
  let(:repo) { Utilities.get_repository }
  subject(:commit) { Commit.new(repo.commit(sha)) }

  its(:__getobj__) { should be_a Grit::Commit }

  context "without a merge" do
    its(:merge?) { should be_false }
  end

  context "with a merge" do
    let(:sha) { "9d31467f6759c92f8535038c470d24a37ae93a9d" }
    its(:merge?) { should be_true }
  end

  context "net, additions, and deletions" do
    its(:additions) { should == 10 }
    its(:deletions) { should == 27 }
    its(:net) { should == -17 }
  end

end

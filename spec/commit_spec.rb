require 'spec_helper'
include GitStatistics

describe Commit do

  let(:sha) { "bf09a64b0e0f801d3e7fe4e002cbd1bf517340a7" }
  let(:repo) { Utilities.get_repository }
  subject(:commit) { Commit.new(repo.commit(sha)) }

  its(:__getobj__) { should be_a Grit::Commit }

  context "understands its files and languages" do
    its(:files) { should have(3).items }
    its(:languages) { should have(1).items }
  end

  context "language-specific changes" do
    let(:name) { "Ruby" }
    subject(:language) { commit.languages.detect { |lang| lang.name == name } }
    context "for commit 9c94e69411263bcb0f7c1114ea6bd43f1b2a3be5" do
      let(:sha) { "2aa45e4ff23c1a558b127c06e95d313a56cc6890" }
      context "language count" do
        subject { commit }
        its(:languages) { should have(2).items }
      end
      context "Ruby" do
        let(:name) { "Ruby" }
        its(:additions) { should == 14 }
        its(:deletions) { should == 13 }
        its(:net) { should == 1 }
      end
      context "Unknown (or txt)" do
        let(:name) { "Unknown" }
        its(:additions) { should == 7 }
        its(:deletions) { should == 11 }
        its(:net) { should == -4 }
      end
    end
    context "for commit bf09a64b" do
      subject { commit.languages.first }
      its(:name) { should == "Ruby" }
      its(:additions) { should == 10 }
      its(:deletions) { should == 27 }
      its(:net) { should == -17 }
    end
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
    context "statistics" do
      its(:languages) { should have(1).items }
      its(:files) { should have(11).items }
      its(:additions) { should == 69 }
      its(:deletions) { should == 68 }
      its(:net) { should == 1}
    end
  end

  context "without a merge" do
    it { should_not be_a_merge }
  end

  context "net, additions, and deletions" do
    its(:additions) { should == 10 }
    its(:deletions) { should == 27 }
    its(:net) { should == -17 }
  end

end

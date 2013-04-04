require 'spec_helper'
include GitStatistics

describe Repo do
  subject(:repository) { Repo.new(dir) }
  let(:current) { Pathname.new(Dir.pwd) }

  context "within the current directory" do
    let(:dir) { current }
    its(:repo) { should be_a Grit::Repo }
    its(:path) { should == current }
  end

  context "with sub directory of the repo" do
    let(:dir) { current + "spec" } # git_statistics/spec/
    its(:repo) { should be_a Grit::Repo }
    its(:path) { should == current }
  end

  describe "failure if not in repository" do
    context "should log a message and exit" do
      before do
        Log.should_receive(:error).once
        repository.stub(:path) { stub }
        repository.should_receive(:exit).with(1)
      end
      let(:dir) { Dir.home } # /Users/username/
      its(:repo) { should be_nil }
    end
  end
end

require 'spec_helper'
include GitStatistics

describe Repository do
  describe "#find" do
    subject { Repository.find(dir) }

    before do
      Thread.current[:repository] = nil
    end

    context "with root directory" do
      let(:dir) { Dir.pwd } # git_statistics/
      it { should be_a Grit::Repo }
    end

    context "with sub directory" do
      let(:dir) { File.dirname(__FILE__) } # git_statistics/spec/
      it { should be_a Grit::Repo }
    end

    context "when not in a repository directory" do
      before { Repository.should_receive(:exit) }
      let(:dir) { Dir.home } # /Users/username/
      it { should be_nil }
    end
  end
end

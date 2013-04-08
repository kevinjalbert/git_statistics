require 'spec_helper'
include GitStatistics

describe Repo do
  describe "#find" do
    subject { Repo.find(dir) }

    let(:current) { Pathname.new(Dir.pwd) }

    before do
      Thread.current[:repository] = nil
    end

    context "with root directory" do
      let(:dir) { current }
      it { should be_a Grit::Repo }
    end

    context "with sub directory" do
      let(:dir) { current + "spec" } # git_statistics/spec/
      it { should be_a Grit::Repo }
    end

    context "when not in a repository directory" do
      before { Repo.should_receive(:exit) }
      let(:dir) { Dir.home } # /Users/username/
      it { should be_nil }
    end
  end
end
require 'spec_helper'
include GitStatistics

describe Repo do
  subject(:repository) { Repo.new(dir) }
  let(:current) { Pathname.new(Dir.pwd) }

  context "within the current directory" do
    let(:dir) { current }
    it { should be_a Grit::Repo }
    its(:working_dir) { should == current }
  end

  context "with sub directory of the repo" do
    let(:dir) { current + "spec" } # git_statistics/spec/
    it { should be_a Grit::Repo }
    its(:working_dir) { should == current }
  end

  describe "fails if not in repository" do
    let(:dir) { "/some/non/repo/directory" }
    before { Repo.any_instance.should_receive(:exit).with(1) }
    it { expect { repository }.not_to raise_error(Grit::NoSuchPathError) }
  end
end

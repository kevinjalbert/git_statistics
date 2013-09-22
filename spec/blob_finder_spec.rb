require 'spec_helper'
include GitStatistics

describe Collector do
  let(:repo) { GIT_REPO }

  describe "#get_blob" do
    let(:sha) { "695b487432e8a1ede765b4e3efda088ab87a77f8" }  # Commit within repository
    subject { BlobFinder.get_blob(repo.commit(sha), file[:file]) }

    context "with valid blob" do
      let(:file) {{:file => "Gemfile.lock"}}
      it { should be_a Grit::Blob }
      its(:name) { should == File.basename(file[:file]) }
    end

    context "with deleted file" do
      let(:file) {{:file => "spec/collector_spec.rb"}}
      it { should be_a Grit::Blob }
      its(:name) { should == File.basename(file[:file]) }
    end

    context "with invalid blob" do
      let(:file) {{:file => "dir/nothing.rb"}}
      it { should be_nil }
    end
  end

  describe "#find_blob_in_tree" do
    let(:sha) {"7d6c29f0ad5860d3238debbaaf696e361bf8c541"}  # Commit within repository
    let(:tree) {repo.tree(sha)}
    let(:file) {nil}
    let(:blob) {BlobFinder.find_blob_in_tree(tree, file.split(File::Separator))}
    subject { blob }

    context "blob on root tree" do
      let(:file) {"Gemfile"}
      it { should be_instance_of Grit::Blob }
      its(:name) { should == file }
    end

    context "blob down tree" do
      let(:file) {"lib/git_statistics/collector.rb"}
      it { should be_instance_of Grit::Blob }
      its(:name) { should == File.basename(file) }
    end

    context "file is nil" do
      subject {BlobFinder.find_blob_in_tree(tree, nil)}
      it { should be_nil }
    end

    context "file is empty" do
      let(:file) {""}
      it { should be_nil }
    end

    context "file is submodule" do
      let(:sha) {"1940ef1c613a04f855d3867b874a4267d3e2c011"}
      let(:file) {"Spoon-Knife"}
      it { should be_instance_of Grit::Submodule }
      its(:name) { should == file }
    end
  end

end

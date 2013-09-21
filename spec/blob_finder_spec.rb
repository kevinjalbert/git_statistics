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

end

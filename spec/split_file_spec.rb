require 'spec_helper'

module GitStatistics
  describe SplitFile do
    describe "#split" do
      subject(:split) { SplitFile.new(old, new).split }
      context "with a change in middle" do
        let(:old) { "lib/{old_dir" }
        let(:new) { "new_dir}/file.rb" }
        its(:new) { should == "lib/new_dir/file.rb" }
      end

      context "with a change at beginning" do
        let(:old) { "{src/dir/lib" }
        let(:new) { "lib/dir}/file.rb" }
        its(:old) { should == "src/dir/lib/file.rb" }
        its(:new) { should == "lib/dir/file.rb" }
      end

      context "with a change at beginning, alternative" do
        let(:old) { "src/{" }
        let(:new) { "dir}/file.rb" }
        its(:old) { should == "src/file.rb"}
        its(:new) { should == "src/dir/file.rb"}
      end

      context "with a change at ending" do
        let(:old) { "lib/dir/{old_file.rb" }
        let(:new) { "new_file.rb}" }
        its(:old) { should == "lib/dir/old_file.rb"}
        its(:new) { should == "lib/dir/new_file.rb"}
      end

      context "with a simple complete change" do
        let(:old) { "file.rb" }
        let(:new) { "lib/dir/file.rb}" }
        its(:old) { should == "file.rb"}
        its(:new) { should == "lib/dir/file.rb"}
      end
    end
  end
end


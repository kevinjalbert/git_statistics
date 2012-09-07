require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Collector do
  describe "#collect_branches" do
    collector = Collector.new(false)

    context "with many branches" do
      branches = collector.collect_branches(fixture("git_many_branches.txt"))
      it {branches.size.should == 2}
      it {branches[0].should == "issue_2"}
      it {branches[1].should == "master"}
    end

    context "with zero branches" do
      branches = collector.collect_branches(fixture("git_zero_branches.txt"))
      it {branches.size.should == 1}
      it {branches[0].should == "master"}
    end
  end

  describe "#clean_string" do
    collector = Collector.new(false)

    context "with trailling spaces" do
      unclean = "  master   "
      clean = collector.clean_string(unclean)
      it {clean.should == "master"}
    end
  end

  describe "#split_old_new_file" do
    collector = Collector.new(false)

    context "with a change in middle" do
      old = "lib/{old_dir"
      new = "new_dir}/file.rb"
      files = collector.split_old_new_file(old, new)
      it {files[:old_file].should == "lib/old_dir/file.rb"}
      it {files[:new_file].should == "lib/new_dir/file.rb"}
    end

    context "with a change at beginning" do
      old = "{src/dir/lib"
      new = "lib/dir}/file.rb"
      files = collector.split_old_new_file(old, new)
      it {files[:old_file].should == "src/dir/lib/file.rb"}
      it {files[:new_file].should == "lib/dir/file.rb"}
    end

    context "with a change at ending" do
      old = "lib/dir/{old_file.rb"
      new = "new_file.rb}"
      files = collector.split_old_new_file(old, new)
      it {files[:old_file].should == "lib/dir/old_file.rb"}
      it {files[:new_file].should == "lib/dir/new_file.rb"}
    end

    context "with a simple complete change" do
      old = "file.rb"
      new = "lib/dir/file.rb}"
      files = collector.split_old_new_file(old, new)
      it {files[:old_file].should == "file.rb"}
      it {files[:new_file].should == "lib/dir/file.rb"}
    end
  end
end

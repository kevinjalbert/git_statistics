require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Utilities do

  describe "#get_repository" do
    context "with root directory" do
      repo = Utilities.get_repository(Dir.pwd) # git_statistics/
      it {repo.instance_of?(Grit::Repo).should be_true}
    end

    context "with sub directory" do
      repo = Utilities.get_repository(File.dirname(__FILE__))  # git_statistics/spec/
      it {repo.instance_of?(Grit::Repo).should be_true}
    end

    context "not in a repository directory" do
      repo = Utilities.get_repository(Dir.pwd + "../")  # git_statistics/../
      it {repo.should == nil}
    end
  end

  describe "#clean_string" do
    context "with trailling spaces" do
      unclean = "  master   "
      clean = Utilities.clean_string(unclean)
      it {clean.should == "master"}
    end
  end

  describe "#split_old_new_file" do
    context "with a change in middle" do
      old = "lib/{old_dir"
      new = "new_dir}/file.rb"
      files = Utilities.split_old_new_file(old, new)
      it {files[:old_file].should == "lib/old_dir/file.rb"}
      it {files[:new_file].should == "lib/new_dir/file.rb"}
    end

    context "with a change at beginning" do
      old = "{src/dir/lib"
      new = "lib/dir}/file.rb"
      files = Utilities.split_old_new_file(old, new)
      it {files[:old_file].should == "src/dir/lib/file.rb"}
      it {files[:new_file].should == "lib/dir/file.rb"}
    end

    context "with a change at ending" do
      old = "lib/dir/{old_file.rb"
      new = "new_file.rb}"
      files = Utilities.split_old_new_file(old, new)
      it {files[:old_file].should == "lib/dir/old_file.rb"}
      it {files[:new_file].should == "lib/dir/new_file.rb"}
    end

    context "with a simple complete change" do
      old = "file.rb"
      new = "lib/dir/file.rb}"
      files = Utilities.split_old_new_file(old, new)
      it {files[:old_file].should == "file.rb"}
      it {files[:new_file].should == "lib/dir/file.rb"}
    end
  end

end

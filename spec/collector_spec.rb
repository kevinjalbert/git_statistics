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

  describe "#extract_change_file" do
    collector = Collector.new(false)

    context "with a simple changed file" do
      line =  "37	30	lib/file.rb"
      file = collector.extract_change_file(line)
      it {file[:additions].should == 37}
      it {file[:deletions].should == 30}
      it {file[:file].should == "lib/file.rb"}
    end

    context "with a simple rename/copy changed file" do
      line = "11	3	old_file.rb => lib/file.rb"
      file = collector.extract_change_file(line)
      it {file[:additions].should == 11}
      it {file[:deletions].should == 3}
      it {file[:file].should == "lib/file.rb"}
      it {file[:old_file].should == "old_file.rb"}
    end

    context "with a complex rename/copy changed file" do
      line = "-	-	lib/{old_dir => new_dir}/file.rb"
      file = collector.extract_change_file(line)
      it {file[:additions].should == 0}
      it {file[:deletions].should == 0}
      it {file[:file].should == "lib/new_dir/file.rb"}
      it {file[:old_file].should == "lib/old_dir/file.rb"}
    end
  end

  describe "#extract_create_delete_file" do
    collector = Collector.new(false)

    context "with a create changed file" do
      line = "create mode 100644 lib/dir/file.rb"
      file = collector.extract_create_delete_file(line)
      it {file[:status].should == "create"}
      it {file[:file].should == "lib/dir/file.rb"}
    end

    context "with a delete changed file" do
      line = "delete mode 100644 lib/file.rb"
      file = collector.extract_create_delete_file(line)
      it {file[:status].should == "delete"}
      it {file[:file].should == "lib/file.rb"}
    end
  end

  describe "#extract_rename_copy_file" do
    collector = Collector.new(false)

    context "with a rename changed file" do
      line = "rename lib/{old_dir => new_dir}/file.rb (100%)"
      file = collector.extract_rename_copy_file(line)
      it {file[:status].should == "rename"}
      it {file[:old_file].should == "lib/old_dir/file.rb"}
      it {file[:new_file].should == "lib/new_dir/file.rb"}
      it {file[:similar].should == 100}
    end

    context "with a copy changed file" do
      line = "copy lib/dir/{old_file.rb => new_file.rb} (75%)"
      file = collector.extract_rename_copy_file(line)
      it {file[:status].should == "copy"}
      it {file[:old_file].should == "lib/dir/old_file.rb"}
      it {file[:new_file].should == "lib/dir/new_file.rb"}
      it {file[:similar].should == 75}
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

require 'spec_helper'
include GitStatistics

describe CommitLineExtractor do

  let(:extractor) { CommitLineExtractor.new(line) }

  describe "#extract_change_file" do
    let(:file) { extractor.changed }

    context "with a simple changed file" do
      let(:line) {"37 30  lib/file.rb"}
      it {file[:additions].should == 37}
      it {file[:deletions].should == 30}
      it {file[:file].should == "lib/file.rb"}
    end

    context "with a simple rename/copy changed file" do
      let(:line) {"11 3 old_file.rb => lib/file.rb"}
      it {file[:additions].should == 11}
      it {file[:deletions].should == 3}
      it {file[:file].should == "lib/file.rb"}
      it {file[:old_file].should == "old_file.rb"}
    end

    context "with a complex rename/copy changed file" do
      let(:line) {"-  - lib/{old_dir => new_dir}/file.rb"}
      it {file[:additions].should == 0}
      it {file[:deletions].should == 0}
      it {file[:file].should == "lib/new_dir/file.rb"}
      it {file[:old_file].should == "lib/old_dir/file.rb"}
    end
  end

  describe "#extract_create_delete_file" do
    let(:file) { extractor.created_or_deleted }

    context "with a create changed file" do
      let(:line) {"create mode 100644 lib/dir/file.rb"}
      it {file[:status].should == "create"}
      it {file[:file].should == "lib/dir/file.rb"}
    end

    context "with a delete changed file" do
      let(:line) {"delete mode 100644 lib/file.rb"}
      it {file[:status].should == "delete"}
      it {file[:file].should == "lib/file.rb"}
    end
  end

  describe "#extract_rename_copy_file" do
    let(:file) { extractor.renamed_or_copied }

    context "with a rename changed file" do
      let(:line) {"rename lib/{old_dir => new_dir}/file.rb (100%)"}
      it {file[:status].should == "rename"}
      it {file[:old_file].should == "lib/old_dir/file.rb"}
      it {file[:new_file].should == "lib/new_dir/file.rb"}
      it {file[:similar].should == 100}
    end

    context "with a copy changed file" do
      let(:line) {"copy lib/dir/{old_file.rb => new_file.rb} (75%)"}
      it {file[:status].should == "copy"}
      it {file[:old_file].should == "lib/dir/old_file.rb"}
      it {file[:new_file].should == "lib/dir/new_file.rb"}
      it {file[:similar].should == 75}
    end
  end
end

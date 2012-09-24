require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Utilities do

  describe "#get_repository" do
    let(:repo) {Utilities.get_repository(dir)}

    context "with root directory" do
      let(:dir) {Dir.pwd} # git_statistics/
      it {repo.instance_of?(Grit::Repo).should be_true}
    end

    context "with sub directory" do
      let(:dir) {File.dirname(__FILE__)} # git_statistics/spec/
      it {repo.instance_of?(Grit::Repo).should be_true}
    end

    context "when not in a repository directory" do
      let(:dir) {Dir.pwd + "../"} # git_statistics/../
      it {repo.should == nil}
    end
  end

  describe "#find_longest_length" do
    let(:max) {nil}
    let(:results) {Utilities.find_longest_length(list, max)}

    context "with empty list" do
      let(:list) {[]}
      it {results.should == nil}
    end

    context "with nil list" do
      let(:list) {nil}
      it {results.should == nil}
    end

    context "with preset minimum length" do
      let(:list) {[]}
      let(:max) {10}
      it {results.should == 10}
    end

    context "with valid list" do
      let(:list) {["abc", "a", "ab"]}
      it {results.should == 3}
    end

    context "with valid hash" do
      let(:list) {{"a" => "word_a", "ab" => "word_b", "abc" => "word_c"}}
      it {results.should == 3}
    end
  end

  describe "#unique_data_in_hash" do
    let(:type) {:word}
    let(:list) {Utilities.unique_data_in_hash(data, type)}

    context "with valid type" do
      let(:data) {
        {:entry_a => {type => "test"},
         :entry_b => {type => "a"},
         :entry_c => {type => "a"},
         :entry_d => {type => "is"},
         :entry_e => {type => "test"}}
      }

      it {list.size.should == 3}
      it {list.include?("is").should be_true}
      it {list.include?("a").should be_true}
      it {list.include?("test").should be_true}
    end

    context "with invalid type" do
      let(:data) {
        {:entry_a => {:wrong => "test"},
         :entry_b => {:wrong => "is"}}
      }

      it {list.should == [nil]}
    end
  end

  describe "#clean_string" do
    let(:unclean) {"  master   "}
    let(:clean) {Utilities.clean_string(unclean)}

    context "with trailling spaces" do
      it {clean.should == "master"}
    end
  end

  describe "#split_old_new_file" do
    let(:files) {Utilities.split_old_new_file(old, new)}
    context "with a change in middle" do
      let(:old) {"lib/{old_dir"}
      let(:new) {"new_dir}/file.rb"}
      it {files[:new_file].should == "lib/new_dir/file.rb"}
    end

    context "with a change at beginning" do
      let(:old) {"{src/dir/lib"}
      let(:new) {"lib/dir}/file.rb"}
      it {files[:old_file].should == "src/dir/lib/file.rb"}
      it {files[:new_file].should == "lib/dir/file.rb"}
    end

    context "with a change at beginning, alternative" do
      let(:old) {"src/{"}
      let(:new) {"dir}/file.rb"}
      it {files[:old_file].should == "src/file.rb"}
      it {files[:new_file].should == "src/dir/file.rb"}
    end

    context "with a change at ending" do
      let(:old) {"lib/dir/{old_file.rb"}
      let(:new) {"new_file.rb}"}
      it {files[:old_file].should == "lib/dir/old_file.rb"}
      it {files[:new_file].should == "lib/dir/new_file.rb"}
    end

    context "with a simple complete change" do
      let(:old) {"file.rb"}
      let(:new) {"lib/dir/file.rb}"}
      it {files[:old_file].should == "file.rb"}
      it {files[:new_file].should == "lib/dir/file.rb"}
    end
  end

  describe "find_blob_in_tree" do
    let(:sha) {"7d6c29f0ad5860d3238debbaaf696e361bf8c541"}  # Commit within repository
    let(:tree) {Utilities.get_repository(Dir.pwd).tree(sha)}
    let(:file) {nil}
    let(:blob) {Utilities.find_blob_in_tree(tree, file.split(File::Separator))}

    context "blob on root tree" do
      let(:file) {"Gemfile"}
      it {blob.instance_of?(Grit::Blob).should be_true}
      it {blob.name.should == file}
    end

    context "blob down tree" do
      let(:file) {"lib/git_statistics/collector.rb"}
      it {blob.instance_of?(Grit::Blob).should be_true}
      it {blob.name.should == file.split(File::Separator).last}
    end

    context "file is nil" do
      let(:blob) {Utilities.find_blob_in_tree(tree, nil)}
      it {blob.should == nil}
    end

    context "file is empty" do
      let(:file) {""}
      it {blob.should == nil}
    end

    context "file is submodule" do
      let(:sha) {"1940ef1c613a04f855d3867b874a4267d3e2c011"}
      let(:file) {"Spoon-Knife"}
      it {blob.instance_of?(Grit::Submodule).should be_true}
      it {blob.name.should == file}
    end
  end

end

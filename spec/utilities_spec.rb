require 'spec_helper'
include GitStatistics

describe Utilities do

  describe "#max_length_in_list" do
    let(:max) { nil }
    let(:list) { [] }
    subject(:results) {Utilities.max_length_in_list(list, max)}

    context "with empty list" do
      it { should == 0 }
    end

    context "with nil list" do
      let(:list) { nil }
      it { should == 0 }
    end

    context "with empty list and zero max" do
      let(:list) { [] }
      let(:max) { 0 }
      it { should == 0 }
    end

    context "with preset minimum length" do
      let(:max) { 10 }
      it { should == 10 }
    end

    context "with valid list" do
      let(:list) { ["abc", "a", "ab"] }
      it { should == 3 }
    end

    context "with valid hash" do
      let(:list) { {"a" => "word_a", "ab" => "word_b", "abc" => "word_c"} }
      it { should == 3 }
    end
  end

  describe "#get_modified_time" do
    let(:file) { 'file' }
    after { Utilities.get_modified_time(file) }
    context "on a Mac" do
      before { Utilities.stub(:os) { :mac } }
      it { Utilities.should_receive(:time_at).with(%[stat -f %m file]) { 10 } }
    end
    context "on a Linux" do
      before { Utilities.stub(:os) { :linux } }
      it { Utilities.should_receive(:time_at).with(%[stat -c %Y file]) { 10 } }
    end
    context "on a Unix" do
      before { Utilities.stub(:os) { :unix } }
      it { Utilities.should_receive(:time_at).with(%[stat -c %Y file]) { 10 } }
    end
  end

  describe "#number_of_matching_files" do
    let(:pattern) { (/\d+\.json/) }
    subject {Utilities.number_of_matching_files(Dir.pwd, pattern)}

    around do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          example.run
        end
      end
    end

    context "with missing directory" do
      it { should == 0 }
    end

    context "with valid files" do
      before do
        FileUtils.touch(["0.json", "1.json", "2.json"])
      end
      it { should == 3 }
    end

    context "with invalid files" do
      before do
        FileUtils.touch(["0.json", "incorrect.json", "1.json"])
      end
      it { should == 2 }
    end

    context "with no files" do
      it { should == 0 }
    end
  end

end

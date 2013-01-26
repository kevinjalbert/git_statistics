require 'spec_helper'
include GitStatistics
include GitStatistics::Formatters

describe Console do
  let(:limit) {100}
  let(:fresh) {true}
  let(:pretty) {false}
  let(:collector) {Collector.new(limit, fresh, pretty)}

  let(:commits) {collector.commits}

  let(:fixture_file) {"multiple_authors.json"}
  let(:save_file) { File.join(collector.commits_path, "0.json") }
  let(:email) {false}
  let(:merge) {false}
  let(:sort) {:commits}
  let(:top_n) {0}

  let(:results) {
    setup_commits(commits, fixture_file, save_file, pretty)
    commits.calculate_statistics(email, merge)
    commits.author_top_n_type(sort)
    results = Console.new(commits)
  }

  let(:config) {
    results.prepare_result_summary(sort, email, top_n)
  }

  describe "#prepare_result_summary" do
    context "with email and sorting" do
      context "on first author" do
        let(:data) {config[:data]}
        author = "Kevin Jalbert"
        subject {data[author]}

        it {data.has_key?(author).should be_true}

        it {subject[:commits].should == 1}
        it {subject[:additions].should == 73}
        it {subject[:deletions].should == 0}
        it {subject[:create].should == 2}

        it {subject[:languages][:Ruby][:additions].should == 62}
        it {subject[:languages][:Ruby][:deletions].should == 0}
        it {subject[:languages][:Ruby][:create].should == 1}
        it {subject[:languages][:Markdown][:additions].should == 11}
        it {subject[:languages][:Markdown][:deletions].should == 0}
        it {subject[:languages][:Markdown][:create].should == 1}
      end

      context "on second author" do
        let(:data) {config[:data]}
        author = "John Smith"
        subject {data[author]}

        it {data.has_key?(author).should be_true}
        it {subject[:commits].should == 1}
        it {subject[:additions].should == 64}
        it {subject[:deletions].should == 16}

        it {subject[:languages][:Ruby][:additions].should == 64}
        it {subject[:languages][:Ruby][:deletions].should == 16}
      end

      it {config[:sort].should == sort}
      it {config[:email].should == email}
      it {config[:top_n].should == top_n}
      it {config[:author_length].should == 17}
      it {config[:language_length].should == 8}
    end

    context "with negative top_n" do
      let(:top_n) {-1}

      context "on first author" do
        let(:data) {config[:data]}
        author = "Kevin Jalbert"
        subject {data[author]}

        it {data.has_key?(author).should be_true}

        it {subject[:commits].should == 1}
        it {subject[:additions].should == 73}
        it {subject[:deletions].should == 0}
        it {subject[:create].should == 2}

        it {subject[:languages][:Ruby][:additions].should == 62}
        it {subject[:languages][:Ruby][:deletions].should == 0}
        it {subject[:languages][:Ruby][:create].should == 1}
        it {subject[:languages][:Markdown][:additions].should == 11}
        it {subject[:languages][:Markdown][:deletions].should == 0}
        it {subject[:languages][:Markdown][:create].should == 1}
      end

      context "on second author" do
        let(:data) {config[:data]}
        author = "John Smith"
        subject {data[author]}

        it {data.has_key?(author).should be_true}
        it {subject[:commits].should == 1}
        it {subject[:additions].should == 64}
        it {subject[:deletions].should == 16}

        it {subject[:languages][:Ruby][:additions].should == 64}
        it {subject[:languages][:Ruby][:deletions].should == 16}
      end

      it {config[:sort].should == sort}
      it {config[:email].should == email}
      it {config[:top_n].should == 0}
      it {config[:author_length].should == 17}
      it {config[:language_length].should == 8}
    end

    context "with top_n that filters to one author" do
      let(:top_n) {1}
      let(:data) {config[:data]}
      author = "Kevin Jalbert"
      subject {data[author]}

      it {data.has_key?(author).should be_true}

      it {subject[:commits].should == 1}
      it {subject[:additions].should == 73}
      it {subject[:deletions].should == 0}
      it {subject[:create].should == 2}

      it {subject[:languages][:Ruby][:additions].should == 62}
      it {subject[:languages][:Ruby][:deletions].should == 0}
      it {subject[:languages][:Ruby][:create].should == 1}
      it {subject[:languages][:Markdown][:additions].should == 11}
      it {subject[:languages][:Markdown][:deletions].should == 0}
      it {subject[:languages][:Markdown][:create].should == 1}

      it {config[:sort].should == sort}
      it {config[:email].should == email}
      it {config[:top_n].should == top_n}
      it {config[:author_length].should == 17}
      it {config[:language_length].should == 8}
    end
  end

  describe "#print_summary" do
    context "with valid data" do
      let(:language_data) {results.print_summary(sort, email)}
      it {language_data.should == fixture("summary_output.txt").read}
    end
  end

  describe "#print_language_data" do
    context "with valid data" do
      let(:language_data) {results.print_language_data(config[:pattern], config[:data]["Kevin Jalbert"])}
      it {language_data.should == fixture("language_data_output.txt").read}
    end
  end

  describe "#print_header" do
    context "with valid data" do
      let(:header) {results.print_header(config)}
      it {header.should == fixture("header_output.txt").read}
    end
  end

end

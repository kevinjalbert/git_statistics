require 'spec_helper'
include GitStatistics
include GitStatistics::Formatters

describe Console do
  let(:limit) { 100 }
  let(:fresh) { true }
  let(:pretty) { false }
  let(:repo) { GIT_REPO }
  let(:collector) { Collector.new(repo, limit, fresh, pretty) }

  let(:commits) { collector.commits }

  let(:fixture_file) { 'multiple_authors.json' }
  let(:save_file) { File.join(collector.commits_path, '0.json') }
  let(:email) { false }
  let(:merge) { false }
  let(:sort) { :commits }
  let(:top_n) { 0 }

  let(:results) do
    setup_commits(commits, fixture_file, save_file, pretty)
    commits.calculate_statistics(email, merge)
    commits.author_top_n_type(sort)
    Console.new(commits)
  end

  let(:config) do
    results.prepare_result_summary(sort, email, top_n)
  end

  before { config }

  describe '#prepare_result_summary' do
    context 'with email and sorting' do
      context 'on first author' do
        let(:data) { config[:data] }
        author = 'Kevin Jalbert'
        subject { data[author] }

        it do
          expect(data.key?(author)).to be true

          expect(subject[:commits]).to eq(1)
          expect(subject[:additions]).to eq(73)
          expect(subject[:deletions]).to eq(0)
          expect(subject[:added_files]).to eq(2)

          expect(subject[:languages][:Ruby][:additions]).to eq(62)
          expect(subject[:languages][:Ruby][:deletions]).to eq(0)
          expect(subject[:languages][:Ruby][:added_files]).to eq(1)
          expect(subject[:languages][:Markdown][:additions]).to eq(11)
          expect(subject[:languages][:Markdown][:deletions]).to eq(0)
          expect(subject[:languages][:Markdown][:added_files]).to eq(1)
        end
      end

      context 'on second author' do
        let(:data) { config[:data] }
        author = 'John Smith'
        subject { data[author] }

        it do
          expect(data.key?(author)).to be true
          expect(subject[:commits]).to eq(1)
          expect(subject[:additions]).to eq(64)
          expect(subject[:deletions]).to eq(16)

          expect(subject[:languages][:Ruby][:additions]).to eq(64)
          expect(subject[:languages][:Ruby][:deletions]).to eq(16)
        end
      end

      it do
        expect(config[:sort]).to eq(sort)
        expect(config[:email]).to eq(email)
        expect(config[:top_n]).to eq(top_n)
        expect(config[:author_length]).to eq(17)
        expect(config[:language_length]).to eq(8)
      end
    end

    context 'with negative top_n' do
      let(:top_n) { -1 }

      context 'on first author' do
        let(:data) { config[:data] }
        author = 'Kevin Jalbert'
        subject { data[author] }

        it do
          expect(data.key?(author)).to be true

          expect(subject[:commits]).to eq(1)
          expect(subject[:additions]).to eq(73)
          expect(subject[:deletions]).to eq(0)
          expect(subject[:added_files]).to eq(2)

          expect(subject[:languages][:Ruby][:additions]).to eq(62)
          expect(subject[:languages][:Ruby][:deletions]).to eq(0)
          expect(subject[:languages][:Ruby][:added_files]).to eq(1)
          expect(subject[:languages][:Markdown][:additions]).to eq(11)
          expect(subject[:languages][:Markdown][:deletions]).to eq(0)
          expect(subject[:languages][:Markdown][:added_files]).to eq(1)
        end
      end

      context 'on second author' do
        let(:data) { config[:data] }
        author = 'John Smith'
        subject { data[author] }

        it do
          expect(data.key?(author)).to be true

          expect(subject[:commits]).to eq(1)
          expect(subject[:additions]).to eq(64)
          expect(subject[:deletions]).to eq(16)

          expect(subject[:languages][:Ruby][:additions]).to eq(64)
          expect(subject[:languages][:Ruby][:deletions]).to eq(16)
        end
      end

      it do
        expect(config[:sort]).to eq(sort)
        expect(config[:email]).to eq(email)
        expect(config[:top_n]).to eq(0)
        expect(config[:author_length]).to eq(17)
        expect(config[:language_length]).to eq(8)
      end
    end

    context 'with top_n that filters to one author' do
      let(:top_n) { 1 }
      let(:data) { config[:data] }
      author = 'Kevin Jalbert'
      subject { data[author] }

      it do
        expect(data.key?(author)).to be true

        expect(subject[:commits]).to eq(1)
        expect(subject[:additions]).to eq(73)
        expect(subject[:deletions]).to eq(0)
        expect(subject[:added_files]).to eq(2)

        expect(subject[:languages][:Ruby][:additions]).to eq(62)
        expect(subject[:languages][:Ruby][:deletions]).to eq(0)
        expect(subject[:languages][:Ruby][:added_files]).to eq(1)
        expect(subject[:languages][:Markdown][:additions]).to eq(11)
        expect(subject[:languages][:Markdown][:deletions]).to eq(0)
        expect(subject[:languages][:Markdown][:added_files]).to eq(1)

        expect(config[:sort]).to eq(sort)
        expect(config[:email]).to eq(email)
        expect(config[:top_n]).to eq(top_n)
        expect(config[:author_length]).to eq(17)
        expect(config[:language_length]).to eq(8)
      end
    end
  end

  describe 'output' do
    let(:output) { fixture(file).file.read }
    describe '#print_summary' do
      context 'with valid data' do
        let(:file) { 'summary_output.txt' }
        subject { results.print_summary(sort, email) }
        it { expect(subject).to eq(output.chomp) }
      end
    end

    describe '#print_language_data' do
      context 'with valid data' do
        let(:file) { 'language_data_output.txt' }
        subject { results.print_language_data(config[:data]['Kevin Jalbert']) }
        it { expect(subject).to eq(output.split("\n")) }
      end
    end

    describe '#print_header' do
      context 'with valid data' do
        let(:file) { 'header_output.txt' }
        subject { results.print_header.join("\n") }
        it { expect(subject).to eq(output.chomp) }
      end
    end
  end
end

require 'spec_helper'
require 'fileutils'
include GitStatistics

describe Commits do
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
  let(:stats) do
    setup_commits(commits, fixture_file, save_file, pretty)
    commits.calculate_statistics(email, merge)
    commits.author_top_n_type(sort)
  end

  describe '#files_in_path' do
    let(:path) { '/tmp/example' }
    subject { commits.files_in_path }
    around do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.touch '0.json'
          FileUtils.touch '1.json'
          commits.stub(:path) { dir }
          example.run
        end
      end
    end
    its(:count) { should == 2 }
    it { should_not include '.' }
    it { should_not include '..' }
  end

  describe '#flush_commits' do
    let(:commits) { collector.commits.load(fixture(fixture_file).file) }

    def commit_size_changes_from(beginning, opts = {})
      expect(commits.size).to eq(beginning)
      commits.flush_commits
      expect(commits.size).to eq(opts[:to])
    end

    context 'with commits exceeding limit' do
      let(:limit) { 2 }
      it { commit_size_changes_from(3, to: 0) }
    end

    context 'with commits equal to limit' do
      let(:limit) { 3 }
      it { commit_size_changes_from(3, to: 0) }
    end

    context 'with commits less than limit' do
      let(:limit) { 5 }
      it { commit_size_changes_from(3, to: 3) }
    end
  end

  describe '#process_commits' do
    let(:commits) { collector.commits.load(fixture(fixture_file).file) }
    let(:type) { :author }
    subject { commits.stats[author_name] }

    before do
      commits.process_commits(type, merge)
    end

    context 'with merge' do
      let(:merge) { true }

      context 'on first author' do
        let(:author_name) { 'Kevin Jalbert' }
        it { subject[:additions].should == 153 }
        it { subject[:deletions].should == 5 }
        it { subject[:commits].should == 2 }
        it { subject[:added_files].should == 3 }
        it { subject[:merges].should == 1 }

        it { subject[:languages][:Markdown][:additions].should == 18 }
        it { subject[:languages][:Markdown][:deletions].should == 1 }
        it { subject[:languages][:Markdown][:added_files].should == 1 }
        it { subject[:languages][:Ruby][:additions].should == 135 }
        it { subject[:languages][:Ruby][:deletions].should == 4 }
        it { subject[:languages][:Ruby][:added_files].should == 2 }
      end

      context 'on second author' do
        let(:author_name) { 'John Smith' }
        it { subject[:additions].should == 64 }
        it { subject[:deletions].should == 16 }
        it { subject[:commits].should == 1 }

        it { subject[:languages][:Ruby][:additions].should == 64 }
        it { subject[:languages][:Ruby][:deletions].should == 16 }
        it { subject[:languages][:Ruby][:added_files].should == 0 }
      end
    end

    context 'without merge' do
      let(:merge) { false }

      context 'on first author' do
        let(:author_name) { 'Kevin Jalbert' }
        it { subject[:additions].should == 73 }
        it { subject[:deletions].should == 0 }
        it { subject[:commits].should == 1 }
        it { subject[:added_files].should == 2 }

        it { subject[:languages][:Markdown][:additions].should == 11 }
        it { subject[:languages][:Markdown][:deletions].should == 0 }
        it { subject[:languages][:Markdown][:added_files].should == 1 }
        it { subject[:languages][:Ruby][:additions].should == 62 }
        it { subject[:languages][:Ruby][:deletions].should == 0 }
        it { subject[:languages][:Ruby][:added_files].should == 1 }
      end

      context 'on second author' do
        let(:author_name) { 'John Smith' }
        it { subject[:additions].should == 64 }
        it { subject[:deletions].should == 16 }
        it { subject[:commits].should == 1 }

        it { subject[:languages][:Ruby][:additions].should == 64 }
        it { subject[:languages][:Ruby][:deletions].should == 16 }
      end
    end
  end

  describe '#author_top_n_type' do
    let(:sort) { :deletions }
    subject { stats[author] }

    context 'with valid data' do
      context 'on first author' do
        let(:author) { 'John Smith' }
        it { stats.key?(author).should be_true }
        it { subject[:commits].should == 1 }
        it { subject[:deletions].should == 16 }
        it { subject[:additions].should == 64 }

        it { subject[:languages][:Ruby][:additions].should == 64 }
        it { subject[:languages][:Ruby][:deletions].should == 16 }
      end

      context 'on second author' do
        let(:author) { 'Kevin Jalbert' }
        it { stats.key?(author).should be_true }
        it { subject[:commits].should == 1 }
        it { subject[:additions].should == 73 }
        it { subject[:deletions].should == 0 }
        it { subject[:added_files].should == 2 }

        it { subject[:languages][:Markdown][:additions].should == 11 }
        it { subject[:languages][:Markdown][:deletions].should == 0 }
        it { subject[:languages][:Markdown][:added_files].should == 1 }
        it { subject[:languages][:Ruby][:additions].should == 62 }
        it { subject[:languages][:Ruby][:deletions].should == 0 }
        it { subject[:languages][:Ruby][:added_files].should == 1 }
      end
    end

    context 'with invalid type' do
      let(:sort) { :wrong }
      it { stats.should be_nil }
    end

    context 'with invalid data' do
      let(:fixture_file) { nil }
      it { stats.should be_nil }
    end
  end

  describe '#calculate_statistics' do
    let(:fixture_file) { 'single_author_pretty.json' }
    subject { stats[author] }

    context 'with email' do
      let(:email) { true }
      let(:author) { 'kevin.j.jalbert@gmail.com' }

      it { stats.key?(author).should be_true }
      it { subject[:commits].should == 1 }
      it { subject[:additions].should == 73 }
      it { subject[:deletions].should == 0 }
      it { subject[:added_files].should == 2 }

      it { subject[:languages][:Markdown][:additions].should == 11 }
      it { subject[:languages][:Markdown][:deletions].should == 0 }
      it { subject[:languages][:Ruby][:additions].should == 62 }
      it { subject[:languages][:Ruby][:deletions].should == 0 }
      it { subject[:languages][:Ruby][:added_files].should == 1 }
    end

    context 'with merge' do
      let(:merge) { true }
      let(:author) { 'Kevin Jalbert' }

      it { stats.key?(author).should be_true }
      it { subject[:commits].should == 2 }
      it { subject[:additions].should == 153 }
      it { subject[:deletions].should == 5 }
      it { subject[:added_files].should == 3 }
      it { subject[:merges].should == 1 }

      it { subject[:languages][:Markdown][:additions].should == 18 }
      it { subject[:languages][:Markdown][:deletions].should == 1 }
      it { subject[:languages][:Ruby][:additions].should == 135 }
      it { subject[:languages][:Ruby][:deletions].should == 4 }
      it { subject[:languages][:Ruby][:added_files].should == 2 }
    end
  end

  describe '#add_language_stats' do
    context 'with file language' do
      let(:data) do
        data = Hash.new(0)
        data[:languages] = {}

        file = { additions: 10,
                 deletions: 5 }

        file[:language] = 'Ruby'

        commits.add_language_stats(data, file)
      end

      it { data[:languages][:Ruby][:additions].should == 10 }
      it { data[:languages][:Ruby][:deletions].should == 5 }
    end

    context 'with multiple files' do
      let(:data) do
        data = Hash.new(0)
        data[:languages] = {}

        file = { additions: 10,
                 deletions: 5 }

        # First file is "Ruby"
        file[:language] = 'Ruby'
        data = commits.add_language_stats(data, file)

        # Second file is "Java"
        file[:language] = 'Java'
        data = commits.add_language_stats(data, file)

        # Third file is "Ruby"
        file[:language] = 'Ruby'
        commits.add_language_stats(data, file)
      end

      it { data[:languages][:Ruby][:additions].should == 20 }
      it { data[:languages][:Ruby][:deletions].should == 10 }
      it { data[:languages][:Java][:additions].should == 10 }
      it { data[:languages][:Java][:deletions].should == 5 }
    end
  end

  describe '#add_commit_stats' do
    context 'with valid commit' do
      let(:data) do
        commit = { additions: 10,
                   deletions: 5,
                   new_files: 0,
                   removed_files: 0,
                   merge: false }

        data = Hash.new(0)
        commits.add_commit_stats(data, commit)
      end

      it { data[:commits].should == 1 }
      it { data[:additions].should == 10 }
      it { data[:deletions].should == 5 }
      it { data[:merges].should == 0 }
    end

    context 'with multiple commits (one merge commit)' do
      let(:data) do
        commit = { additions: 10,
                   deletions: 5,
                   new_files: 0,
                   removed_files: 0,
                   merge: false }

        data = Hash.new(0)
        data = commits.add_commit_stats(data, commit)

        # Second commit has merge status
        commit[:merge] = true
        commits.add_commit_stats(data, commit)
      end

      it { data[:commits].should == 2 }
      it { data[:additions].should == 20 }
      it { data[:deletions].should == 10 }
      it { data[:merges].should == 1 }
    end

    context 'with commit that has file status changes' do
      let(:data) do
        commit = { additions: 10,
                   deletions: 5,
                   added_files: 1,
                   deleted_files: 2,
                   merge: false }

        data = Hash.new(0)
        commits.add_commit_stats(data, commit)
      end

      it { data[:commits].should == 1 }
      it { data[:additions].should == 10 }
      it { data[:deletions].should == 5 }
      it { data[:added_files].should == 1 }
      it { data[:deleted_files].should == 2 }
    end
  end

  describe '#save and #load' do
    let(:fixture_contents) { fixture(fixture_file).io.join("\n") }
    let(:tmpfile_contents) { File.read('tmp.json') }

    before do
      commits.load(fixture(fixture_file).file)
      commits.save('tmp.json', pretty)
    end

    after do
      FileUtils.remove_file('tmp.json')
    end

    context 'with pretty' do
      let(:fixture_file) { 'single_author_pretty.json' }
      let(:pretty) { true }

      it do
        JSON.parse(fixture_contents).should == JSON.parse(tmpfile_contents)
      end
    end

    context 'with no pretty' do
      let(:fixture_file) { 'multiple_authors.json' }
      let(:pretty) { false }

      it do
        JSON.parse(fixture_contents).should == JSON.parse(tmpfile_contents)
      end
    end
  end
end

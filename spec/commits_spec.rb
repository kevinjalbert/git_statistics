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

    it do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.touch '0.json'
          FileUtils.touch '1.json'
          allow(commits).to receive(:path) { dir }

          expect(subject.count).to eq(2)
          expect(subject).to_not include('.')
          expect(subject).to_not include('..')
        end
      end
    end
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

        it do
          expect(subject[:additions]).to eq(153)
          expect(subject[:deletions]).to eq(5)
          expect(subject[:commits]).to eq(2)
          expect(subject[:added_files]).to eq(3)
          expect(subject[:merges]).to eq(1)

          expect(subject[:languages][:Markdown][:additions]).to eq(18)
          expect(subject[:languages][:Markdown][:deletions]).to eq(1)
          expect(subject[:languages][:Markdown][:added_files]).to eq(1)
          expect(subject[:languages][:Ruby][:additions]).to eq(135)
          expect(subject[:languages][:Ruby][:deletions]).to eq(4)
          expect(subject[:languages][:Ruby][:added_files]).to eq(2)
        end
      end

      context 'on second author' do
        let(:author_name) { 'John Smith' }

        it do
          expect(subject[:additions]).to eq(64)
          expect(subject[:deletions]).to eq(16)
          expect(subject[:commits]).to eq(1)

          expect(subject[:languages][:Ruby][:additions]).to eq(64)
          expect(subject[:languages][:Ruby][:deletions]).to eq(16)
          expect(subject[:languages][:Ruby][:added_files]).to eq(0)
        end
      end
    end

    context 'without merge' do
      let(:merge) { false }

      context 'on first author' do
        let(:author_name) { 'Kevin Jalbert' }

        it do
          expect(subject[:additions]).to eq(73)
          expect(subject[:deletions]).to eq(0)
          expect(subject[:commits]).to eq(1)
          expect(subject[:added_files]).to eq(2)

          expect(subject[:languages][:Markdown][:additions]).to eq(11)
          expect(subject[:languages][:Markdown][:deletions]).to eq(0)
          expect(subject[:languages][:Markdown][:added_files]).to eq(1)
          expect(subject[:languages][:Ruby][:additions]).to eq(62)
          expect(subject[:languages][:Ruby][:deletions]).to eq(0)
          expect(subject[:languages][:Ruby][:added_files]).to eq(1)
        end
      end

      context 'on second author' do
        let(:author_name) { 'John Smith' }

        it do
          expect(subject[:additions]).to eq(64)
          expect(subject[:deletions]).to eq(16)
          expect(subject[:commits]).to eq(1)

          expect(subject[:languages][:Ruby][:additions]).to eq(64)
          expect(subject[:languages][:Ruby][:deletions]).to eq(16)
        end
      end
    end
  end

  describe '#author_top_n_type' do
    let(:sort) { :deletions }
    subject { stats[author] }

    context 'with valid data' do
      context 'on first author' do
        let(:author) { 'John Smith' }

        it do
          expect(stats.key?(author)).to be true
          expect(subject[:commits]).to eq(1)
          expect(subject[:deletions]).to eq(16)
          expect(subject[:additions]).to eq(64)

          expect(subject[:languages][:Ruby][:additions]).to eq(64)
          expect(subject[:languages][:Ruby][:deletions]).to eq(16)
        end
      end

      context 'on second author' do
        let(:author) { 'Kevin Jalbert' }

        it do
          expect(stats.key?(author)).to be true
          expect(subject[:commits]).to eq(1)
          expect(subject[:additions]).to eq(73)
          expect(subject[:deletions]).to eq(0)
          expect(subject[:added_files]).to eq(2)

          expect(subject[:languages][:Markdown][:additions]).to eq(11)
          expect(subject[:languages][:Markdown][:deletions]).to eq(0)
          expect(subject[:languages][:Markdown][:added_files]).to eq(1)
          expect(subject[:languages][:Ruby][:additions]).to eq(62)
          expect(subject[:languages][:Ruby][:deletions]).to eq(0)
          expect(subject[:languages][:Ruby][:added_files]).to eq(1)
        end
      end
    end

    context 'with invalid type' do
      let(:sort) { :wrong }
      it { expect(stats).to be nil }
    end

    context 'with invalid data' do
      let(:fixture_file) { nil }
      it { expect(stats).to be nil }
    end
  end

  describe '#calculate_statistics' do
    let(:fixture_file) { 'single_author_pretty.json' }
    subject { stats[author] }

    context 'with email' do
      let(:email) { true }
      let(:author) { 'kevin.j.jalbert@gmail.com' }

      it do
        expect(stats.key?(author)).to be true
        expect(subject[:commits]).to eq(1)
        expect(subject[:additions]).to eq(73)
        expect(subject[:deletions]).to eq(0)
        expect(subject[:added_files]).to eq(2)

        expect(subject[:languages][:Markdown][:additions]).to eq(11)
        expect(subject[:languages][:Markdown][:deletions]).to eq(0)
        expect(subject[:languages][:Ruby][:additions]).to eq(62)
        expect(subject[:languages][:Ruby][:deletions]).to eq(0)
        expect(subject[:languages][:Ruby][:added_files]).to eq(1)
      end
    end

    context 'with merge' do
      let(:merge) { true }
      let(:author) { 'Kevin Jalbert' }

      it do
        expect(stats.key?(author)).to be true
        expect(subject[:commits]).to eq(2)
        expect(subject[:additions]).to eq(153)
        expect(subject[:deletions]).to eq(5)
        expect(subject[:added_files]).to eq(3)
        expect(subject[:merges]).to eq(1)

        expect(subject[:languages][:Markdown][:additions]).to eq(18)
        expect(subject[:languages][:Markdown][:deletions]).to eq(1)
        expect(subject[:languages][:Ruby][:additions]).to eq(135)
        expect(subject[:languages][:Ruby][:deletions]).to eq(4)
        expect(subject[:languages][:Ruby][:added_files]).to eq(2)
      end
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

      it do
        expect(data[:languages][:Ruby][:additions]).to eq(10)
        expect(data[:languages][:Ruby][:deletions]).to eq(5)
      end
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

      it do
        expect(data[:languages][:Ruby][:additions]).to eq(20)
        expect(data[:languages][:Ruby][:deletions]).to eq(10)
        expect(data[:languages][:Java][:additions]).to eq(10)
        expect(data[:languages][:Java][:deletions]).to eq(5)
      end
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

      it do
        expect(data[:commits]).to eq(1)
        expect(data[:additions]).to eq(10)
        expect(data[:deletions]).to eq(5)
        expect(data[:merges]).to eq(0)
      end
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

      it do
        expect(data[:commits]).to eq(2)
        expect(data[:additions]).to eq(20)
        expect(data[:deletions]).to eq(10)
        expect(data[:merges]).to eq(1)
      end
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

      it do
        expect(data[:commits]).to eq(1)
        expect(data[:additions]).to eq(10)
        expect(data[:deletions]).to eq(5)
        expect(data[:added_files]).to eq(1)
        expect(data[:deleted_files]).to eq(2)
      end
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
        expect(JSON.parse(fixture_contents)).to eq(JSON.parse(tmpfile_contents))
      end
    end

    context 'with no pretty' do
      let(:fixture_file) { 'multiple_authors.json' }
      let(:pretty) { false }

      it do
        expect(JSON.parse(fixture_contents)).to eq(JSON.parse(tmpfile_contents))
      end
    end
  end
end

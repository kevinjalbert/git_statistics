require 'spec_helper'
include GitStatistics

describe CommitSummary do
  let(:sha) { 'bf09a64b0e0f801d3e7fe4e002cbd1bf517340a7' }
  let(:repo) { GIT_REPO }
  subject(:commit) { CommitSummary.new(repo, repo.lookup(sha)) }

  it { expect(subject.__getobj__).to be_a(Rugged::Commit) }

  context 'understands its files and languages' do
    it do
      expect(subject.filenames.size).to eq(3)
      expect(subject.languages.size).to eq(1)
    end
  end

  context 'language-specific changes' do
    let(:name) { 'Ruby' }
    subject(:language) { commit.languages.find { |lang| lang.name == name } }

    context 'for commit 2aa45e4ff23c1a558b127c06e95d313a56cc6890' do
      let(:sha) { '2aa45e4ff23c1a558b127c06e95d313a56cc6890' }

      context 'language count' do
        it { expect(commit.languages.size).to eq(2) }
      end

      context 'Ruby' do
        let(:name) { 'Ruby' }
        it do
          expect(subject.additions).to eq(14)
          expect(subject.deletions).to eq(13)
          expect(subject.net).to eq(1)
        end
      end

      context 'Text' do
        let(:name) { 'Text' }
        it do
          expect(subject.additions).to eq(7)
          expect(subject.deletions).to eq(11)
          expect(subject.net).to eq(-4)
        end
      end
    end

    context 'for commit bf09a64b' do
      subject { commit.languages.first }
      it do
        expect(subject.name).to eq('Ruby')
        expect(subject.additions).to eq(10)
        expect(subject.deletions).to eq(27)
        expect(subject.net).to eq(-17)
      end
    end
  end

  context 'file-specific changes' do
    let(:name) { 'lib/git_statistics/formatters/console.rb' }
    subject(:file) { commit.file_stats.find { |file| file.filename == name } }

    context 'for commit ef9292a92467430e0061e1b1ad4cbbc3ad7da6fd' do
      let(:sha) { 'ef9292a92467430e0061e1b1ad4cbbc3ad7da6fd' }

      context 'file count' do
        it { expect(commit.filenames.size).to eq(12) }
      end

      context 'bin/git_statistics (new)' do
        let(:name) { 'bin/git_statistics' }
        it do
          expect(subject.language).to eq('Ruby')
          expect(subject.additions).to eq(5)
          expect(subject.deletions).to eq(0)
          expect(subject.net).to eq(5)
          expect(subject.status).to eq(:added)
        end
      end

      context 'lib/initialize.rb (deleted)' do
        let(:name) { 'lib/initialize.rb' }
        it do
          expect(subject.language).to eq('Ruby')
          expect(subject.additions).to eq(0)
          expect(subject.deletions).to eq(4)
          expect(subject.net).to eq(-4)
          expect(subject.status).to eq(:deleted)
        end
      end

      context 'lib/git_statistics.rb (modified)' do
        let(:name) { 'lib/git_statistics.rb' }
        it do
          expect(subject.language).to eq('Ruby')
          expect(subject.additions).to eq(37)
          expect(subject.deletions).to eq(30)
          expect(subject.net).to eq(7)
          expect(subject.status).to eq(:modified)
        end
      end
    end
  end

  context 'with a removed file' do
    let(:sha) { '4ce86b844458a1fd77c6066c9297576b9520f97e' }
    it { expect(subject.deleted_files).to eq(2) }
  end

  context 'without a removed file' do
    let(:sha) { 'b808b3a9d4ce2d8a1d850f2c24d2d1fb00e67727' }
    it { expect(subject.deleted_files).to eq(0) }
  end

  context 'with a new file' do
    let(:sha) { '8b1941437a0ff8cf6a35a46d4f5df8b6587c346f' }
    it { expect(subject.added_files).to eq(19) }
  end

  context 'without a new file' do
    let(:sha) { '52f9f38cbe4ba90edd607298cb2f9b1aec26bcf1' }
    it { expect(subject.added_files).to eq(0) }
  end

  context 'with a merge' do
    let(:sha) { '9d31467f6759c92f8535038c470d24a37ae93a9d' }

    it { should be_a_merge }

    context 'statistics' do
      it do
        expect(subject.filenames.size).to eq(11)
        expect(subject.languages.size).to eq(1)
        expect(subject.additions).to eq(69)
        expect(subject.deletions).to eq(68)
        expect(subject.net).to eq(1)
      end
    end
  end

  context 'without a merge' do
    it { should_not be_a_merge }
  end

  context 'net, additions, and deletions' do
    it do
      expect(subject.additions).to eq(10)
      expect(subject.deletions).to eq(27)
      expect(subject.net).to eq(-17)
    end
  end
end

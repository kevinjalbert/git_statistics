require 'spec_helper'
include GitStatistics

describe Collector do
  let(:limit) { 100 }
  let(:fresh) { true }
  let(:pretty) { false }
  let(:repo) { GIT_REPO }
  let(:collector) { Collector.new(repo, limit, fresh, pretty) }

  describe '#collect' do
    let(:branch) { CLI::DEFAULT_BRANCH }
    let(:email) { false }
    let(:merge) { true }
    let(:time_since) { 'Tue Sep 24 14:15:44 2012 -0400' }
    let(:time_until) { 'Tue Sep 26 14:45:05 2012 -0400' }
    let(:author) { 'Kevin Jalbert' }

    subject do
      collector.collect(branch: branch, time_since: time_since, time_until: time_until)
      collector.commits.calculate_statistics(email, merge)
      collector.commits.stats[author]
    end

    context 'with no merge commits' do
      let(:merge) { false }
      let(:time_since) { 'Tue Sep 10 14:15:44 2012 -0400' }
      let(:time_until) { 'Tue Sep 11 14:45:05 2012 -0400' }

      it do
        expect(subject[:additions]).to eq(276)
        expect(subject[:deletions]).to eq(99)
        expect(subject[:commits]).to eq(4)
        expect(subject[:merges]).to eq(0)

        expect(subject[:languages][:Ruby][:additions]).to eq(270)
        expect(subject[:languages][:Ruby][:deletions]).to eq(99)
        expect(subject[:languages][:Ruby][:added_files]).to eq(2)
        expect(subject[:languages][:Text][:additions]).to eq(6)
        expect(subject[:languages][:Text][:deletions]).to eq(0)
        expect(subject[:languages][:Text][:added_files]).to eq(1)
      end
    end

    context 'with merge commits and merge option' do
      it do
        expect(subject[:additions]).to eq(1240)
        expect(subject[:deletions]).to eq(934)
        expect(subject[:commits]).to eq(9)
        expect(subject[:merges]).to eq(1)

        expect(subject[:languages][:Markdown][:additions]).to eq(1)
        expect(subject[:languages][:Markdown][:deletions]).to eq(0)
        expect(subject[:languages][:Ruby][:additions]).to eq(1227)
        expect(subject[:languages][:Ruby][:deletions]).to eq(934)
        expect(subject[:languages][:Unknown][:additions]).to eq(12)
        expect(subject[:languages][:Unknown][:deletions]).to eq(0)
      end
    end

    context 'with merge commits and no merge option' do
      let(:merge) { false }

      it do
        expect(subject[:additions]).to eq(581)
        expect(subject[:deletions]).to eq(452)
        expect(subject[:commits]).to eq(8)
        expect(subject[:merges]).to eq(0)

        expect(subject[:languages][:Markdown][:additions]).to eq(1)
        expect(subject[:languages][:Markdown][:deletions]).to eq(0)
        expect(subject[:languages][:Ruby][:additions]).to eq(574)
        expect(subject[:languages][:Ruby][:deletions]).to eq(452)
        expect(subject[:languages][:Unknown][:additions]).to eq(6)
        expect(subject[:languages][:Unknown][:deletions]).to eq(0)
      end
    end
  end

  describe '#extract_commit' do
    let(:commit) { repo.lookup(sha) }
    let(:data) { collector.extract_commit(commit, nil) }

    context 'with valid commit' do
      let(:sha) { '260bc61e2c42930d91f3503c5849b0a2351275cf' }

      it do
        expect(data[:author]).to eq('Kevin Jalbert')
        expect(data[:author_email]).to eq('kevin.j.jalbert@gmail.com')
        expect(data[:time]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-|+]\d{4}/)

        expect(data[:merge]).to eq(false)
        expect(data[:additions]).to eq(30)
        expect(data[:deletions]).to eq(2)
        expect(data[:added_files]).to eq(1)
        expect(data[:deleted_files]).to eq(0)

        expect(data[:files][0][:filename]).to eq('Gemfile')
        expect(data[:files][0][:additions]).to eq(0)
        expect(data[:files][0][:deletions]).to eq(1)
        expect(data[:files][0][:status]).to eq(:modified)
        expect(data[:files][0][:language]).to eq('Ruby')

        expect(data[:files][1][:filename]).to eq('Gemfile.lock')
        expect(data[:files][1][:additions]).to eq(30)
        expect(data[:files][1][:deletions]).to eq(0)
        expect(data[:files][1][:status]).to eq(:added)
        expect(data[:files][1][:language]).to eq('Unknown')

        expect(data[:files][2][:filename]).to eq('lib/git_statistics/initialize.rb')
        expect(data[:files][2][:additions]).to eq(0)
        expect(data[:files][2][:deletions]).to eq(1)
        expect(data[:files][2][:status]).to eq(:modified)
        expect(data[:files][2][:language]).to eq('Ruby')
      end
    end

    context 'with invalid commit' do
      let(:sha) { '111111aa111a11111a11aa11aaaa11a111111a11' }
      it { expect { data }.to raise_error(Rugged::OdbError) }
    end

    context 'with invalid sha' do
      let(:sha) { 'invalid input' }
      it { expect { data }.to raise_error(Rugged::InvalidError) }
    end
  end
end

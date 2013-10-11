require 'spec_helper'
include GitStatistics

describe Collector do
  let(:limit) {100}
  let(:fresh) {true}
  let(:pretty) {false}
  let(:repo) { GIT_REPO }
  let(:collector) {Collector.new(repo, limit, fresh, pretty)}

  describe "#collect" do
    let(:branch) {CLI::DEFAULT_BRANCH}
    let(:email) {false}
    let(:merge) {true}
    let(:time_since) {"Tue Sep 24 14:15:44 2012 -0400"}
    let(:time_until) {"Tue Sep 26 14:45:05 2012 -0400"}
    let(:author) {"Kevin Jalbert"}

    let(:setup) {
      collector.collect({:branch => branch, :time_since => time_since, :time_until => time_until})
      collector.commits.calculate_statistics(email, merge)
      @subject = collector.commits.stats[author]
    }

    context "with no merge commits" do
      let(:merge) {false}
      let(:time_since) {"Tue Sep 10 14:15:44 2012 -0400"}
      let(:time_until) {"Tue Sep 11 14:45:05 2012 -0400"}

      before(:all) { setup }

      it{@subject[:additions].should == 276}
      it{@subject[:deletions].should == 99}
      it{@subject[:commits].should == 4}
      it{@subject[:merges].should == 0}

      it{@subject[:languages][:Ruby][:additions].should == 270}
      it{@subject[:languages][:Ruby][:deletions].should == 99}
      it{@subject[:languages][:Ruby][:added_files].should == 2}
      it{@subject[:languages][:Text][:additions].should == 6}
      it{@subject[:languages][:Text][:deletions].should == 0}
      it{@subject[:languages][:Text][:added_files].should == 1}
    end

    context "with merge commits and merge option" do
      before(:all) { setup }

      it{@subject[:additions].should == 1240}
      it{@subject[:deletions].should == 934}
      it{@subject[:commits].should == 9}
      it{@subject[:merges].should == 1}

      it{@subject[:languages][:Markdown][:additions].should == 1}
      it{@subject[:languages][:Markdown][:deletions].should == 0}
      it{@subject[:languages][:Ruby][:additions].should == 1227}
      it{@subject[:languages][:Ruby][:deletions].should == 934}
      it{@subject[:languages][:Unknown][:additions].should == 12}
      it{@subject[:languages][:Unknown][:deletions].should == 0}
    end

    context "with merge commits and no merge option" do
      let(:merge) {false}
      before(:all) { setup }

      it{@subject[:additions].should == 581}
      it{@subject[:deletions].should == 452}
      it{@subject[:commits].should == 8}
      it{@subject[:merges].should == 0}

      it{@subject[:languages][:Markdown][:additions].should == 1}
      it{@subject[:languages][:Markdown][:deletions].should == 0}
      it{@subject[:languages][:Ruby][:additions].should == 574}
      it{@subject[:languages][:Ruby][:deletions].should == 452}
      it{@subject[:languages][:Unknown][:additions].should == 6}
      it{@subject[:languages][:Unknown][:deletions].should == 0}
    end
  end

  describe "#extract_commit" do
    let(:commit) {repo.lookup(sha)}
    let(:data) {collector.extract_commit(commit, nil)}

    context "with valid commit" do
      let(:sha) {"260bc61e2c42930d91f3503c5849b0a2351275cf"}
      it {data[:author].should == "Kevin Jalbert"}
      it {data[:author_email].should == "kevin.j.jalbert@gmail.com"}
      it {data[:time].should match /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-|+]\d{4}/}

      it {data[:merge].should == false}
      it {data[:additions].should == 30}
      it {data[:deletions].should == 2}
      it {data[:added_files].should == 1}
      it {data[:deleted_files].should == 0}

      it {data[:files][0][:filename].should == "Gemfile"}
      it {data[:files][0][:additions].should == 0}
      it {data[:files][0][:deletions].should == 1}
      it {data[:files][0][:status].should.nil?}
      it {data[:files][0][:language].should == "Ruby"}

      it {data[:files][1][:filename].should == "Gemfile.lock"}
      it {data[:files][1][:additions].should == 30}
      it {data[:files][1][:deletions].should == 0}
      it {data[:files][1][:status].should eq(:added)}
      it {data[:files][1][:language].should == "Unknown"}

      it {data[:files][2][:filename].should == "lib/git_statistics/initialize.rb"}
      it {data[:files][2][:additions].should == 0}
      it {data[:files][2][:deletions].should == 1}
      it {data[:files][2][:status].should.nil?}
      it {data[:files][2][:language].should == "Ruby"}
    end

    context "with invalid commit" do
      let(:sha) {"111111aa111a11111a11aa11aaaa11a111111a11"}
      it { expect {data}.to raise_error(Rugged::OdbError) }
    end

    context "with invalid sha" do
      let(:sha) {"invalid input"}
      it { expect {data}.to raise_error(Rugged::InvalidError) }
    end
  end

end

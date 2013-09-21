require 'spec_helper'
include GitStatistics

describe Collector do
  let(:limit) {100}
  let(:fresh) {true}
  let(:pretty) {false}
  let(:repo) { GIT_REPO }
  let(:collector) {Collector.new(repo, limit, fresh, pretty)}

  # Create buffer which is an array of cleaned lines
  let(:buffer) {
    fixture(fixture_file).lines
  }

  describe "#collect" do
    let(:branch) {""}
    let(:email) {false}
    let(:merge) {true}
    let(:time_since) {"Tue Sep 25 14:15:44 2012 -0400"}
    let(:time_until) {"Tue Sep 25 14:45:05 2012 -0400"}
    let(:author) {"Kevin Jalbert"}

    let(:setup) {
      collector.collect(branch, {:since => time_since, :until => time_until})
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
      it{@subject[:languages][:Ruby][:create].should == 2}
      it{@subject[:languages][:Text][:additions].should == 6}
      it{@subject[:languages][:Text][:deletions].should == 0}
      it{@subject[:languages][:Text][:create].should == 1}
    end

    context "with merge commits and merge option" do
      before(:all) { setup }

      it{@subject[:additions].should == 667}
      it{@subject[:deletions].should == 483}
      it{@subject[:commits].should == 3}
      it{@subject[:merges].should == 1}

      it{@subject[:languages][:Markdown][:additions].should == 1}
      it{@subject[:languages][:Markdown][:deletions].should == 0}
      it{@subject[:languages][:Ruby][:additions].should == 654}
      it{@subject[:languages][:Ruby][:deletions].should == 483}
      it{@subject[:languages][:Unknown][:additions].should == 12}
      it{@subject[:languages][:Unknown][:deletions].should == 0}
    end

    context "with merge commits and no merge option" do
      let(:merge) {false}
      before(:all) { setup }

      it{@subject[:additions].should == 8}
      it{@subject[:deletions].should == 1}
      it{@subject[:commits].should == 2}
      it{@subject[:merges].should == 0}

      it{@subject[:languages][:Markdown][:additions].should == 1}
      it{@subject[:languages][:Markdown][:deletions].should == 0}
      it{@subject[:languages][:Ruby][:additions].should == 1}
      it{@subject[:languages][:Ruby][:deletions].should == 1}
      it{@subject[:languages][:Unknown][:additions].should == 6}
      it{@subject[:languages][:Unknown][:deletions].should == 0}
    end
  end

  describe "#extract_commit" do
    let(:commit) {repo.commit(sha)}
    let(:data) {collector.extract_commit(commit)}

    context "with valid commit" do
      let(:sha) {"260bc61e2c42930d91f3503c5849b0a2351275cf"}
      it {data[:author].should == "Kevin Jalbert"}
      it {data[:author_email].should == "kevin.j.jalbert@gmail.com"}
      it {data[:time].should match /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} -\d{4}/}

      it {data[:merge].should == false}
      it {data[:additions].should == 30}
      it {data[:deletions].should == 2}
      it {data[:new_files].should == 1}
      it {data[:removed_files].should == 0}

      it {data[:files][0][:name].should == "Gemfile"}
      it {data[:files][0][:additions].should == 0}
      it {data[:files][0][:deletions].should == 1}
      it {data[:files][0][:filestatus].should.nil?}
      it {data[:files][0][:language].should == "Ruby"}

      it {data[:files][1][:name].should == "Gemfile.lock"}
      it {data[:files][1][:additions].should == 30}
      it {data[:files][1][:deletions].should == 0}
      it {data[:files][1][:filestatus].should eq(:create)}
      it {data[:files][1][:language].should == "Unknown"}

      it {data[:files][2][:name].should == "lib/git_statistics/initialize.rb"}
      it {data[:files][2][:additions].should == 0}
      it {data[:files][2][:deletions].should == 1}
      it {data[:files][2][:filestatus].should.nil?}
      it {data[:files][2][:language].should == "Ruby"}
    end

    context "with invalid commit" do
      let(:sha) {"111111aa111a11111a11aa11aaaa11a111111a11"}
      it {data.should.nil?}
    end

    context "with invalid sha" do
      let(:sha) {"invalid input"}
      it {data.should.nil?}
    end
  end

end

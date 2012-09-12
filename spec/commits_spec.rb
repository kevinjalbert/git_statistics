require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Commits do
  collector = Collector.new(false)

  describe "#author_top_n_type" do
    context "with valid data" do
      commits = Commits.new
      commits.load(fixture("multiple_authors.json"))

      commits.calculate_statistics(false, false)
      stats = commits.author_top_n_type(:deletions)

      # Check stats for first author
      author_1 = "John Smith"
      it {stats.has_key?(author_1).should be_true}
      it {stats[author_1][:commits].should == 1}
      it {stats[author_1][:additions].should == 64}
      it {stats[author_1][:deletions].should == 16}

      it {stats[author_1][:languages][:Ruby][:additions].should == 64}
      it {stats[author_1][:languages][:Ruby][:deletions].should == 16}

      # Check stats for second author
      author_2 = "Kevin Jalbert"
      it {stats.has_key?(author_2).should be_true}
      it {stats[author_2][:commits].should == 1}
      it {stats[author_2][:additions].should == 73}
      it {stats[author_2][:deletions].should == 0}
      it {stats[author_2][:create].should == 2}

      it {stats[author_2][:languages][:Markdown][:additions].should == 11}
      it {stats[author_2][:languages][:Markdown][:deletions].should == 0}
      it {stats[author_2][:languages][:Markdown][:create].should== 1}
      it {stats[author_2][:languages][:Ruby][:additions].should == 62}
      it {stats[author_2][:languages][:Ruby][:deletions].should == 0}
      it {stats[author_2][:languages][:Ruby][:create].should == 1}
    end

    context "with invalid type" do
      commits = Commits.new
      commits.load(fixture("multiple_authors.json"))

      commits.calculate_statistics(false, false)
      stats = commits.author_top_n_type(:wrong)

      it {stats.should == nil}
    end

    context "with invalid data" do
      commits = Commits.new

      commits.calculate_statistics(false, false)
      stats = commits.author_top_n_type(:deletions)

      it {stats.should == nil}
    end
  end

  describe "#calculate_statistics" do
    context "with email" do
      commits = Commits.new
      commits.load(fixture("single_author_pretty.json"))

      commits.calculate_statistics(true, false)
      stats = commits.author_top_n_type(:commits)

      author = "kevin.j.jalbert@gmail.com"
      it {stats.has_key?(author).should be_true}
      it {stats[author][:commits].should == 1}
      it {stats[author][:additions].should == 73}
      it {stats[author][:deletions].should == 0}
      it {stats[author][:create].should == 2}

      it {stats[author][:languages][:Markdown][:additions].should == 11}
      it {stats[author][:languages][:Markdown][:deletions].should == 0}
      it {stats[author][:languages][:Ruby][:additions].should == 62}
      it {stats[author][:languages][:Ruby][:deletions].should == 0}
      it {stats[author][:languages][:Ruby][:create].should == 1}
    end

    context "with merge" do
      commits = Commits.new
      commits.load(fixture("single_author_pretty.json"))

      commits.calculate_statistics(false, true)
      stats = commits.author_top_n_type(:commits)

      author = "Kevin Jalbert"
      it {stats.has_key?(author).should be_true}
      it {stats[author][:commits].should == 2}
      it {stats[author][:additions].should == 153}
      it {stats[author][:deletions].should == 5}
      it {stats[author][:create].should == 3}
      it {stats[author][:merges].should == 1}

      it {stats[author][:languages][:Markdown][:additions].should == 18}
      it {stats[author][:languages][:Markdown][:deletions].should == 1}
      it {stats[author][:languages][:Ruby][:additions].should == 135}
      it {stats[author][:languages][:Ruby][:deletions].should == 4}
      it {stats[author][:languages][:Ruby][:create].should == 2}
    end
  end

  describe "#add_language_stats" do
    file = {:additions => 10,
            :deletions => 5}

    context "with file language" do
     commits = Commits.new
     data = Hash.new(0)
     data[:languages] = {}

     file[:language] = "Ruby"

     data = commits.add_language_stats(data, file)

     it {data[:languages][:Ruby][:additions].should == 10}
     it {data[:languages][:Ruby][:deletions].should == 5}
    end

    context "with multiple files" do
     commits = Commits.new
     data = Hash.new(0)
     data[:languages] = {}

     # First file is "Ruby"
     file[:language] = "Ruby"
     data = commits.add_language_stats(data, file)

     # Second file is "Java"
     file[:language] = "Java"
     data = commits.add_language_stats(data, file)

     # Third file is "Ruby"
     file[:language] = "Ruby"
     data = commits.add_language_stats(data, file)

     it {data[:languages][:Ruby][:additions].should == 20}
     it {data[:languages][:Ruby][:deletions].should == 10}
     it {data[:languages][:Java][:additions].should == 10}
     it {data[:languages][:Java][:deletions].should == 5}
    end
  end

  describe "#add_commit_stats" do
    commit = {:additions => 10,
              :deletions => 5,
              :merge => false}

    context "with valid commit" do
     commits = Commits.new
     data = Hash.new(0)

     data = commits.add_commit_stats(data, commit)

     it {data[:commits].should == 1}
     it {data[:additions].should == 10}
     it {data[:deletions].should == 5}
     it {data[:merges].should == 0}
    end

    context "with multiple commits" do
     commits = Commits.new
     data = Hash.new(0)

     data = commits.add_commit_stats(data, commit)

     # Second commit has merge status
     commit[:merge] = true

     data = commits.add_commit_stats(data, commit)

     it {data[:commits].should == 2}
     it {data[:additions].should == 20}
     it {data[:deletions].should == 10}
     it {data[:merges].should == 1}
    end

    context "with commit that has file status changes" do
     commits = Commits.new
     data = Hash.new(0)
     commit[:create] = 1
     commit[:delete] = 2
     commit[:rename] = 3
     commit[:copy] = 4

     data = commits.add_commit_stats(data, commit)

     it {data[:commits].should == 1}
     it {data[:additions].should == 10}
     it {data[:deletions].should == 5}
     it {data[:create].should == 1}
     it {data[:delete].should == 2}
     it {data[:rename].should == 3}
     it {data[:copy].should == 4}
    end

    context "with merge commit" do
     commits = Commits.new
     data = Hash.new(0)
     commit[:merge] = true

     data = commits.add_commit_stats(data, commit)

     it {data[:commits].should == 1}
     it {data[:additions].should == 10}
     it {data[:deletions].should == 5}
     it {data[:merges].should == 1}
    end
  end

  describe "#save and #load" do
    context "with pretty" do
      commits = Commits.new
      commits.load(fixture("single_author_pretty.json"))
      commits.save("tmp.json", true)

      same = FileUtils.compare_file("tmp.json", fixture("single_author_pretty.json"))
      FileUtils.remove_file("tmp.json")

      it {same.should be_true}
    end

    context "with no pretty" do
      commits = Commits.new
      commits.load(fixture("multiple_authors.json"))
      commits.save("tmp.json", false)

      same = FileUtils.compare_file("tmp.json", fixture("multiple_authors.json"))
      FileUtils.remove_file("tmp.json")

      it {same.should be_true}
    end
  end

end

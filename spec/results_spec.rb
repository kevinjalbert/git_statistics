require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Results do
  email = false
  merge = false
  sort = "commits"

  commits = Commits.new
  commits.load(fixture("multiple_authors.json"))
  commits.calculate_statistics(email, merge)

  results = Results.new(commits)

  describe "#prepare_result_summary" do

    context "with email and sorting" do
      config = results.prepare_result_summary(sort, email)
      data = config[:data]

      author_1 = "Kevin Jalbert"
      author_2 = "John Smith"

      it {data.has_key?(author_1).should be_true}
      it {data.has_key?(author_2).should be_true}

      it {data[author_1][:commits].should == 1}
      it {data[author_1][:additions].should == 73}
      it {data[author_1][:deletions].should == 0}
      it {data[author_1][:create].should == 2}

      it {data[author_1][:languages][:Ruby][:additions].should == 62}
      it {data[author_1][:languages][:Ruby][:deletions].should == 0}
      it {data[author_1][:languages][:Ruby][:create].should == 1}
      it {data[author_1][:languages][:Markdown][:additions].should == 11}
      it {data[author_1][:languages][:Markdown][:deletions].should == 0}
      it {data[author_1][:languages][:Markdown][:create].should == 1}

      it {data[author_2][:commits].should == 1}
      it {data[author_2][:additions].should == 64}
      it {data[author_2][:deletions].should == 16}

      it {data[author_2][:languages][:Ruby][:additions].should == 64}
      it {data[author_2][:languages][:Ruby][:deletions].should == 16}

      it {config[:sort].should == sort}
      it {config[:email].should == email}
      it {config[:top_n].should == 0}
      it {config[:author_length].should == 17}
      it {config[:language_length].should == 8}
    end

    context "with negative top_n" do
      config = results.prepare_result_summary(sort, email, -1)
      data = config[:data]

      author_1 = "Kevin Jalbert"
      author_2 = "John Smith"

      it {data.has_key?(author_1).should be_true}
      it {data.has_key?(author_2).should be_true}

      it {data[author_1][:commits].should == 1}
      it {data[author_1][:additions].should == 73}
      it {data[author_1][:deletions].should == 0}
      it {data[author_1][:create].should == 2}

      it {data[author_1][:languages][:Ruby][:additions].should == 62}
      it {data[author_1][:languages][:Ruby][:deletions].should == 0}
      it {data[author_1][:languages][:Ruby][:create].should == 1}
      it {data[author_1][:languages][:Markdown][:additions].should == 11}
      it {data[author_1][:languages][:Markdown][:deletions].should == 0}
      it {data[author_1][:languages][:Markdown][:create].should == 1}

      it {data[author_2][:commits].should == 1}
      it {data[author_2][:additions].should == 64}
      it {data[author_2][:deletions].should == 16}

      it {data[author_2][:languages][:Ruby][:additions].should == 64}
      it {data[author_2][:languages][:Ruby][:deletions].should == 16}

      it {config[:sort].should == sort}
      it {config[:email].should == email}
      it {config[:top_n].should == 0}
      it {config[:author_length].should == 17}
      it {config[:language_length].should == 8}
    end

    context "with top_n that filters to one author" do
      config = results.prepare_result_summary(sort, email, 1)
      data = config[:data]

      author_1 = "Kevin Jalbert"
      author_2 = "John Smith"

      it {data.has_key?(author_1).should be_true}
      it {data.has_key?(author_2).should be_false}

      it {data[author_1][:commits].should == 1}
      it {data[author_1][:additions].should == 73}
      it {data[author_1][:deletions].should == 0}
      it {data[author_1][:create].should == 2}

      it {data[author_1][:languages][:Ruby][:additions].should == 62}
      it {data[author_1][:languages][:Ruby][:deletions].should == 0}
      it {data[author_1][:languages][:Ruby][:create].should == 1}
      it {data[author_1][:languages][:Markdown][:additions].should == 11}
      it {data[author_1][:languages][:Markdown][:deletions].should == 0}
      it {data[author_1][:languages][:Markdown][:create].should == 1}

      it {config[:sort].should == sort}
      it {config[:email].should == email}
      it {config[:top_n].should == 1}
      it {config[:author_length].should == 17}
      it {config[:language_length].should == 8}
    end

  end
end

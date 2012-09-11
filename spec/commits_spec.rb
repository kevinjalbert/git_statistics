require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Commits do
  collector = Collector.new(false)

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

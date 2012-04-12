require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Commits do
  describe "#authors" do
    context "with one author" do
      commits = Commits.new
      commits.load(fixture("single_author.json"))
      author_list = commits.authors


      it { author_list.size.should be(1) }
      it { author_list[0].should == "Kevin Jalbert" }
    end

    context "with many authors" do
      commits = Commits.new
      commits.load(fixture("many_authors.json"))
      author_list = commits.authors

      it { author_list.size.should be(3) }
      it { author_list[0].should == "Bart Simpson" }
      it { author_list[1].should == "Kevin Jalbert" }
      it { author_list[2].should == "Maggie Simpson" }
    end

    context "with no authors" do
      commits = Commits.new
      author_list = commits.authors

      it { author_list.size.should be(0) }
    end
  end

  describe "#authors_email" do
    context "with one author" do
      commits = Commits.new
      commits.load(fixture("single_author.json"))
      author_list = commits.authors_email

      it { author_list.size.should be(1) }
      it { author_list[0].should == "kevin.j.jalbert@gmail.com" }
    end

    context "with many authors" do
      commits = Commits.new
      commits.load(fixture("many_authors.json"))
      author_list = commits.authors_email

      it { author_list.size.should be(3) }
      it { author_list[0].should == "bart.simpson@gmail.com" }
      it { author_list[1].should == "kevin.j.jalbert@gmail.com" }
      it { author_list[2].should == "maggie.simpson@gmail.com" }
    end

    context "with no authors" do
      commits = Commits.new
      author_list = commits.authors_email

      it { author_list.size.should be(0) }
    end
  end

  describe "#authors_statistics" do
    context "with email" do
      context "with merge" do
        commits = Commits.new
        commits.load(fixture("many_authors.json"))
        results = commits.authors_statistics(true, true)

        it {results.size.should be(3)}
        it {results["bart.simpson@gmail.com"][:commits].should be(2)}
        it {results["bart.simpson@gmail.com"][:insertions].should be(13)}
        it {results["bart.simpson@gmail.com"][:deletions].should be(3)}
        it {results["bart.simpson@gmail.com"][:creates].should be(2)}
        it {results["bart.simpson@gmail.com"][:deletes].should be(0)}
        it {results["bart.simpson@gmail.com"][:renames].should be(2)}
        it {results["bart.simpson@gmail.com"][:copies].should be(0)}
        it {results["bart.simpson@gmail.com"][:merges].should be(1)}

        it {results["kevin.j.jalbert@gmail.com"][:commits].should be(1)}
        it {results["kevin.j.jalbert@gmail.com"][:insertions].should be(62)}
        it {results["kevin.j.jalbert@gmail.com"][:deletions].should be(6)}
        it {results["kevin.j.jalbert@gmail.com"][:creates].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:deletes].should be(1)}
        it {results["kevin.j.jalbert@gmail.com"][:renames].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:copies].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:merges].should be(1)}

        it {results["maggie.simpson@gmail.com"][:commits].should be(2)}
        it {results["maggie.simpson@gmail.com"][:insertions].should be(211)}
        it {results["maggie.simpson@gmail.com"][:deletions].should be(192)}
        it {results["maggie.simpson@gmail.com"][:creates].should be(7)}
        it {results["maggie.simpson@gmail.com"][:deletes].should be(2)}
        it {results["maggie.simpson@gmail.com"][:renames].should be(3)}
        it {results["maggie.simpson@gmail.com"][:copies].should be(1)}
        it {results["maggie.simpson@gmail.com"][:merges].should be(0)}

      end

      context "no merge" do
        commits = Commits.new
        commits.load(fixture("many_authors.json"))
        results = commits.authors_statistics(true, false)

        it {results.size.should be(3)}
        it {results["bart.simpson@gmail.com"][:commits].should be(1)}
        it {results["bart.simpson@gmail.com"][:insertions].should be(3)}
        it {results["bart.simpson@gmail.com"][:deletions].should be(2)}
        it {results["bart.simpson@gmail.com"][:creates].should be(2)}
        it {results["bart.simpson@gmail.com"][:deletes].should be(0)}
        it {results["bart.simpson@gmail.com"][:renames].should be(0)}
        it {results["bart.simpson@gmail.com"][:copies].should be(0)}
        it {results["bart.simpson@gmail.com"][:merges].should be(0)}

        it {results["kevin.j.jalbert@gmail.com"][:commits].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:insertions].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:deletions].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:creates].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:deletes].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:renames].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:copies].should be(0)}
        it {results["kevin.j.jalbert@gmail.com"][:merges].should be(0)}

        it {results["maggie.simpson@gmail.com"][:commits].should be(2)}
        it {results["maggie.simpson@gmail.com"][:insertions].should be(211)}
        it {results["maggie.simpson@gmail.com"][:deletions].should be(192)}
        it {results["maggie.simpson@gmail.com"][:creates].should be(7)}
        it {results["maggie.simpson@gmail.com"][:deletes].should be(2)}
        it {results["maggie.simpson@gmail.com"][:renames].should be(3)}
        it {results["maggie.simpson@gmail.com"][:copies].should be(1)}
        it {results["maggie.simpson@gmail.com"][:merges].should be(0)}
      end
    end

    context "no email" do
      context "with merge" do
        commits = Commits.new
        commits.load(fixture("many_authors.json"))
        results = commits.authors_statistics(false, true)

        it {results.size.should be(3)}
        it {results["Bart Simpson"][:commits].should be(2)}
        it {results["Bart Simpson"][:insertions].should be(13)}
        it {results["Bart Simpson"][:deletions].should be(3)}
        it {results["Bart Simpson"][:creates].should be(2)}
        it {results["Bart Simpson"][:deletes].should be(0)}
        it {results["Bart Simpson"][:renames].should be(2)}
        it {results["Bart Simpson"][:copies].should be(0)}
        it {results["Bart Simpson"][:merges].should be(1)}

        it {results["Kevin Jalbert"][:commits].should be(1)}
        it {results["Kevin Jalbert"][:insertions].should be(62)}
        it {results["Kevin Jalbert"][:deletions].should be(6)}
        it {results["Kevin Jalbert"][:creates].should be(0)}
        it {results["Kevin Jalbert"][:deletes].should be(1)}
        it {results["Kevin Jalbert"][:renames].should be(0)}
        it {results["Kevin Jalbert"][:copies].should be(0)}
        it {results["Kevin Jalbert"][:merges].should be(1)}

        it {results["Maggie Simpson"][:commits].should be(2)}
        it {results["Maggie Simpson"][:insertions].should be(211)}
        it {results["Maggie Simpson"][:deletions].should be(192)}
        it {results["Maggie Simpson"][:creates].should be(7)}
        it {results["Maggie Simpson"][:deletes].should be(2)}
        it {results["Maggie Simpson"][:renames].should be(3)}
        it {results["Maggie Simpson"][:copies].should be(1)}
        it {results["Maggie Simpson"][:merges].should be(0)}

      end

      context "no merge" do
        commits = Commits.new
        commits.load(fixture("many_authors.json"))
        results = commits.authors_statistics(false, false)

        it {results.size.should be(3)}
        it {results["Bart Simpson"][:commits].should be(1)}
        it {results["Bart Simpson"][:insertions].should be(3)}
        it {results["Bart Simpson"][:deletions].should be(2)}
        it {results["Bart Simpson"][:creates].should be(2)}
        it {results["Bart Simpson"][:deletes].should be(0)}
        it {results["Bart Simpson"][:renames].should be(0)}
        it {results["Bart Simpson"][:copies].should be(0)}
        it {results["Bart Simpson"][:merges].should be(0)}

        it {results["Kevin Jalbert"][:commits].should be(0)}
        it {results["Kevin Jalbert"][:insertions].should be(0)}
        it {results["Kevin Jalbert"][:deletions].should be(0)}
        it {results["Kevin Jalbert"][:creates].should be(0)}
        it {results["Kevin Jalbert"][:deletes].should be(0)}
        it {results["Kevin Jalbert"][:renames].should be(0)}
        it {results["Kevin Jalbert"][:copies].should be(0)}
        it {results["Kevin Jalbert"][:merges].should be(0)}

        it {results["Maggie Simpson"][:commits].should be(2)}
        it {results["Maggie Simpson"][:insertions].should be(211)}
        it {results["Maggie Simpson"][:deletions].should be(192)}
        it {results["Maggie Simpson"][:creates].should be(7)}
        it {results["Maggie Simpson"][:deletes].should be(2)}
        it {results["Maggie Simpson"][:renames].should be(3)}
        it {results["Maggie Simpson"][:copies].should be(1)}
        it {results["Maggie Simpson"][:merges].should be(0)}
      end
    end
  end

  describe "#author_top_n_type" do
    context "no data" do
      context "with email" do
        commits = Commits.new
        results = commits.author_top_n_type(true, :commits)

        it { results.should be(nil)}
      end

      context "without email" do
        commits = Commits.new
        results = commits.author_top_n_type(false, :commits)

        it { results.should be(nil)}
      end
    end

    context "with data" do
      context "with email" do
        context "n is negative" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(true, true)
          results = commits.author_top_n_type(true, :commits, -1)

          it { results.size.should be(3)}
          it { results[0][0].should == "bart.simpson@gmail.com"}
          it { results[1][0].should == "maggie.simpson@gmail.com"}
          it { results[2][0].should == "kevin.j.jalbert@gmail.com"}

        end

        context "n is 0" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(true, true)
          results = commits.author_top_n_type(true, :commits, 0)

          it { results.size.should be(3)}
          it { results[0][0].should == "bart.simpson@gmail.com"}
          it { results[1][0].should == "maggie.simpson@gmail.com"}
          it { results[2][0].should == "kevin.j.jalbert@gmail.com"}
        end

        context "n is less then total" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(true, true)
          results = commits.author_top_n_type(true, :commits, 2)

          it { results.size.should be(2)}
          it { results[0][0].should == "bart.simpson@gmail.com"}
          it { results[1][0].should == "maggie.simpson@gmail.com"}
        end

        context "n is greater then total" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(true, true)
          results = commits.author_top_n_type(true, :commits, 20)

          it { results.size.should be(3)}
          it { results[0][0].should == "bart.simpson@gmail.com"}
          it { results[1][0].should == "maggie.simpson@gmail.com"}
          it { results[2][0].should == "kevin.j.jalbert@gmail.com"}
        end
      end

      context "no email" do
        context "n is negative" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(false, true)
          results = commits.author_top_n_type(false, :commits, -1)

          it { results.size.should be(3)}
          it { results[0][0].should == "Bart Simpson"}
          it { results[1][0].should == "Maggie Simpson"}
          it { results[2][0].should == "Kevin Jalbert"}

        end

        context "n is 0" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(false, true)
          results = commits.author_top_n_type(false, :commits, 0)

          it { results.size.should be(3)}
          it { results[0][0].should == "Bart Simpson"}
          it { results[1][0].should == "Maggie Simpson"}
          it { results[2][0].should == "Kevin Jalbert"}
        end

        context "n is less then total" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(false, true)
          results = commits.author_top_n_type(false, :commits, 2)

          it { results.size.should be(2)}
          it { results[0][0].should == "Bart Simpson"}
          it { results[1][0].should == "Maggie Simpson"}
        end

        context "n is greater then total" do
          commits = Commits.new
          commits.load(fixture("many_authors.json"))
          commits.calculate_statistics(false, true)
          results = commits.author_top_n_type(false, :commits, 20)

          it { results.size.should be(3)}
          it { results[0][0].should == "Bart Simpson"}
          it { results[1][0].should == "Maggie Simpson"}
          it { results[2][0].should == "Kevin Jalbert"}
        end
      end
    end
  end

  describe "#calculate_statistics (totals)" do
    context "with merge" do
      commits = Commits.new
      commits.load(fixture("many_authors.json"))
      commits.calculate_statistics(true, true)
      results = commits.totals

      it {results[:commits].should be(5)}
      it {results[:insertions].should be(286)}
      it {results[:deletions].should be(201)}
      it {results[:creates].should be(9)}
      it {results[:deletes].should be(3)}
      it {results[:renames].should be(5)}
      it {results[:copies].should be(1)}
      it {results[:merges].should be(2)}
    end

    context "no merge" do
      commits = Commits.new
      commits.load(fixture("many_authors.json"))
      commits.calculate_statistics(false, false)
      results = commits.totals

      it {results[:commits].should be(3)}
      it {results[:insertions].should be(214)}
      it {results[:deletions].should be(194)}
      it {results[:creates].should be(9)}
      it {results[:deletes].should be(2)}
      it {results[:renames].should be(3)}
      it {results[:copies].should be(1)}
      it {results[:merges].should be(0)}
    end
  end

  describe "#save" do
    context "with pretty" do
      commits = Commits.new
      commits.load(fixture("single_author.json"))
      commits.save("tmp.json", true)
      same = FileUtils.compare_file("tmp.json", fixture("single_author.json"))
      FileUtils.remove_file("tmp.json")
      it { same.should be_true }
    end

    context "no pretty" do
      commits = Commits.new
      commits.load(fixture("single_author.json"))
      commits.save("tmp.json", false)
      same = FileUtils.compare_file("tmp.json", fixture("single_author_unpretty.json"))
      FileUtils.remove_file("tmp.json")
      it { same.should be_true }
    end
  end
end

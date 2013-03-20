require 'spec_helper'
include GitStatistics

describe Collector do
  let(:verbose) {false}
  let(:limit) {100}
  let(:fresh) {true}
  let(:pretty) {false}
  let(:collector) {Collector.new(verbose, limit, fresh, pretty)}

  # Create buffer which is an array of cleaned lines
  let(:buffer) {
    fixture(fixture_file).readlines.map(&:clean_for_authors)
  }

  describe "#collect" do
    let(:branch) {""}
    let(:email) {false}
    let(:merge) {true}
    let(:time_since) {"--since \"Tue Sep 25 14:15:44 2012 -0400\""}
    let(:time_until) {"--until \"Tue Sep 25 14:45:05 2012 -0400\""}
    let(:author) {"Kevin Jalbert"}

    let(:setup) {
      collector.collect(branch, time_since, time_until)
      collector.commits.calculate_statistics(email, merge)
      @subject = collector.commits.stats[author]
    }

    context "with no merge commits" do
      let(:merge) {false}
      let(:time_since) {"--since \"Tue Sep 10 14:15:44 2012 -0400\""}
      let(:time_until) {"--until \"Tue Sep 11 14:45:05 2012 -0400\""}

      before(:all) {setup}

      it{@subject[:additions].should == 276}
      it{@subject[:deletions].should == 99}
      it{@subject[:commits].should == 4}
      it{@subject[:merges].should == 0}

      it{@subject[:languages][:Ruby][:additions].should == 270}
      it{@subject[:languages][:Ruby][:deletions].should == 99}
      it{@subject[:languages][:Ruby][:create].should == 2}
      it{@subject[:languages][:Unknown][:additions].should == 6}
      it{@subject[:languages][:Unknown][:deletions].should == 0}
      it{@subject[:languages][:Unknown][:create].should == 1}
    end

    context "with merge commits and merge option" do
      before(:all) {setup}

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
      before(:all) {setup}

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

  describe "#collect_branches" do
    let(:branches) {collector.collect_branches(fixture(fixture_file))}

    context "with many branches" do
    let(:fixture_file) {"git_many_branches.txt"}
      it {branches.size.should == 2}
      it {branches[0].should == "issue_2"}
      it {branches[1].should == "master"}
    end

    context "with zero branches" do
      let(:fixture_file) {"git_zero_branches.txt"}
      it {branches.size.should == 1}
      it {branches[0].should == "master"}
    end

    context "with many branches in detached state" do
      let(:fixture_file) {"git_many_branches_detached_state.txt"}
      it {branches.size.should == 2}
      it {branches[0].should == "issue_2"}
      it {branches[1].should == "master"}
    end

    context "with zero branches in detached state" do
      let(:fixture_file) {"git_zero_branches_detached_state.txt"}
      it {branches.size.should == 1}
      it {branches[0].should == "master"}
    end
  end

  describe "#acquire_commit_data" do
    let(:input) {fixture(fixture_file).read}
    let(:data) {collector.acquire_commit_data(input)}

    context "no parent, first commit" do
      let(:fixture_file) {"commit_buffer_information_first.txt"}
      it {data[:sha].should == "111111aa111a11111a11aa11aaaa11a111111a11"}
      it {data[:data][:author].should == "Test Author"}
      it {data[:data][:author_email].should == "author@test.com"}
      it {data[:data][:time].should == "2011-01-11 11:11:11 +0000"}
      it {data[:data][:merge].should be_false}
    end

    context "without merge, one parent" do
      let(:fixture_file) {"commit_buffer_information.txt"}
      it {data[:sha].should == "111111aa111a11111a11aa11aaaa11a111111a11"}
      it {data[:data][:author].should == "Test Author"}
      it {data[:data][:author_email].should == "author@test.com"}
      it {data[:data][:time].should == "2011-01-11 11:11:11 +0000"}
      it {data[:data][:merge].should be_false}
    end

    context "with merge, two parents" do
      let(:fixture_file) {"commit_buffer_information_with_merge.txt"}
      it {data[:sha].should == "111111aa111a11111a11aa11aaaa11a111111a11"}
      it {data[:data][:author].should == "Test Author"}
      it {data[:data][:author_email].should == "author@test.com"}
      it {data[:data][:time].should == "2011-01-11 11:11:11 +0000"}
      it {data[:data][:merge].should be_true}
    end
  end

  describe "#identify_changed_files" do
    let(:files) {collector.identify_changed_files(buffer)}
    let(:fixture_file) {"commit_buffer_changes.txt"}

    context "with no changes" do
      let(:buffer) {[]}
      it {files.size.should == 0}
      it {files[0].should.nil?}
    end

    context "with all types (create,delete,rename,copy) of files" do
      it {files.size.should == 5}

      it {files[0][:additions].should == 45}
      it {files[0][:deletions].should == 1}
      it {files[0][:file].should == "dir/README"}

      it {files[1][:additions].should == 6}
      it {files[1][:deletions].should == 5}
      it {files[1][:old_file].should == "dir/lib/old_dir/copy_file.rb"}
      it {files[1][:file].should == "dir/lib/new_dir/copy_file.rb"}
      it {files[1][:status].should == "copy"}

      it {files[2][:additions].should == 0}
      it {files[2][:deletions].should == 0}
      it {files[2][:old_file].should == "dir/lib/rename/old_file.rb"}
      it {files[2][:file].should == "dir/lib/rename/new_file.rb"}
      it {files[2][:status].should == "rename"}

      it {files[3][:additions].should == 0}
      it {files[3][:deletions].should == 127}
      it {files[3][:file].should == "dir/lib/delete_file.rb"}
      it {files[3][:status].should == "delete"}

      it {files[4][:additions].should == 60}
      it {files[4][:deletions].should == 0}
      it {files[4][:file].should == "dir/lib/create_file.rb"}
      it {files[4][:status].should == "create"}
    end
  end

  describe "#extract_commit" do
    let(:data) {collector.extract_commit(buffer)}

    context "with valid buffer" do
      let(:fixture_file) {"commit_buffer_whole.txt"}

      it {data[:author].should == "Kevin Jalbert"}
      it {data[:author_email].should == "kevin.j.jalbert@gmail.com"}
      it {data[:time].should == "2012-04-12 14:13:56 -0400"}

      it {data[:merge].should == false}
      it {data[:additions].should == 30}
      it {data[:deletions].should == 2}
      it {data[:create].should == 1}

      it {data[:files][0][:name].should == "Gemfile"}
      it {data[:files][0][:additions].should == 0}
      it {data[:files][0][:deletions].should == 1}
      it {data[:files][0][:status].should.nil?}
      it {data[:files][0][:binary].should == false}
      it {data[:files][0][:image].should == false}
      it {data[:files][0][:vendored].should == false}
      it {data[:files][0][:generated].should == false}
      it {data[:files][0][:language].should == "Ruby"}

      it {data[:files][1][:name].should == "Gemfile.lock"}
      it {data[:files][1][:additions].should == 30}
      it {data[:files][1][:deletions].should == 0}
      it {data[:files][1][:status].should == "create"}
      it {data[:files][1][:binary].should == false}
      it {data[:files][1][:image].should == false}
      it {data[:files][1][:vendored].should == false}
      it {data[:files][1][:generated].should == true}
      it {data[:files][1][:language].should == "Unknown"}

      it {data[:files][2][:name].should == "lib/git_statistics/initialize.rb"}
      it {data[:files][2][:additions].should == 0}
      it {data[:files][2][:deletions].should == 1}
      it {data[:files][2][:status].should.nil?}
      it {data[:files][2][:binary].should == false}
      it {data[:files][2][:image].should == false}
      it {data[:files][2][:vendored].should == false}
      it {data[:files][2][:generated].should == false}
      it {data[:files][2][:language].should == "Ruby"}
    end

    context "with buffer that has no file changes" do
      let(:fixture_file) {"commit_buffer_information.txt"}
      it {data.should.nil?}
    end

    context "with invalid buffer" do
      let(:buffer) {"invalid input"}
      it {data.should.nil?}
    end
  end

  describe "#fall_back_collect_commit" do
    subject { collector.fall_back_collect_commit(sha) }
    context "with valid sha" do
      let(:fixture_file) { "commit_buffer_whole.txt" }
      let(:sha) { "260bc61e2c42930d91f3503c5849b0a2351275cf" }
      it { should == buffer }
    end

    context "with invalid sha" do
      let(:sha) { "111111aa111a11111a11aa11aaaa11a111111a11" }
      it { should be_empty }
    end
  end

  describe "#get_blob" do
    let(:sha) { "695b487432e8a1ede765b4e3efda088ab87a77f8" }  # Commit within repository
    subject { collector.get_blob(sha, file) }

    context "with valid blob" do
      let(:file) {{:file => "Gemfile.lock"}}
      it { should be_a Grit::Blob }
      its(:name) { should == File.basename(file[:file]) }
    end

    context "with deleted file" do
      let(:file) {{:file => "spec/collector_spec.rb"}}
      it { should be_a Grit::Blob }
      its(:name) { should == File.basename(file[:file]) }
    end

    context "with invalid blob" do
      let(:file) {{:file => "dir/nothing.rb"}}
      it { should be_nil }
    end
  end

  describe "#process_blob" do
    let(:sha) {"695b487432e8a1ede765b4e3efda088ab87a77f8"}  # Commit within repository
    let(:blob) {collector.get_blob(sha, file)}
    let(:data) {
      data = Hash.new(0)
      data[:files] = []
      collector.process_blob(data, blob, file)
    }
    let(:data_file) {data_file = data[:files].first}

    context "with status (delete) blob" do
      let(:file) {{:file => "spec/collector_spec.rb",
                   :additions => 0,
                   :deletions => 6,
                   :status => "delete"}}

      it {data[:additions].should == file[:additions]}
      it {data[:deletions].should == file[:deletions]}

      it {data_file[:name].should == file[:file]}
      it {data_file[:additions].should == file[:additions]}
      it {data_file[:deletions].should == file[:deletions]}
      it {data_file[:status].should == file[:status]}
      it {data_file[:binary].should == false}
      it {data_file[:image].should == false}
      it {data_file[:vendored].should == false}
      it {data_file[:generated].should == false}
      it {data_file[:language].should == "Ruby"}
    end

    context "with invalid language blob" do
      let(:file) {{:file => "Gemfile.lock",
                   :additions => 33,
                   :deletions => 11,
                   :status => nil}}

      it {data[:additions].should == file[:additions]}
      it {data[:deletions].should == file[:deletions]}

      it {data_file[:name].should == file[:file]}
      it {data_file[:additions].should == file[:additions]}
      it {data_file[:deletions].should == file[:deletions]}
      it {data_file[:status].should.nil?}
      it {data_file[:binary].should == false}
      it {data_file[:image].should == false}
      it {data_file[:vendored].should == false}
      it {data_file[:generated].should == true}
      it {data_file[:language].should == "Unknown"}
    end

    context "with valid language blob" do
      let(:file) {{:file => "README.md",
                   :additions => 7,
                   :deletions => 3,
                   :status => nil}}

      it {data[:additions].should == file[:additions]}
      it {data[:deletions].should == file[:deletions]}

      it {data_file[:name].should == file[:file]}
      it {data_file[:additions].should == file[:additions]}
      it {data_file[:deletions].should == file[:deletions]}
      it {data_file[:status].should.nil?}
      it {data_file[:binary].should == false}
      it {data_file[:image].should == false}
      it {data_file[:vendored].should == false}
      it {data_file[:generated].should == false}
      it {data_file[:language].should == "Markdown"}
    end
  end

end

require File.dirname(__FILE__) + '/spec_helper'
include GitStatistics

describe Collector do
  let(:verbose) {false}
  let(:limit) {100}
  let(:fresh) {true}
  let(:pretty) {false}
  let(:collector) {Collector.new(verbose, limit, fresh, pretty)}

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
  end

  describe "#extract_change_file" do
    let(:file) {collector.extract_change_file(line)}

    context "with a simple changed file" do
      let(:line) {"37	30	lib/file.rb"}
      it {file[:additions].should == 37}
      it {file[:deletions].should == 30}
      it {file[:file].should == "lib/file.rb"}
    end

    context "with a simple rename/copy changed file" do
      let(:line) {"11	3	old_file.rb => lib/file.rb"}
      it {file[:additions].should == 11}
      it {file[:deletions].should == 3}
      it {file[:file].should == "lib/file.rb"}
      it {file[:old_file].should == "old_file.rb"}
    end

    context "with a complex rename/copy changed file" do
      let(:line) {"-	-	lib/{old_dir => new_dir}/file.rb"}
      it {file[:additions].should == 0}
      it {file[:deletions].should == 0}
      it {file[:file].should == "lib/new_dir/file.rb"}
      it {file[:old_file].should == "lib/old_dir/file.rb"}
    end
  end

  describe "#extract_create_delete_file" do
    let(:file) {collector.extract_create_delete_file(line)}

    context "with a create changed file" do
      let(:line) {"create mode 100644 lib/dir/file.rb"}
      it {file[:status].should == "create"}
      it {file[:file].should == "lib/dir/file.rb"}
    end

    context "with a delete changed file" do
      let(:line) {"delete mode 100644 lib/file.rb"}
      it {file[:status].should == "delete"}
      it {file[:file].should == "lib/file.rb"}
    end
  end

  describe "#extract_rename_copy_file" do
    let(:file) {collector.extract_rename_copy_file(line)}

    context "with a rename changed file" do
      let(:line) {"rename lib/{old_dir => new_dir}/file.rb (100%)"}
      it {file[:status].should == "rename"}
      it {file[:old_file].should == "lib/old_dir/file.rb"}
      it {file[:new_file].should == "lib/new_dir/file.rb"}
      it {file[:similar].should == 100}
    end

    context "with a copy changed file" do
      let(:line) {"copy lib/dir/{old_file.rb => new_file.rb} (75%)"}
      it {file[:status].should == "copy"}
      it {file[:old_file].should == "lib/dir/old_file.rb"}
      it {file[:new_file].should == "lib/dir/new_file.rb"}
      it {file[:similar].should == 75}
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

    context "with no changes" do
      let(:buffer) {[]}
      it {files.size.should == 0}
      it {files[0].should == nil}
    end

    context "with all types (create,delete,rename,copy) of files" do
      # Create buffer which is an array of cleaned lines
      let(:buffer) {
        buffer = []
        fixture("commit_buffer_changes.txt").readlines.each do |line|
          buffer << Utilities.clean_string(line)
        end
        buffer
      }

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
    # Create buffer which is an array of cleaned lines
    let(:buffer) {
      buffer = []
      fixture(fixture_file).readlines.each do |line|
        buffer << Utilities.clean_string(line)
      end
      buffer
    }
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
      it {data[:files][0][:status].should == nil}
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
      it {data[:files][2][:status].should == nil}
      it {data[:files][2][:binary].should == false}
      it {data[:files][2][:image].should == false}
      it {data[:files][2][:vendored].should == false}
      it {data[:files][2][:generated].should == false}
      it {data[:files][2][:language].should == "Ruby"}
    end

    context "with buffer that has no file changes" do
      let(:fixture_file) {"commit_buffer_information.txt"}
      it {data.should == nil}
    end

    context "with invalid buffer" do
      let(:buffer) {"invalid input"}
      it {data.should == nil}
    end
  end

  describe "#fall_back_collect_commit" do
    let(:buffer) {collector.fall_back_collect_commit(sha)}
    context "with valid sha" do
      # Create buffer which is an array of cleaned lines
      let(:expected) {
        expected = []
        fixture("commit_buffer_whole.txt").readlines.each do |line|
          expected << Utilities.clean_string(line)
        end
        expected
      }
      let(:sha) {"260bc61e2c42930d91f3503c5849b0a2351275cf"}

      it {buffer.should == expected}
    end

    context "with invalid sha" do
      let(:sha) {"111111aa111a11111a11aa11aaaa11a111111a11"}
      it {buffer.should == nil}
    end
  end

  describe "#get_blob" do
    let(:sha) {"695b487432e8a1ede765b4e3efda088ab87a77f8"}  # Commit within repository
    let(:blob) {collector.get_blob(sha, file)}

    context "with valid blob" do
      let(:file) {{:file => "Gemfile.lock"}}
      it {blob.instance_of?(Grit::Blob).should be_true}
      it {blob.name.should == file[:file].split(File::Separator).last}
    end

    context "with invalid blob" do
      let(:file) {{:file => "dir/nothing.rb"}}
      it {blob.should == nil}
    end

    context "with deleted file" do
      let(:file) {{:file => "spec/collector_spec.rb"}}
      it {blob.instance_of?(Grit::Blob).should be_true}
      it {blob.name.should == file[:file].split(File::Separator).last}
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
      it {data_file[:status].should == nil}
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
      it {data_file[:status].should == nil}
      it {data_file[:binary].should == false}
      it {data_file[:image].should == false}
      it {data_file[:vendored].should == false}
      it {data_file[:generated].should == false}
      it {data_file[:language].should == "Markdown"}
    end
  end

end

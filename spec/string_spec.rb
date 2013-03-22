require "spec_helper"

describe String, "#clean_for_authors" do
  subject { unclean.clean_for_authors }

  context "without trailing spaces" do
    let(:unclean) { "master" }
    it { should == "master" }
    its(:encoding) { should == Encoding.find("UTF-8") }
  end

  context "with trailing spaces" do
    let(:unclean) {"  master   ".force_encoding("ASCII-8BIT")}
    it { should == "master" }
    its(:encoding) { should == Encoding.find("UTF-8") }
  end

end

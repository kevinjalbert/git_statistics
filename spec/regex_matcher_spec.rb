require 'spec_helper'
include GitStatistics

describe RegexMatcher do
  let(:change_info) { RegexMatcher.new(/(match)/i, 1) }
  let(:text) { 'matching string' }

  describe "#scan" do
    subject { change_info.scan(text) }
    context "with matching string" do
      its(:size) { should == 1 }
    end
    context "without matching string" do
      let(:text) { 'does not matter' }
      its(:size) { should == 0 }
    end
  end
  describe "#if_matches" do
    it "should yield the result with matching string" do
      original = :original
      change_info.if_matches(text) do |changes|
        original = :new_value
      end
      original.should == :new_value
    end
    it "should not yield the result without a matching string" do
      text = 'does not yield'
      original = :original
      change_info.if_matches(text) do |changes|
        original = :new_value
      end
      original.should == :original
    end
  end
end

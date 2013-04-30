require 'spec_helper'
include GitStatistics

describe Stats do
  let(:values) { {} }
  subject(:stats)  { Stats.new(values) }

  context "initialization" do
    let(:values) { { key: "value" } }
    it { should == Stats.new({key: "value"}) }
  end

  context "#take_top" do
    let(:values) { { 1=>2, 3=>4, 5=>6, 7=>8 } }
    subject { stats.take_top(number) }

    context "taking nil should return all" do
      let(:number) { nil }
      it { should == stats }
    end

    context "taking 0 should return all" do
      let(:number) { 0 }
      it { should == stats }
    end

    context "taking 1 should return first key=>value pair" do
      let(:number) { 1 }
      it { should == Stats.new(1=>2) }
    end

    context "taking 5 should return all values" do
      let(:number) { 5 }
      it { should == stats }
    end
  end

end

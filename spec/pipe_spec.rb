require 'spec_helper'

include GitStatistics

describe Pipe do
  let(:command) { 'time' }
  let(:line)    { stub }
  let(:pipe)    { Pipe.new(command) }

  context "initializes correctly" do
    context "with pipe character" do
      let(:command) { '|git log --oneline' }
      it { expect(pipe.command).to eq 'git log --oneline'}
    end
    context "without pipe character" do
      let(:command) { 'stat something else' }
      it { expect(pipe.command).to eq 'stat something else'}
    end
  end

  context "#empty?" do
    before { pipe.stub(:lines) { lines } }
    context "with empty lines" do
      let(:lines) { [] }
      it { pipe.should be_empty }
    end
    context "with empty lines" do
      let(:lines) { [stub] }
      it { pipe.should_not be_empty }
    end
  end

  context "#each" do
    before do
      pipe.stub(:lines) { [line, line] }
    end
    it "should delegate to the lines" do
      line.should_receive(:call).twice
      pipe.each(&:call)
    end
  end

  context "#lines" do
    before do
      line.should_receive(:clean_for_authors).twice
      pipe.stub(:io) { [line, line] }
    end
    it { pipe.lines }
  end

  context "#io" do
    it "should call #open and pass the command through" do
      pipe.should_receive(:open).with("|#{command}")
      pipe.io
    end
    it { pipe.io.should be_an IO }
  end

end

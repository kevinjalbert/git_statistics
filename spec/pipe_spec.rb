require 'spec_helper'

include GitStatistics

describe Pipe do
  let(:command) { 'git' }
  let(:line)    { '' }
  let(:pipe)    { Pipe.new(command) }

  context 'initializes correctly' do
    context 'with pipe character' do
      let(:command) { '|git log --oneline' }
      it { expect(pipe.command).to eq('git log --oneline') }
    end

    context 'without pipe character' do
      let(:command) { 'stat something else' }
      it { expect(pipe.command).to eq('stat something else') }
    end
  end

  context '#empty?' do
    before { allow(pipe).to receive(:lines) { lines } }

    context 'with empty lines' do
      let(:lines) { [] }
      it { expect(pipe).to be_empty }
    end

    context 'with a single line' do
      let(:lines) { [double] }
      it { expect(pipe).to_not be_empty }
    end
  end

  context '#each' do
    before do
      allow(pipe).to receive(:lines) { [line, line] }
    end

    it 'should delegate to the lines' do
      expect(line).to receive(:call).twice
      pipe.each(&:call)
    end
  end

  context '#lines' do
    before do
      expect(line).to receive(:strip).twice.and_return('')
      allow(pipe).to receive(:io) { [line, line] }
    end

    it { pipe.lines }
  end

  context '#io' do
    it 'should call #open and pass the command through' do
      expect(pipe).to receive(:open).with(/\A|#{command}/)
      pipe.io
    end

    it { expect(pipe.io).to be_an(IO) }
  end
end

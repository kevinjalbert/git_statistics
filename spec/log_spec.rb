require 'spec_helper'

include GitStatistics

describe Log do
  let(:log) { Class.new(Log) }

  context 'initializes instance' do
    it 'acts as singleton' do
      expect(log.instance).to eq(log.instance)
    end

    it 'has a logger' do
      expect(log.instance.logger).to be_a(Logger)
    end

    it 'is a Log (FakeLog)' do
      expect(log.class).to eq(Log.class)
    end

    it 'reacts to Logger methods' do
      Logger.public_instance_methods.each do |method|
        expect(log.valid_method?(method)).to be true
      end
    end
  end

  context '#use_debug' do
    it "logger's progname before" do
      expect(log.progname).to be nil
    end

    it "logger's progname after" do
      log.use_debug
      expect(log.progname).to_not be nil
    end
  end

  context '#parse_caller' do
    context 'with nothing' do
      it { expect(log.parse_caller(nil)).to be nil }
    end

    context 'with jumble (random text)' do
      it { expect(log.parse_caller('asdaacsdc')).to be nil }
    end

    context 'with valid caller' do
      it { expect(log.parse_caller("git_statistics/lib/git_statistics/log.rb:45:in `respond_to_missing?'")).to eq('git_statistics/lib/git_statistics/log.rb:45') }
    end
  end
end

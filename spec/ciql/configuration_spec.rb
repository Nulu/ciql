require 'spec_helper'

module Ciql
  describe '.client' do
    let(:reactor) { FakeReactor.new }

    before(:each) do
      Cql::Io::IoReactor.stub(:new).and_return(reactor)
    end

    after(:each) do
      Ciql.class_variable_set(:@@client, nil)
      Ciql.class_variable_set(:@@configuration, nil)
    end

    it 'returns a Client instance' do
      Ciql.client.should be_instance_of Ciql::Client::SynchronousClient
    end

    it 'always returns the same Client instance' do
      Ciql.client.should be Ciql.client
    end

    it 'creates the client with the configured options' do
      Ciql.configure { |c| c.port = 1234 }
      Ciql::Client::AsynchronousClient.should_receive(:new).with(port: 1234).and_call_original
      Ciql.client
    end

    it 'connects the client' do
      Ciql.client.should be_connected
    end
  end

  describe '.configuration' do
    after(:each) do
      Ciql.class_variable_set(:@@configuration, nil)
    end

    it 'returns a Configuration instance' do
      Ciql.configuration.should be_instance_of Ciql::Configuration
    end

    it 'always returns the same Configuration instance' do
      Ciql.configuration.should be Ciql.configuration
    end
  end

  describe '.configure' do
    it 'yields the Configuration instance returned by .configuration' do
      Ciql.configure do |c|
        c.should be Ciql.configuration
      end
    end
  end

  describe Configuration do
    it 'supports property access via #name' do
      subject.port = 5
      subject.port.should == 5
    end

    it '#hosts is an array' do
      subject.hosts << 'remote'
      subject.hosts.should == ['remote']
    end

    describe '#to_options' do
      it 'returns a Hash with the configured options as keys' do
        subject.foo = 1
        subject.bar = 'a'
        subject.to_options.should == {foo: 1, bar: 'a'}
      end

      it 'sets #host with comma-separated string of #hosts entries' do
        subject.hosts << 'local'
        subject.hosts << 'remote'
        subject.to_options[:host].should == 'local,remote'
      end

      it 'combines #host and #hosts into #host' do
        subject.host = 'primary'
        subject.hosts << 'secondary'
        subject.to_options[:host].should == 'primary,secondary'
      end

      it 'does not include an entry for :hosts' do
        subject.to_options[:hosts].should be_nil
      end

      it 'clears #hosts' do
        subject.hosts << 'one'
        subject.to_options
        subject.hosts.should be_empty
      end

      it 'ignores nil values and empty strings' do
        subject.hosts << nil
        subject.hosts << ''
        subject.hosts << 'server'
        subject.to_options[:host].should == 'server'
      end

      it 'does not change #host if #hosts is empty' do
        subject.to_options[:host].should == nil
        subject.host = 'local'
        subject.to_options[:host].should == 'local'
      end
    end
  end
end

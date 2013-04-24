require 'spec_helper'

module Ciql
  describe '.client' do
    after(:each) do
      Ciql.class_variable_set(:@@client, nil)
    end

    let(:reactor) { FakeReactor.new }

    before(:each) do
      Cql::Io::IoReactor.stub(:new).and_return(reactor)
    end

    it 'defaults to nil' do
      Ciql.client.should be_nil
    end

    it 'returns a client after it is configured' do
      Ciql.configure {}
      Ciql.client.should be_instance_of Ciql::Client
    end

    it 'starts the client when first requested' do
      client = Ciql.configure {}
      client.should_receive(:connect)
      Ciql.client
    end

    it 'does not try to start the client on subsequent requests' do
      client = Ciql.configure {}
      Ciql.client
      client.should_not_receive(:close)
      Ciql.client
    end
  end

  describe '.configure' do
    after(:each) do
      Ciql.class_variable_set(:@@client, nil)
    end

    it 'yields a Configuration instance' do
      Ciql.configure do |c|
        c.should be_instance_of Ciql::Configuration
      end
    end

    it 'uses the Configuration instance to initialize the Client' do
      Ciql::Client.should_receive(:new).with({foo: 42})
      Ciql.configure { |config| config.foo = 42 }
    end

    it 'shutdowns the current client, if present' do
      client = Ciql.configure {}
      client.should_receive(:close)
      Ciql.configure {}
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

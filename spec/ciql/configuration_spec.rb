require 'spec_helper'

module Ciql
  describe '.client' do
    it 'defaults to nil' do
      Ciql.client.should be_nil
    end

    it 'returns a client after it is configured' do
      Ciql.configure {}
      Ciql.client.should be_instance_of Ciql::Client
    end
  end

  describe '.configure' do
    it 'yields a Configuration instance' do
      Ciql.configure do |c|
        c.should be_instance_of Ciql::Configuration
      end
    end

    it 'calls #to_options on the Configuration after yielding' do
      config = Ciql::Configuration.new
      Ciql::Configuration.stub!(:new).and_return(config)
      Ciql.configure do |c|
        config.should_receive(:to_options).and_return(config)
      end
    end

    it 'uses the Configuration instance to initialize the Client' do
      config = Ciql::Configuration.new
      Ciql::Configuration.should_receive(:new).and_return(config)
      Ciql::Client.should_receive(:new).with(config)
      Ciql.configure {}
    end
  end

  describe Configuration do
    it 'supports property access via #name, ["name"], and [:name]' do
      subject.port = 5
      subject.port.should == 5
      subject.port.should == subject['port']
      subject.port.should == subject[:port]
    end

    it '#hosts is an array' do
      subject.hosts << 'remote'
      subject.hosts.should == ['remote']
    end

    describe '#to_options' do
      it 'sets #host with comma-separated string of #hosts entries' do
        subject.hosts << 'local'
        subject.hosts << 'remote'
        subject.to_options.host.should == 'local,remote'
      end

      it 'combines #host and #hosts into #host' do
        subject.host = 'primary'
        subject.hosts << 'secondary'
        subject.to_options.host.should == 'primary,secondary'
      end

      it 'clears #hosts' do
        subject.hosts << 'one'
        subject.to_options.hosts.should be_empty
      end

      it 'ignores nil values and empty strings' do
        subject.hosts << nil
        subject.hosts << ''
        subject.hosts << 'server'
        subject.to_options.host.should == 'server'
      end

      it 'does not change #host if #hosts is empty' do
        subject.to_options.host.should == nil
        subject.host = 'local'
        subject.to_options.host.should == 'local'
      end
    end
  end
end

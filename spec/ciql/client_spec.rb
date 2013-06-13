require 'spec_helper'

module Ciql::Client
  describe AsynchronousClient do
    let(:client) { described_class.new }

    describe '#execute' do
      before do
        client.instance_variable_set(:@connected, true)
        client.stub(:execute_request) do |request|
          Cql::Future.completed(request)
        end
      end

      it 'returns a Cql::Future' do
        client.execute('x').should be_kind_of Cql::Future
      end

      it 'binds query parameters' do
        client.execute('a = ? and b = ?', "a'b", [1,2].pack('C*'))
          .get.cql.should == "a = 'a''b' and b = 0x0102"
      end

      it 'uses an extra trailing argument as the consistency level' do
        client.execute('update', :any).get.consistency.should == :any
        client.execute('update ?', :any).get.consistency.should == :quorum
        client.execute('update ?', :any, :one).get.consistency.should == :one
      end
    end
  end

  describe SynchronousClient do
    let(:async_client) { mock('async client') }
    let(:client) { described_class.new(async_client) }

    describe '#execute' do
      before do
        async_client.should_receive(:execute) do |*arguments|
          Cql::Future.completed(arguments)
        end
      end

      it "returns the value of the async client's #execute result" do
        client.execute('??', 'a', 'b', :two).should == ['??', 'a', 'b', :two]
      end
    end
  end

  describe '.connect' do
    let(:reactor) { FakeReactor.new }

    before(:each) do
      Cql::Io::IoReactor.stub(:new).and_return(reactor)
    end

    subject { Ciql::Client.connect(port: 4000) }

    it 'returns a SynchronousClient' do
      subject.should be_instance_of Ciql::Client::SynchronousClient
    end

    it 'passes the options to the internal async client' do
      subject.async.instance_variable_get(:@port).should == 4000
    end
  end
end

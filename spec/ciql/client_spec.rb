require 'spec_helper'

module Ciql
  describe Client do
    let(:client) { described_class.new }

    describe '#execute' do
      before(:each) do
        client.instance_variable_set(:@started, true)
        client.stub(:execute_request) do |request|
          Cql::Future.completed(request)
        end
      end

      it 'binds query parameters' do
        client.execute('a = ? and b = ?', "a'b", [1,2].pack('C*'))
          .cql.should == "a = 'a''b' and b = 0x0102"
      end

      it 'uses an extra trailing argument as the consistency level' do
        client.execute('update', :any).consistency.should == :any
        client.execute('update ?', :any).consistency.should == :quorum
        client.execute('update ?', :any, :one).consistency.should == :one
      end
    end
  end
end

require 'spec_helper'
require 'ciql/client/thrift'

module Ciql::Client
  describe Thrift do
    let(:logger) { double(:debug? => true, debug: nil) }

    subject { described_class.new(log: logger) }

    before do
      Ciql.logger = logger
    end

    it 'inherits from CassandraCQL::Database' do
      subject.should be_kind_of CassandraCQL::Database
    end

    it 'defaults to two retries on connection exceptions' do
      subject.instance_variable_get(:@thrift_client_options)[:retries].should eq 2
    end

    it 'accepts :retries as an option' do
      instance = described_class.new(log: logger, retries: 5)
      instance.instance_variable_get(:@thrift_client_options)[:retries].should eq 5
    end

    describe '#execute' do
      it 'logs the query' do
        subject # instantiate
        logger.should_receive(:debug).with(/system.local where key = 'local' \[ONE\]/)
        subject.execute('select * from system.local where key = ?', :local, :one)
      end
    end
  end
end

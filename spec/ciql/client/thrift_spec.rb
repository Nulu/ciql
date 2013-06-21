require 'spec_helper'

module Ciql::Client
  describe Thrift do
    let(:logger) { mock(:debug? => true, :debug => nil) }

    subject { described_class.new(log: logger) }

    it 'inherits from CassandraCQL::Database' do
      subject.should be_kind_of CassandraCQL::Database
    end

    describe '#execute' do
      it 'logs the query' do
        subject # instantiate
        logger.should_receive(:debug).with(/system.local where key = 'local' \(ONE\)/)
        subject.execute('select * from system.local where key = ?', :local, :one)
      end
    end
  end
end

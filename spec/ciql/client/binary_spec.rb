require 'spec_helper'

module Ciql::Client
  describe Binary do
    let(:logger) do
      double(:debug? => true, debug: nil, info: nil, warn: nil)
    end

    subject { described_class.new(log: logger) }

    before do
     Ciql.logger = logger
    end

    describe '#execute' do
      it 'logs the query' do
        subject # instantiate
        logger.should_receive(:debug).with(/system.local where key = 'local' \[ONE\]/)
        subject.execute('select * from system.local where key = ?', :local, :one)
      end
    end

    describe '#disconnect!' do
      it 'closes the connection' do
        subject.disconnect!
        subject.connection.should_not be_connected
      end
    end
  end
end

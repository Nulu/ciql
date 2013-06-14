require 'spec_helper'

module Ciql::Client
  describe Thrift do
    subject { described_class.new }

    it 'inherits from CassandraCQL::Database' do
      subject.should be_kind_of CassandraCQL::Database
    end
  end
end

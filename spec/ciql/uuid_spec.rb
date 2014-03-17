require 'spec_helper'

describe Ciql::UUID do
  let(:time) { Time.parse('2014-3-17 9:45:12.123456 PST') }

  describe '.starting' do
    subject { described_class.starting(time) }

    it 'returns the expected UUID for a starting time' do
      subject.to_guid.should eq 'e3c8da80-adfb-11e3-3932-353935343231'
    end

    it 'encodes the time correctly' do
      subject.to_time.should eq time
    end
  end

  describe '.ending' do
    subject { described_class.ending(time) }

    it 'returns the expected UUID for an ending time' do
      subject.to_guid.should eq 'e3c8da89-adfb-11e3-3931-383732303139'
    end

    it 'encodes the time correctly' do
      subject.to_time.should eq time
    end
  end
end

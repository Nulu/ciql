require 'spec_helper'

module Ciql
  describe Sanitize do
    describe 'when there are no placeholders in the statement' do
      before do
        @statement = 'select * from table'
      end

      describe 'and no variables are given' do
        it 'returns the statement as-is' do
          subject.sanitize(@statement).should == @statement
        end
      end

      describe 'and one or more variables are given' do
        it 'throws InvalidBindVariableError' do
          expect {
            subject.sanitize(@statement, 1, 2)
          }.to raise_error(subject::InvalidBindVariableError)
        end
      end
    end

    describe 'when there are placeholders in the query' do
      describe 'and too few variables are given' do
        it 'throws InvalidBindVariableError' do
          expect {
            subject.sanitize('?')
          }.to raise_error(subject::InvalidBindVariableError)

          expect {
            subject.sanitize('? ?', 1)
          }.to raise_error(subject::InvalidBindVariableError)
        end
      end

      describe 'and too many variables are given' do
        it 'throws InvalidBindVariableError' do
          expect {
            subject.sanitize('? ?', 1, 2, 3)
          }.to raise_error(subject::InvalidBindVariableError)
        end
      end

      it 'replaces placeholders with the correct variable' do
        subject.sanitize('? ?', 1, 2.1).should == '1 2.1'
      end

      it 'converts nil to NULL' do
        subject.sanitize('?', nil).should == 'NULL'
      end

      it 'quotes strings' do
        subject.sanitize('?', 'string').should == "'string'"
      end

      it 'escapes single quotes' do
        subject.sanitize('?', "a'b").should == "'a''b'"
      end

      it 'converts dates' do
        subject.sanitize('?', Date.new(2013, 3, 26))
          .should == "'2013-03-26'"
      end

      it 'converts times' do
        subject.sanitize('?', Time.new(2013, 3, 26, 23, 1, 2.123, 0))
          .should == 1364338862123.to_s
      end

      it 'converts DateTime instances as a time' do
        subject.sanitize('?', DateTime.new(2013, 3, 26, 23, 1, 2.123, 0))
          .should == 1364338862123.to_s
      end

      it 'converts SimpleUUID::UUID to a bare string representation' do
        subject.sanitize('?', SimpleUUID::UUID.new(2**127 - 1))
          .should == "7fffffff-ffff-ffff-ffff-ffffffffffff"
      end

      it 'converts binary strings into a hex blob' do
        subject.sanitize('?', [1,2,3,4].pack('C*'))
          .should == "0x01020304"
      end

      it 'converts TrueClass instances to true, without quotes' do
        subject.sanitize('?', true).should == 'true'
      end

      it 'converts FalseClass instances to false, without quotes' do
        subject.sanitize('?', false).should == 'false'
      end

      it 'joins casted elements of an array with a comma separator wrapped in []' do
        subject.sanitize('?', [1,true,Time.at(0).to_date])
          .should == "[1,true,'1969-12-31']"
      end

      it 'joins casted elements of a set with a comma separator wrapped in {}' do
        subject.sanitize('?', [1,nil,'a'].to_set).should == "{1,NULL,'a'}"
      end

      it 'joins casted key/value pairs of a hash with colon and comma separators wrapped in {}' do
        subject.sanitize('?', {a: 1, b: 'z'}).should == "{'a':1,'b':'z'}"
      end
    end
  end
end

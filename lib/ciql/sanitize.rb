require 'simple_uuid'
require 'set'

module Ciql
  module Sanitize

    class UnescapableObjectError < Ciql::Error; end
    class InvalidBindVariableError < Ciql::Error; end

    def self.sanitize(statement, *variables)
      variables = variables.dup
      expected = statement.count('?')

      if expected != variables.size
        raise InvalidBindVariableError,
          "Wrong number of bound variables "\
          "(statement expected #{expected}, "\
          "was #{variables.size})"
      end

      statement.gsub(/\?/) { cast(variables.shift) }
    end

    private

    def self.quote(string)
      "'" + string.gsub("'", "''") + "'"
    end

    def self.cast(obj)
      case obj
      when Hash
        "{#{obj.map { |pair| pair.map(&method(:cast)).join(':') }.join(',')}}"

      when Set
        "{#{obj.map { |member| cast(member) }.join(',')}}"

      when Enumerable
        "[#{obj.map { |member| cast(member) }.join(',')}]"

      when NilClass       then 'NULL'
      when Numeric        then obj
      when DateTime, Time then obj.strftime('%s%3N').to_i
      when Date           then quote(obj.strftime('%Y-%m-%d'))

      when ::SimpleUUID::UUID then obj.to_guid

      when String
        if obj.encoding == ::Encoding::BINARY
          '0x' + obj.unpack('H*').first
        else
          quote obj.encode(::Encoding::UTF_8)
        end

      when TrueClass, FalseClass
        obj.to_s

      else
        quote obj.to_s.dup.force_encoding(::Encoding::BINARY)
      end
    end
  end
end

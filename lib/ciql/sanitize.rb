require 'simple_uuid'

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
        obj.map do |key, value|
          [cast(key), cast(value)].join(':')
        end.join(',')

      when Enumerable
        obj.map { |member| cast(member) }.join(',')

      when Numeric; obj
      when Date;    quote(obj.strftime('%Y-%m-%d'))
      when Time;    (obj.to_f * 1000).to_i

      when ::Cql::Uuid;        obj.to_s
      when ::SimpleUUID::UUID; obj.to_guid

      when String
        if obj.encoding == ::Encoding::BINARY
          '0x' + obj.unpack('H*').first
        else
          quote obj.encode(::Encoding::UTF_8)
        end

      else
        quote obj.to_s.dup.force_encoding(::Encoding::BINARY)
      end
    end
  end
end

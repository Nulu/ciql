require 'cql'
require 'benchmark'

require 'ciql/client/log'

module Ciql::Client
  class Binary
    include Log

    attr_reader :connection

    def initialize(options={})
      options     = options.dup
      @log_format = options.delete(:log_format)

      options[:hosts]  = options.delete(:host) { '127.0.0.1' }.split(',')
      options[:logger] = Ciql.logger

      @connection = Cql::Client.connect(options)
    end

    def execute(statement, *arguments)
      bind_variables    = arguments.shift statement.count('?')
      bound_statement   = Ciql::Sanitize.sanitize(statement, *bind_variables)
      consistency_level = arguments.shift or :quorum

      result = nil
      times = Benchmark.measure do
        result = @connection.execute(
          bound_statement,
          consistency: consistency_level
        )
      end

      log(
        duration:    times.real * 10**3,
        query:       bound_statement,
        consistency: consistency_level.to_s.upcase
      )

      result
    end

    def disconnect!
      @connection.close
    end
  end
end

require 'cql'
require 'benchmark'

require 'ciql/client/log'

module Ciql::Client
  class Binary
    include Log

    def initialize(options={})
      @options = {
        logger:               Ciql.logger,
        connections_per_node: 2,
      }.merge(options)
      @log_format = @options.delete(:log_format)
      @options[:hosts] = @options.delete(:host) { '127.0.0.1' }.split(',')
    end

    def connection
      @connection ||= Cql::Client.connect(@options)
    end

    def execute(statement, *arguments)
      bind_variables    = arguments.shift statement.count('?')
      bound_statement   = Ciql::Sanitize.sanitize(statement, *bind_variables)
      consistency_level = arguments.shift or :quorum

      result = nil
      times = Benchmark.measure do
        result = connection.execute(
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
      connection.close
    end
  end
end

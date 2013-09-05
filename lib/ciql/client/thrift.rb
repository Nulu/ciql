require 'cassandra-cql/1.2'
require 'cassandra-cql'
require 'benchmark'

require 'ciql/client/log'

module Ciql::Client
  class Thrift < CassandraCQL::Database
    include Log

    def initialize(options={})
      options = options.dup
      @log_format = options.delete(:log_format)

      port = options.delete(:port) { 9160 }
      hosts = options.delete(:host) { '127.0.0.1' }.split(',')
      hosts_with_port = hosts.map { |host| [host, port].join(':') }
      retries = options.delete(:retries) { 2 }
      super(hosts_with_port, options, retries: retries)
    end

    def execute(statement, *arguments)
      bind_variables = arguments.shift statement.count('?')
      bound_statement = Ciql::Sanitize.sanitize(statement, *bind_variables)
      compression_type = CassandraCQL::Thrift::Compression::NONE
      consistency_level = (arguments.shift or :quorum).to_s.upcase

      result = nil
      times = Benchmark.measure do
        result = CassandraCQL::Result.new(
          @connection.execute_cql3_query(
            bound_statement, compression_type,
            CassandraCQL::Thrift::ConsistencyLevel.const_get(consistency_level)
          )
        )
      end

      log(
        duration:    times.real * 10**3,
        query:       bound_statement,
        compression: compression_type,
        consistency: consistency_level
      )

      result

    rescue CassandraCQL::Thrift::InvalidRequestException
      message = [$!.why, bound_statement].join(' -- ')
      raise CassandraCQL::Error::InvalidRequestException.new(message)
    end
  end
end

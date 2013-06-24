require 'cassandra-cql/1.2'
require 'cassandra-cql'
require 'benchmark'

module Ciql::Client
  class Thrift < CassandraCQL::Database
    def initialize(options={})
      @logger = options.delete(:log) || Logger.new($stdout)
      @log_format = options.delete(:log_format) || DEFAULT_LOG_FORMAT

      port = options.delete(:port) { 9160 }
      hosts = options.delete(:host) { '127.0.0.1' }.split(',')
      hosts_with_port = hosts.map { |host| [host, port].join(':') }
      super(hosts_with_port, options)
    end

    def execute(statement, *arguments)
      bind_variables = arguments.shift statement.count('?')
      bound_statement = Ciql::Sanitize.sanitize(statement, *bind_variables)
      compression_type = CassandraCQL::Thrift::Compression::NONE
      consistency_level = (arguments.shift or :local_quorum).to_s.upcase

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
      raise CassandraCQL::Error::InvalidRequestException.new($!.why)
    end

  private
    DEFAULT_LOG_FORMAT = '  CQL (%<duration>.3fms)  %{query} (%{consistency})'.freeze

    def log(message)
      return unless @logger.debug?
      @logger.debug(@log_format % message)
    end
  end
end

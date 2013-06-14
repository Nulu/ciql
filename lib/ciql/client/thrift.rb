require 'cassandra-cql/1.2'
require 'cassandra-cql'

module Ciql::Client
  class Thrift < CassandraCQL::Database
    def initialize(options={})
      port = options.delete(:port) { 9160 }
      hosts = options.delete(:host) { '127.0.0.1' }.split(',')
      hosts_with_port = hosts.map { |host| [host, port].join(':') }
      super(hosts_with_port, options)
    end

    def execute(statement, *arguments)
      bind_variables = arguments.shift statement.count('?')
      bound_statement = Ciql::Sanitize.sanitize(statement, *bind_variables)
      compression_type = CassandraCQL::Thrift::Compression::NONE
      consistency_level = CassandraCQL::Thrift::ConsistencyLevel.const_get(
        (arguments.shift or :quorum).to_s.upcase
      )

      CassandraCQL::Result.new(
        @connection.execute_cql3_query(
          bound_statement, compression_type, consistency_level
        )
      )
    rescue CassandraCQL::Thrift::InvalidRequestException
      raise CassandraCQL::Error::InvalidRequestException.new($!.why)
    end
  end
end

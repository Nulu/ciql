module Ciql
  module Client
    class AsynchronousClient < Cql::Client::AsynchronousClient
      def execute(statement, *arguments)
        bind_variables = arguments.shift statement.count('?')
        bound_statement = Ciql::Sanitize.sanitize statement, *bind_variables
        super(bound_statement, *arguments)
      end
    end

    class SynchronousClient < Cql::Client::SynchronousClient
      def execute(statement, *arguments)
        @async_client.execute(statement, *arguments).get
      end
    end

    def self.connect(options={})
      SynchronousClient.new(AsynchronousClient.new(options)).connect
    end
  end
end

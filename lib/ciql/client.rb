module Ciql
  class Client < Cql::Client
    def execute(statement, *arguments)
      bind_variables = arguments.shift statement.count('?')
      bound_statement = Ciql::Sanitize.sanitize statement, *bind_variables
      super(bound_statement, *arguments)
    end
  end
end

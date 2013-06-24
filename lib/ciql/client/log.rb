module Ciql::Client
  module Log
    DEFAULT_LOG_FORMAT = 'CQL %{query} [%{consistency}] (%<duration>.3fms) '.freeze

    def log(message)
      return unless Ciql.logger.debug?
      Ciql.logger.debug (@log_format or DEFAULT_LOG_FORMAT) % message
    end
  end
end

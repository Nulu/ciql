module Ciql
  class Railtie < Rails::Railtie
    initializer 'ciql.logger', after: 'data_mapper.logger' do
      Ciql.logger = DataMapper.logger
    end
  end

  module LogListener
    def log(message)
      ActiveSupport::Notifications.instrument('sql.data_mapper',
        :name          => 'CQL',
        :sql           => '%{query} [%{consistency}]' % message,
        :duration      => message[:duration]
      )
    rescue Exception => e
      Ciql.logger.error "[ciql] #{e.class.name}: #{e.message}: #{message.inspect}}"
    end
  end

  Client::Thrift.send(:include, LogListener)
end

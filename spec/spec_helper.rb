require 'bundler/setup'
require 'simplecov'; SimpleCov.start
require 'ciql'

class FakeReactor
  def start
    Cql::Future.completed([])
  end

  def add_connection(host, port)
    Cql::Future.completed(1)
  end

  def queue_request(request, connection_id = nil)
    Cql::Future.completed(nil)
  end

  def stop
  end
end

require 'logger'

module Ciql
  Error = Class.new(StandardError)

  def self.logger
    @logger ||= Logger.new($stdout)
  end

  def self.logger=(logger)
    @logger = logger
  end
end

require 'ciql/configuration'
require 'ciql/sanitize'
require 'ciql/uuid'
require 'ciql/client/binary'
require 'ciql/rails' if defined?(Rails)

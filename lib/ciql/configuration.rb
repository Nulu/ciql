require 'ostruct'

module Ciql
  @@client = nil
  def self.client
    @@client.start! unless @@client.nil? or @@client.connected?
    @@client
  end

  def self.configure(&block)
    @@client.shutdown! unless @@client.nil?
    yield (configuration = Configuration.new)
    @@client = Client.new(configuration.to_options)
  end

  class Configuration < OpenStruct
    def initialize
      super
      self.hosts = []
    end

    def to_options
      all = [host].concat(hosts).compact.reject(&:empty?)
      self.hosts = []
      self.host = all.join(',') unless all.empty?
      self.marshal_dump.dup.tap { |hash| hash.delete(:hosts) }
    end
  end
end

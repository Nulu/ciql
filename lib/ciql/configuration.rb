require 'ostruct'

module Ciql
  @@client = nil
  def self.client; @@client; end

  def self.configure(&block)
    @@client.shutdown! if @@client
    yield configuration = Configuration.new
    @@client = Client.new(configuration.to_options)
  end

  class Configuration < OpenStruct
    def initialize
      super
      self.hosts = []
    end

    def to_options
      all = [host].concat(hosts).compact.reject(&:empty?)
      self.host = all.join(',') unless all.empty?
      self
    end
  end
end

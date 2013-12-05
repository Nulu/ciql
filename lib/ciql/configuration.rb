require 'ostruct'

module Ciql
  @@client = nil
  def self.client
    @@client ||= Client::Binary.new(configuration.to_options)
  end

  @@configuration = nil
  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield configuration
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

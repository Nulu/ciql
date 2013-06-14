module Ciql
  Error = Class.new(StandardError)
end

require 'ciql/configuration'
require 'ciql/client/thrift'

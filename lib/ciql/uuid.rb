require 'simple_uuid'

module Ciql
  module UUID

    # Create a fake time UUID that sorts as the smallest for a timestamp
    #
    # @param [Time] time
    #
    # @return [SimpleUUID::UUID]
    def self.starting(time)
      create_uuid(time.stamp * 10, 0x8080808080808080)
    end

    # Create a fake time UUID that sorts as the largest for a timestamp
    #
    # @param [Time] time
    #
    # @return [SimpleUUID::UUID]
    def self.ending(time)
      create_uuid((time.stamp + 1) * 10 - 1, 0x7f7f7f7f7f7f7f7f)
    end

  private

    # Create a new UUID
    #
    # @param [Fixnum] time, as 0.1 us since unix epoch
    # @param [Fixnum] seq_and_node
    #
    # @return [SimpleUUID::UUID]
    def self.create_uuid(time, seq_and_node)
      time += SimpleUUID::UUID::GREGORIAN_EPOCH_OFFSET
      bytes = [
        time & 0xFFFF_FFFF,
        time >> 32,
        ((time >> 48) & 0x0FFF) | 0x1000,
        seq_and_node.to_s.unpack('NN')
      ].flatten
      SimpleUUID::UUID.new(bytes.pack('NnnNN'))
    end
  end
end

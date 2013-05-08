module RedisProtocol
  OP_DELIMITER = "\r\n"

  class << self
    def parse_request data
      components = []
      operand_length, payload = next_token data
      raise 'invalid packet' unless operand_length.start_with? '*'
      operand_length = operand_length[1..-1].to_i
      1.upto(operand_length).each do |_|
        field_length, payload = next_token payload
        raise 'invalid length format' unless field_length.start_with? '$'
        field_length = field_length[1..-1].to_i
        data, payload = next_token payload, field_length
        components << data
      end

      components
    end

    def recognize data
      data.split(OP_DELIMITER)[2]
    end

    def next_token data, length = 0
      index = length
      index = data.index OP_DELIMITER if index == 0
      current_data = data[0...index]
      raise 'invalid length' unless data[index, OP_DELIMITER.length].eql? "\r\n"
      next_data = data[(index + OP_DELIMITER.length)..-1]

      [current_data, next_data]
    end
  end
end

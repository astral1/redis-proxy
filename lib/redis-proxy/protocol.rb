module RedisProtocol
  OP_DELIMITER = "\r\n"

  class << self
    def parse_request(data)
      type = check_request_type data

      RedisProtocol.send type, data
    end

    def recognize(data)
      case check_request_type data
        when :inline
          data.split[0]
        else
          data.split(OP_DELIMITER)[2]
      end
    end

    def check_request_type(data)
      if data.count(OP_DELIMITER[0]) > 1
        :standard
      else
        :inline
      end
    end

    def standard(data)
      components = []
      operand_length, payload = operand_length_for data
      1.upto(operand_length).each do |_|
        data, payload = unpack_payload(payload)
        components << data
      end
      components
    end

    def operand_length_for(data)
      operand_length, payload = next_token data
      raise 'invalid packet' unless operand_length.start_with? '*'
      operand_length = operand_length[1..-1].to_i

      [operand_length, payload]
    end

    def unpack_payload(payload)
      field_length, payload = next_token payload
      raise 'invalid length format' unless field_length.start_with? '$'
      field_length = field_length[1..-1].to_i
      next_token payload, field_length
    end

    def inline(data)
      data.split
    end

    def next_token(data, length = 0)
      index = length
      index = data.index OP_DELIMITER if index == 0
      current_data = data[0...index]
      raise 'invalid length' unless data[index, OP_DELIMITER.length].eql? "\r\n"
      next_data = data[(index + OP_DELIMITER.length)..-1]

      [current_data, next_data]
    end

    private :next_token, :standard, :inline, :operand_length_for, :unpack_payload
  end
end

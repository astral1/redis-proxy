class RedisBackend < EM::Connection
  def initialize peer
    @peer = peer
  end

  def receive_data data
    @peer.send_data data
  end

  def unbind
    @peer.close_connection_after_writing unless @peer.nil?
  end
end

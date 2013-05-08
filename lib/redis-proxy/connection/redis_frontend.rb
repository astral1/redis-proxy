class RedisFrontend < EM::Connection
  @@front_session_count = 0

  def post_init
    @@front_session_count += 1
    puts "Concurrent User - #{@@front_session_count}"
    @backend = EM::connect('localhost', 6379, RedisBackend, self)
  end

  def receive_data data
    components = RedisProtocol.parse_request data
    @backend.send_data data
    puts RedisProtocol.recognize data
  end

  def unbind
    @@front_session_count -= 1
    puts "Concurrent User - #{@@front_session_count}"
  end
end

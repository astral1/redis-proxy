require 'redis-protocol'
class RedisFrontend < EM::Connection
  @@front_session_count = 0

  def post_init
    #EM.defer do
    #  @@front_session_count += 1
    #  puts "Concurrent User - #{@@front_session_count}"
    #end
    @backend = EM::connect('localhost', 6379, RedisBackend, self)
  end

  def receive_data(data)
    components = RedisProtocol::UnifiedProtocol.parse data
    #components = RedisProtocol::Request.new data
    @backend.send_data data
    #puts RedisProtocol.recognize data
  end

  def unbind
    @backend.close_connection_after_writing if @backend
    #EM.defer do
    #  @@front_session_count -= 1
    #  puts "Concurrent User - #{@@front_session_count}"
    #end
  end
end

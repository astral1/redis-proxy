class RedisFrontend < EM::Connection
    def post_init
        puts 'connect'
        @backend = EM::connect('localhost', 6379, RedisBackend, self)
    end

    def receive_data data
        components = RedisProtocol.parse_request data
        @backend.send_data data do |response|
            puts response
            send_data response
        end
        puts RedisProtocol.recognize data
    end

    def unbind
        puts 'disconnect'
    end
end

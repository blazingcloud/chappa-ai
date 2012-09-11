require 'thin'
class Donkey
  def call(env)
    p env

    body = ["Nasrudin is riding a donkey"]
    [
      200,
      { 'Content-Type' => 'text/plain' },
      body
    ]
  end
end

module Thin
  class Connection
    alias :thin_connection_post_init :post_init
    def post_init(*args)
      p '--before thin_connection_post_init'
      @remote_ip =  remote_address
      p @remote_ip + "connected"
      p args
      retval = thin_connection_post_init(*args)
      p '--after thin_connection_post_init'
      return  retval
    end
    alias :thin_connection_receive_data :receive_data
    def receive_data(*args)
      p '--before thin_connection_receive_data'
      p remote_address
      p args
      retval = thin_connection_receive_data(*args)
      p '--after thin_connection_receive_data'
      return  retval
    end
    alias :thin_connection_unbind :unbind
    def unbind(*args)
      p '--before thin_connection_unbind'
      p @remote_ip + "- unbound connection"
      p args
      retval = thin_connection_unbind(*args)
      p '--after thin_connection_unbind'
      return  retval
    end
  end
end

module Thin
  class Request
    alias :thin_request_parse :parse
    def parse(*args)
      p '+++before thin_request_parse'
      p args
      p @env
      retval = thin_request_parse(*args)
      p '+++after thin_request_parse'
      return retval
    end

  end
end
Thin::Server.start('0.0.0.0', 3000) do
  use Rack::CommonLogger
  map '/' do
    run Donkey.new
  end
end



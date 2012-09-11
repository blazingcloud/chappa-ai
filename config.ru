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
  class Request
    alias :thin_request_parse :parse
    def parse(*args)
      p 'before thin_request_parse'
      p args
      returnval = thin_request_parse(*args)
      p 'after thin_request_parse'
      return returnval
    end

  end
end
Thin::Server.start('0.0.0.0', 3000) do
  use Rack::CommonLogger
  map '/' do
    run Donkey.new
  end
end



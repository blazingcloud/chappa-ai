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
  class Connection < EventMachine::Connection

  end
end
Thin::Server.start('0.0.0.0', 3000) do
  use Rack::CommonLogger
  map '/' do
    run Donkey.new
  end
end



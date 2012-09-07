#encoding: UTF-8
require 'eventmachine'

 module ChappaAi

   def post_init
     p [:post_init]
     puts "Received a new connection"
     @data_received = ""
     @line_count = 0
   end
   def connection_completed #  diagnostic
     p [:connection_completed]
   end
   def receive_data data
     p [:receive_data, data]
     @data_received << data

   end
   def unbind 
     p [:unbind]
   end
 end

 EventMachine::run {
   host,port = "0.0.0.0", 9999
   EventMachine::start_server host, port, ChappaAi
   puts "Now accepting connections on address #{host}, port #{port}..."
   EventMachine::add_periodic_timer( 25 ) { $stderr.write "門" }
 }

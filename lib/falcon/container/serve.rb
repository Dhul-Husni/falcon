# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative '../server'

require 'async/container/controller'

module Falcon
	module Container
		class Serve < Async::Container::Controller
			def initialize(command, endpoint = nil, **options, &block)
				@command = command
				@block = block
				
				@endpoint = endpoint
				@bound_endpoint = nil
				@debug_trap = Async::IO::Trap.new(:USR1)
				
				super(**options)
			end
			
			def create_container
				@command.container_class.new
			end
			
			def start
				@endpoint ||= @command.endpoint
				
				@bound_endpoint = Async::Reactor.run do
					Async::IO::SharedEndpoint.bound(@endpoint)
				end.wait
				
				@debug_trap.ignore!
				
				super
			end
			
			def setup(container)
				app, _ = @block.call
				
				container.run(name: "Falcon Server", restart: true, **@command.container_options) do |task, instance|
					task.async do
						if @debug_trap.install!
							Async.logger.info(instance) do
								"- Per-process status: kill -USR1 #{Process.pid}"
							end
						end
						
						@debug_trap.trap do
							Async.logger.info(self) do |buffer|
								task.reactor.print_hierarchy(buffer)
							end
						end
					end
					
					server = Falcon::Server.new(app, @bound_endpoint, @endpoint.protocol, @endpoint.scheme)
					
					server.run
					
					task.children.each(&:wait)
				end
			end
			
			def stop(*)
				@bound_endpoint&.close
				
				@debug_trap.default!
				
				super
			end
		end
	end
end

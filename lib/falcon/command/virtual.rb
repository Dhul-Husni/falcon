# frozen_string_literal: true

# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative '../controller/virtual'
require_relative 'paths'

require 'samovar'

module Falcon
	module Command
		class Virtual < Samovar::Command
			self.description = "Run one or more virtual hosts with a front-end proxy."
			
			options do
				option '--bind-insecure <address>', "Bind redirection to the given hostname/address", default: "http://[::]:80"
				option '--bind-secure <address>', "Bind proxy to the given hostname/address", default: "https://[::]:443"
				
				option '-t/--timeout <duration>', "Specify the maximum time to wait for non-blocking operations.", type: Float, default: 30
			end
			
			many :paths
			
			include Paths
			
			def controller
				Controller::Virtual.new(self)
			end
			
			def bind_secure
				@options[:bind_secure]
			end
			
			def bind_insecure
				@options[:bind_insecure]
			end
			
			def timeout
				@options[:timeout]
			end
			
			def call
				Async.logger.info(self) do |buffer|
					buffer.puts "Falcon Virtual v#{VERSION} taking flight!"
					buffer.puts "- To terminate: Ctrl-C or kill #{Process.pid}"
					buffer.puts "- To reload all sites: kill -HUP #{Process.pid}"
				end
				
				self.controller.run
			end
			
			def insecure_endpoint(**options)
				Async::HTTP::Endpoint.parse(@options[:bind_insecure], **options)
			end
			
			def secure_endpoint(**options)
				Async::HTTP::Endpoint.parse(@options[:bind_secure], **options)
			end
			
			# An endpoint suitable for connecting to the specified hostname.
			def host_endpoint(hostname, **options)
				endpoint = secure_endpoint(**options)
				
				url = URI.parse(@options[:bind_secure])
				url.hostname = hostname
				
				return Async::HTTP::Endpoint.new(url, hostname: endpoint.hostname)
			end
		end
	end
end

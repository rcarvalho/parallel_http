require 'iconv'
require 'eventmachine'
require 'em-http-request'
require 'fiber'

class ParallelHttp
	def self.exec requests
		results = []
		if EM.reactor_running?
			results = [{:error => "Have not tested this with an eventmachine reactor that is already running.  Might have to change the code around a bit... I have an EM.stop in there and I know that would be bad if I shut down your reactor."}]
		else
			EM.run do
				results = exec_inner(requests)
			end
		end
		results
	end

	def self.exec_inner requests
		results = []
		request_size = requests.size
		requests.each do |request|
			Fiber.new do
				result = self.single(request)
				ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
				body = ic.iconv(result.response)
				results << {id: request[:id], response_code: result.response_header.status, body: body}
				EM.stop if request_size == results.size
			end.resume
		end
		results
	end

	def self.single request
		f = Fiber.current
		# puts "making a request #{request[:url]}, #{request[:verb]}, #{request[:options]}"
		http = EventMachine::HttpRequest.new(request[:url]).send(request[:verb].downcase, request[:options] || {})
		http.callback { f.resume(http) }
		http.errback { f.resume(http) }
		result = Fiber.yield
		result
	end
end
require 'eventmachine'
require 'em-http-request'

class ParallelHttp
	def self.exec requests
		@@results = []
		@@request_size = requests.size
		if EM.reactor_running?
			@@results = [{:error => "Have not tested this with an eventmachine reactor that is already running.  Might have to change the code around a bit... I have an EM.stop in there and I know that would be bad if I shut down your reactor."}]
		else
			EM.run do
				requests.each do |request|
					result = self.single(request)
				end
			end
		end
		@@results
	end

	def self.exec_result id, result
		body = result.response.encode('utf-8')
		@@results << {:id => id, :response_code => result.response_header.status, :body => body}
		EM.stop if @@request_size == @@results.size
	end

	def self.single request
		# puts "making a request #{request[:url]}, #{request[:verb]}, #{request[:options]}"
		http = EventMachine::HttpRequest.new(request[:url]).send(request[:verb].downcase, request[:options] || {})
		http.callback do
			self.exec_result(request[:id], http)
		end
		http.errback do
			self.exec_result(request[:id], http)
		end
	end
end
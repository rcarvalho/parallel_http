require 'eventmachine'
require 'em-http-request'
require 'iconv' if RUBY_VERSION.to_f < 1.9

class ParallelHttp
	@@verbose = false
	def self.verbose!
		@@verbose = true
	end
	
	def self.exec requests, options={}
		@@results = []
		@@request_size = requests.size
		if EM.reactor_running?
			@@results = [{:error => "Have not tested this with an eventmachine reactor that is already running.  Might have to change the code around a bit... I have an EM.stop in there and I know that would be bad if I shut down your reactor."}]
		else
			EM.run do
				requests.each do |request|
					ParallelHttp.single(request, options)
				end
			end
		end
		@@results
	end

	def self.exec_result id, result, error=nil
		body = ''
		if RUBY_VERSION.to_f < 1.9
			body = Iconv.iconv('UTF-8//IGNORE', 'UTF-8',  result.response).first
		else
			body = result.response.force_encoding('UTF-8').encode('UTF-16', :invalid => :replace, :replace => '').encode('UTF-8')
		end
		hsh = {:id => id, :response_code => result.response_header.status, :body => body}
		hsh.merge!(:error => error) if error
		@@results << hsh
		if @@request_size == @@results.size
			EM.stop 
		end
	end

	def self.single request, options

		puts "making a request #{request[:url]}, #{request[:verb]}, #{request[:options]}" if @@verbose
		opts = request[:options] || {}
		http = EventMachine::HttpRequest.new(request[:url], options).send(request[:verb].downcase, opts)
		http.callback do
			puts "SUCCESS: #{request[:id]}" if @@verbose
			@@success = request[:id]
			ParallelHttp.exec_result(request[:id], http)
			http.close(nil)
		end
		http.errback do |h|
			if @@success != request[:id]
				puts "FAILURE: #{request[:id]}" if @@verbose
				ParallelHttp.exec_result(request[:id], h, h.error)
				http.close(nil)
			end
		end
	end
end
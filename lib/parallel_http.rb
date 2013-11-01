# encoding: UTF-8
require 'eventmachine'
require 'em-http-request'
require 'iconv' if RUBY_VERSION.to_f < 1.9

class ParallelHttp
	@@verbose = false
	@@results = []
	@@reactor_running = EM.reactor_running?
	def self.verbose!
		@@verbose = true
	end
	
	def self.exec requests, options={}
		@@results = []
		@@request_size = requests.size
		if @@reactor_running
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

	def self.add requests, options={}
		requests.each do |request|
			ParallelHttp.single(request, options)
		end		
	end

	def self.results
		@@results
	end

	def self.exec_result id, url, result, error=nil
		body = ''
		if RUBY_VERSION.to_f < 1.9
			body = Iconv.iconv('UTF-8//IGNORE', 'UTF-8',  result.response).first
		else
			body = result.response.force_encoding('UTF-8').encode('UTF-16', :invalid => :replace, :replace => '').encode('UTF-8')
		end
		hsh = {:id => id, :url => result.last_effective_url.to_s, :response_code => result.response_header.status, :body => body}
		hsh.merge!(:error => error) if error
		@@results << hsh
		if @@request_size == @@results.size && !@@reactor_running
			EM.stop 
		end
	end

	def self.single request, options
		puts "making a request #{request[:url]}, #{request[:verb]}, #{request[:options]}" if @@verbose
		opts = request[:options] || {}
		opts[:head] ||= {}
		opts[:head].merge!({"Accept-Encoding" => "gzip, compressed"})
		http = EventMachine::HttpRequest.new(request[:url], options).send(request[:verb].downcase, opts)
		http.callback do
			puts "SUCCESS: #{request[:id]}" if @@verbose
			ParallelHttp.exec_result(request[:id], request[:url], http)
		end
		http.errback do |h|
			puts "FAILURE: #{request[:id]}" if @@verbose
			ParallelHttp.exec_result(request[:id], request[:url], h, h.error)
		end
	end
end
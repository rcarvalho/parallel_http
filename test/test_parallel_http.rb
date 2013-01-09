require 'test/unit'
require 'parallel_http'

class ParallelHttpTest < Test::Unit::TestCase
	def test_some_requests
		user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_0) AppleWebKit/536.3 (KHTML, like Gecko) Chrome/19.0.1063.0 Safari/536.3"
		options = {head: {"User-Agent" => user_agent}, redirects: 3}
		requests = [{id: 1, verb: 'get', url: 'http://google.com', options: options},{id: 2, verb: 'get', url: 'http://yahoo.com', options: options},{id: 3, verb: 'get', url: 'http://bing.com', options: options}]
		puts "making #{requests.size} requests"
		results = ParallelHttp.exec(requests)
		results.each do |result|
			assert_equal 200, result[:response_code]
		end
		puts "getting #{results.size} responses"
		assert_equal 3, results.size
	end
end
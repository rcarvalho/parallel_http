************************ 
parallel_http GEM
************************

This gem allows one to make parallel http requests in their Ruby application.

Currently, this is meant for applications that do not use eventmachine.  The gem
itself uses eventmachine, but basically starts and kills an eventmachine event
loop during the course of a single request/response.

To use check out the test or see the example below:

	user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_0) AppleWebKit/536.3 (KHTML, like Gecko) Chrome/19.0.1063.0 Safari/536.3"
	options = {:head => {"User-Agent" => user_agent}, :redirects => 3}
	requests = [{:id => 1, :verb => 'get', :url => 'http://google.com', :options => options},
				  		{:id => 2, :verb => 'get', :url => 'http://yahoo.com', :options => options},
				  		{:id => 3, :verb => 'get', :url => 'http://bing.com', :options => options}]
	opts = {:connect_timeout => 5000, :inactivity_timeout => 0}
	# connection_timeout and activity_timeout are in seconds.  
	# 0 for activity timeout disables it.
	results = ParallelHttp.exec(requests, opts)

Because we are using em-http-request and basically forwarding the arguments to this library, please see the following doc for more information about what is possible for :options => https://github.com/igrigorik/em-http-request/wiki/Issuing-Requests

Add the following to your options hash if you want to include parameters to your GET or POST

Query options for GETs
	{:query => {:param1 => 'blah', :param2 => 'blah blah'}}

Body options for POSTs
	{:body => {:param1 => 'blah', :param2 => 'blah blah'}}

*************
HELP
*************

Currently, I've only tested this with GET and POST, though it should theoretically work for all of the verbs.  If you want to write a test for any of these other verbs or if you would like to modify the code so it works with an existing eventmachine reactor feel free and send me a pull request.  I will review and integrate.
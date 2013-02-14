Gem::Specification.new do |s|
  s.name        = 'parallel_http'
  s.version     = '0.0.9'
  s.date        = '2013-02-14'
  s.summary     = "Parallel HTTP calls"
  s.description = "Make parallel http calls using EventMachine under the hood"
  s.authors     = ["Rodney Carvalho"]
  s.email       = 'rcarvalho@atlantistech.com'
  s.files       = ["lib/parallel_http.rb"]
  s.homepage    = 'http://rubygems.org/gems/parallel_http'
  s.add_runtime_dependency "eventmachine", [">= 1.0.0"]
  s.add_runtime_dependency "em-http-request", [">= 1.0.3"]
end
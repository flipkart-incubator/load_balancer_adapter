Gem::Specification.new do |s|
  s.name        = 'load_balancer_adapter'
  s.version     = '0.1'
  s.date        = '2014-07-17'
  s.summary     = "Load balances connections across multiple database hosts"
  s.description = "Load balances connections across multiple database hosts"
  s.authors     = ["Yogi Kulkarni"]
  s.email       = 'yogi@flipkart.com'
  s.files       = Dir["lib/*"]
  s.homepage    = 'http://github.com/flipkart/load_balancer_adapter'
  s.add_dependency "activerecord", ">= 3.1.0", "< 3.2.0"
  s.add_development_dependency "test-unit"
end
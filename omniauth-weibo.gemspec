# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-weibo/version"

Gem::Specification.new do |s|
  s.name        = "omniauth-weibo"
  s.version     = Omniauth::Weibo::VERSION
  s.authors     = ["Scott Ballantyne"]
  s.email       = ["ussballantyne@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{an omniauth strategy for sina weibo}
  s.description = %q{an omniauth strategy for sina weibo}

  s.rubyforge_project = "omniauth-weibo"
  
  s.add_runtime_dependency     'omniauth', '~> 1.0.0.rc2'
  s.add_runtime_dependency     'oauth'
  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rack-test'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

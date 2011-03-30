# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "tsatsiki-cucumber-formatter"
  s.version     = '0.1.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bob Lail"]
  s.email       = ["bob.lailfamily@gmail.com"]
  s.homepage    = "http://tsatsiki.info"
  s.summary     = %q{Writes results of cucumber tests to a Tsatsiki server}
  s.description = %q{A custom formatter for Cucumber}

  s.rubyforge_project = "tsatsiki_cucumber_formatter"
  
  s.add_dependency "cucumber"
  s.add_dependency "addressable"
  s.add_dependency "libwebsocket"
  
  s.add_development_dependency "bundler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

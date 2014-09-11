$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "envoy_idempotence/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "envoy_idempotence"
  s.version     = EnvoyIdempotence::VERSION
  s.authors     = ["Lee Henson"]
  s.email       = ["lee.m.henson@gmail.com"]
  s.homepage    = "https://github.com/musicglue/envoy_idempotence"
  s.summary     = %q{Adds message idempotence support to Envoy.}
  s.description = %q{Adds message idempotence support to Envoy.}
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "docket"
  s.add_dependency "rails", ">= 4.1.0"

  s.add_development_dependency "awesome_print"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-focus"
  s.add_development_dependency "minitest-rg"
  s.add_development_dependency "minitest-spec-rails"
  s.add_development_dependency "pg"
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "silverweb_ecom/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "silverweb_ecom"
  s.version     = SilverwebEcom::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SilverwebEcom."
  s.description = "TODO: Description of SilverwebEcom."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.3"

  s.add_development_dependency "sqlite3"
end

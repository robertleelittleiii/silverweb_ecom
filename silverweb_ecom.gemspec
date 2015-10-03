$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "silverweb_ecom/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "silverweb_ecom"
  s.version     = SilverwebEcom::VERSION
  s.authors     = ["Robert Lee Little III"]
  s.email       = ["rob@silverwebsystems.com"]
  s.homepage    = "http://www.silverwebsystems.com/"
  s.summary     = "This is an ecommerce gem that plugs into the silverweb cms gem."
  s.description = "An ecommerse gem that sits on top of the silverweb_cms."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.0"
  s.add_dependency 'silverweb_cms'
  s.add_dependency "bartt-ssl_requirement"
  #s.add_dependency "ssl_requirement"
  s.add_dependency "geocoder"

  s.add_development_dependency "mysql"
end

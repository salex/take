$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "take/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "take"
  s.version     = Take::VERSION
  s.authors     = ["Steve Alex"]
  s.email       = ["salex@mac.com"]
  s.homepage    = "http://iwishicouldwrite.com"
  s.summary     = "take-#{s.version}"
  s.description = "A Rails mountable engine to provides a assessments/questions/answers structure. For use in assessments, tests, surveys, etc."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end

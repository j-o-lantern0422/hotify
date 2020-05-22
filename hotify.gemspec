require_relative 'lib/hotify/version'

Gem::Specification.new do |spec|
  spec.name          = "hotify"
  spec.version       = Hotify::VERSION
  spec.authors       = ["j-o-lantern0422"]
  spec.email         = ["j.o.lantern0422@gmail.com"]

  spec.summary       = %q{Onelogin role and users mange with yaml}
  spec.description   = %q{Onelogin role manage, example user add, or remove from role command}
  spec.homepage      = "https://github.com/j-o-lantern0422/hotify"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/j-o-lantern0422/hotify"
  spec.metadata["changelog_uri"] = "https://github.com/j-o-lantern0422/hotify"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "byebug", "~> 11.1.3"
  spec.add_development_dependency "pry", "~> 0.13.1"
  spec.add_development_dependency "dotenv", "~> 2.7.5" 
  spec.add_dependency "onelogin", "~> 1.5.0"
  spec.add_dependency "thor", "~> 1.0.1"
end

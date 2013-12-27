# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vcs_toolkit/version'

Gem::Specification.new do |spec|
  spec.name        = 'vcs_toolkit'
  spec.version     = VCSToolkit::VERSION
  spec.authors     = ["Georgy Angelov"]
  spec.email       = ["georgyangelov@gmail.com"]
  spec.homepage    = "http://github.com/stormbreakerbg/vcs-toolkit"
  spec.summary     = "A Ruby gem designed to allow its users to easily implement their own Version Control System"
  spec.description = "Allows easy to use platform for building a Version Control System. It's a proof-of-concept that VCS systems such as Git are simple in their implementation"
  spec.license     = "MIT"

  spec.add_runtime_dependency "diff-lcs"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fuubar"

  spec.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  spec.executables  = []
  spec.require_path = 'lib'
end
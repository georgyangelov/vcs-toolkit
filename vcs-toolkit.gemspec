Gem::Specification.new do |s|
  s.name        = 'vcs_toolkit'
  s.version     = 0.0.0
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Georgy Angelov"]
  s.email       = ["georgyangelov@gmail.com"]
  s.homepage    = "http://github.com/stormbreakerbg/vcs-toolkit"
  s.summary     = "A Ruby gem designed to allow its users to easily implement their own Version Control System"
  s.description = "Allows easy to use platform for building a Version Control System. It's a proof-of-concept that VCS systems such as Git are simple in their implementation"

  s.add_development_dependency "rspec"

  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.md)
  s.executables  = []
  s.require_path = 'lib'
end
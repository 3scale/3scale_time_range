# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '3scale_time_range/version'

Gem::Specification.new do |spec|
  spec.name          = "3scale_time_range"
  spec.version       = TimeRange::VERSION
  spec.authors       = ["Wojciech Ogrodowczyk", "Alejandro Martinez Ruiz", "Michal Macejko", "Michal Cichra", "David Ortiz Lopez"]
  spec.email         = ["wojciech@haikuco.de", "amr@redhat.com", "mmacejko@redhat.com", "mcichra@redhat.com", "dortiz@redhat.com"]
  spec.summary       = %q{Utility class for ranges of times (time periods).}
  spec.description   = %q{Utility class for ranges of times (time periods). It's like Range, but has additional enumeration capabilities.}
  spec.homepage      = "https://github.com/3scale/3scale_time_range"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 3.2.19"

  spec.add_development_dependency "bundler", ">= 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.4.0"
  spec.add_development_dependency "geminabox", "~> 0.12.4"
end

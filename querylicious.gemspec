# frozen-string-literal: true

Gem::Specification.new do |spec|
  version_file = File.expand_path('VERSION', __dir__)
  version = File.read(version_file).lines.first.chomp

  spec.name          = 'querylicious'
  spec.version       = version.split('+').first
  spec.authors       = ['Jo-Herman Haugholt']
  spec.email         = ['jo-herman@sonans.no']

  spec.summary       = 'An opinionated search query parser'
  spec.homepage      = 'https://github.com/Sonans/querylicious'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'parslet', '~> 1.8'
  spec.add_runtime_dependency 'dry-matcher', '~> 0.6.0'
  spec.add_runtime_dependency 'dry-types', '~> 0.12.0'
  spec.add_runtime_dependency 'dry-struct', '~> 0.4.0'
  spec.add_runtime_dependency 'dry-initializer', '~> 2.3'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'reek', '~> 4.7'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-parameterized', '~> 0.4.0'
  spec.add_development_dependency 'rubocop', '~> 0.49.1'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'simplecov', '~> 0.15.0'
end

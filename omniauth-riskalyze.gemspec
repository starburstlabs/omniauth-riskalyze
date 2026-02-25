# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/riskalyze/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-riskalyze'
  spec.version       = Omniauth::Riskalyze::VERSION
  spec.authors       = ['Matt Gillooly']
  spec.email         = ['starburst@mattgillooly.com']

  spec.summary       = 'Riskalyze strategy for OmniAuth'
  spec.description   = 'Riskalyze strategy for OmniAuth'
  spec.homepage      = 'https://github.com/starburst/omniauth-riskalyze'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'omniauth', '~> 2.0'
  spec.add_runtime_dependency 'omniauth-oauth2', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
end

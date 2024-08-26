# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_shippo/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_shippo'
  s.version     = SpreeShippo::VERSION
  s.summary     = "Spree Commerce Shippo Extension"
  s.required_ruby_version = '>= 3.3.4'

  s.author    = 'Shrey'
  s.email     = 'shrey.gupta@bluebash.co'
  s.homepage  = 'https://github.com/your-github-handle/spree_shippo'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '>= 4.8.3'
  s.add_dependency 'spree_extension'
  s.add_dependency 'shippo'
  s.add_dependency 'wicked_pdf', '~> 2.6'
  s.add_dependency 'wkhtmltopdf-binary', '~> 0.12.6'
  s.add_dependency 'httparty'
  s.add_development_dependency 'spree_dev_tools'
end

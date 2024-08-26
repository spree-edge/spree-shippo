source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails-controller-testing'

spree_opts = { github: 'spree/spree', branch: 'main' }
gem 'spree', spree_opts
gem 'spree_emails', spree_opts

gem 'spree_backend', github: 'spree/spree_backend', branch: 'main'
gem 'spree_frontend', github: 'spree/spree_rails_frontend', branch: 'main'

if ENV['DB'] == 'mysql'
  gem 'mysql2'
elsif ENV['DB'] == 'postgres'
  gem 'pg'
else
  gem 'sqlite3', '~> 1.4'
end

group :development do
  gem 'wkhtmltopdf-binary'
end
gem 'httparty'
gem "wicked_pdf", github: "mileszs/wicked_pdf", branch: "master"
gem 'shippo', git: 'https://github.com/goshippo/shippo-ruby-client'

gemspec

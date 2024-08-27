# Spree Shippo

This is a Shippo extension for [Spree Commerce](https://spreecommerce.org), an open source e-commerce platform built with Ruby on Rails.
This extension primarily consists of logic for using the USPS carrier service.

## Installation

1. Add this extension to your Gemfile with this line:

    ```ruby
    gem 'spree_shippo', github: 'spree-edge/spree-shippo', branch: 'main'
    ```

   And then execute:

    $ bundle

2. Copy & run migrations

    ```ruby
    bundle exec rails g spree_shippo:install
    ```

3. Restart your server

  If your server was running, restart it so that it can find the assets properly.

## Usage

You need to configure Spree Shippo by creating a `spree_shippo.rb` file in the `initializers` folder. Add the following code to the file. Also, make sure to add your Shippo API token to avoid "token not configured" errors.


```ruby
require 'shippo'

Shippo::API.token = Rails.application.credentials.dig(:spree_shippo, :api_token) || ENV['SPREE_SHIPPO_API_TOKEN']

if Shippo::API.token.nil?
raise "Shippo API token is not configured. Please add it to Rails credentials or set the SHIPPO_API_TOKEN environment variable."
end
```

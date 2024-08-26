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

You must configure Spree Shippo by adding your Shippo API Token. Without this, you will encounter the following error and won't be able to proceed:

```ruby
    require 'shippo'

    Shippo::API.token = Rails.application.credentials.dig(:spree_shippo, :api_token) || ENV['SPREE_SHIPPO_API_TOKEN']

    if Shippo::API.token.nil?
    raise "Shippo API token is not configured. Please add it to Rails credentials or set the SHIPPO_API_TOKEN environment variable."
    end
end
```

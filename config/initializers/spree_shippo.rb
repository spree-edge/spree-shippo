require 'shippo'

Shippo::API.token = Rails.application.credentials.dig(:spree_shippo, :api_token) || ENV['SPREE_SHIPPO_API_TOKEN']

if Shippo::API.token.nil?
  raise "Shippo API token is not configured. Please add it to Rails credentials or set the SHIPPO_API_TOKEN environment variable."
end

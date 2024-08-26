module ShippoConcern
  extend ActiveSupport::Concern
  require 'httparty'
  require 'shippo'

  def get_rates(package)
    begin
      @shipment = ::Shippo::Shipment.create(create_ship_request_object(package))

      return @shipment.rates
    rescue => ex
      throw create_ship_request_object(package)
    end
  end

  def get_tracking(carrier, tracking_number)
    obj = {
      "carrier": carrier,
      "tracking_number": tracking_number
    }

    result = HTTParty.post(
      "https://api.goshippo.com/tracks/",
      headers: { "Authorization" => "ShippoToken #{Shippo::API.token}", "Content-Type" => "application/json" },
      body: obj.to_json
    )
    return result
  end

  private

  def create_ship_request_object(shipment)
    order = shipment.order
    stock_location = shipment.stock_location
    shipping_address = order.shipping_address

    parcel = {
      length: 0,
      width: 0,
      height: 0,
      distance_unit: :in,
      weight: 0,
      mass_unit: :oz
    }

    parcels = []
    shipment.contents.each do |content|
      variant = content.variant

      parcel[:length] += 6
      parcel[:width] += 3
      parcel[:height] += 2
      parcel[:weight] += 10
    end

    parcels << parcel

    params = {
      async: false,
      address_from: {
        name: stock_location.name,
        company: Spree::Store.current.name,
        street1: stock_location.address1,
        street2: stock_location.address2,
        city: stock_location.city,
        state: Spree::State.find_by_id(stock_location&.state_id)&.abbr,
        zip: stock_location.zipcode,
        country: Spree::Country.find_by_id(stock_location&.country_id)&.iso,
        phone: stock_location.phone
      },
      address_to: {
        name: "#{shipping_address.firstname} #{shipping_address.lastname}",
        company: shipping_address.company.present? ? shipping_address.company : '',
        street1: shipping_address.address1,
        city: shipping_address.city,
        state: shipping_address&.state&.abbr,
        zip: shipping_address.zipcode,
        country: shipping_address.country.iso,
        phone: shipping_address.phone,
        email: order.email
      },
      parcels: parcels
    }
    return params
  end
end

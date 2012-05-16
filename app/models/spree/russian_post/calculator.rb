# coding: UTF-8

class Spree::RussianPost::Calculator < Spree::Calculator
  include RussianPostCalc

  # Post code of the sender.
  preference :sender_post_code,             :text,    :default => '190000'

  # Calculated price will we multipied to 100% + cache_on_delivery_percentage%
  preference :cache_on_delivery_percentage, :decimal, :default => 0

  # If this value is set, given payment method will be used and payment method selection
  # will be disabled. Usually used for cache on delivery.
  preference :autoselect_payment_method_id, :integer

  # Use declared value for calculation.
  preference :use_declared_value,           :boolean, :default => false

  def self.description
    I18n.t(:russian_post_description)
  end

  def compute(object=nil)
    weight = compute_weight(weight)

    # Get order from the object.
    order = object.is_a?(Order) ? object : object.order

    declared_value = if preferred_use_declared_value
                       object.line_items.map(&:amount).sum
                     else
                       0
                     end

    # Calculate delivery price itself.
    calculate_delivery_price preferred_sender_post_code, order.ship_address.zipcode, weight, declared_value
  end

  # Computes weight for the given order.
  #
  # @param [Spree::Order, Spree::Shipment] object Object to calculate weight of. Can be Order or Shipment
  #
  # @return [Float] calculated weight [kilogramms].
  #
  # TODO (VZ): Move it to the order class. Perhabs add caching to this fiesld's value.
  # TODO (VZ): Add weight caching to the line item.
  def compute_weight object
    object.line_items.map { |li| li.variant.weight  * li.quantity }.sum
  end


  # Make weight to be 0.75, 1.25, 1.75...
  be_rude :calculate_delivery_price,
    2 => lambda { |weight|
           if weight < 0.75
             0
           elsif weight > 20
             then raise "Максимальный вес для отправления: 20 кг."
           else
             ((weight - 0.25) / 0.5).floor * 0.5 + 0.25
           end
         }
end

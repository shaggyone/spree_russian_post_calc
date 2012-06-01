# coding: UTF-8

class Spree::RussianPost::Calculator < Spree::Calculator
  include RussianPostCalc

  # Post code of the sender.
  preference :sender_post_code,             :string,    :default => '190000'

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
    weight = compute_weight(object)

    # Get order from the object.
    order = object.is_a?(::Spree::Order) ? object : object.order

    declared_value = if preferred_use_declared_value
                       object.line_items.map(&:amount).sum
                     else
                       0
                     end

    # Calculate delivery price itself.
    calculate_price preferred_sender_post_code, order.ship_address.zipcode, weight, declared_value
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
    object.line_items.map { |li| (li.variant.weight || 0)  * li.quantity }.sum
  end

  def calculate_price sender_post_code, destination_post_code, weight, declared_value = 0
    weight = if weight < 0.75
               0
             elsif weight > 20
               then raise "Максимальный вес для отправления: 20 кг."
             else
               ((weight - 0.25) / 0.5).floor * 0.5 + 0.25
             end

    self.class.calculate_delivery_price sender_post_code, destination_post_code, weight, declared_value
  end

  class << self
    include ::FlexyCache

    flexy_cache :calculate_delivery_price,
                :cache_key_condition => Proc.new { |*args| args.join("/") },
                :expire_on           => Proc.new { |object| Time.now + 2.weeks },
                :retry_in            => Proc.new { |object| Time.now + 2.hours },
                :error_result        => Proc.new { |result, object| result.blank? },
                :catch_exceptions    => Net::HTTPExceptions
  end
end

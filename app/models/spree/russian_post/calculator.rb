class Spree::RussianPost::Calculator < Spree::Calculator

  # Post code of the sender.
  preference :sender_post_code,             :text,    :default => '190000'

  # Calculated price will we multipied to 100% + cache_on_delivery_percentage%
  preference :cache_on_delivery_percentage, :decimal, :default => 0

  # If this value is set, given payment method will be used and payment method selection
  # will be disabled. Usually used for cache on delivery.
  preference :autoselect_payment_method_id, :integer

  def self.description
    I18n.t(:russian_post_description)
  end

  def compute(object=nil)

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
    object.line_items.inject { |sum, li| sum += li.variant.weight  * li.quantity }
  end

end

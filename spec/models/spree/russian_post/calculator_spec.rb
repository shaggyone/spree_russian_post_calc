require 'spec_helper'

describe Spree::RussianPost::Calculator do
  let(:calculator) { Spree::RussianPost::Calculator.new }
  let(:shipping_method) { create :shipping_method, :calculator => calculator }

  context "preferences" do

  end

  context "#compute_weight" do
    let(:variant_1) { create :variant, :weight => 1   }
    let(:variant_2) { create :variant, :weight => 0.2 }
    let(:order) do
      build :order, :line_items => [
        build(:line_item, :quantity => 3, :variant => variant_1),
        build(:line_item, :quantity => 2, :variant => variant_2)
      ]
    end

    let(:shipment) { create :shipment, :shipping_method => shipping_method }


    it "computes weight for an order" do
      calculator.compute_weight(order).should be == 3.4
    end

    it "computes weight for a shipment" do
      # NOTE: For some reason shipment.order has zero line_items if got from factories.
      shipment.order = order

      calculator.compute_weight(shipment).should be == 3.4
    end
  end

  context "#calculate_delivery_price" do
    it "should be rude" do
      subject.should_receive(:exact_calculate_delivery_price).with("from", "to",     0, "value").ordered
      subject.should_receive(:exact_calculate_delivery_price).with("from", "to",     0, "value").ordered
      subject.should_receive(:exact_calculate_delivery_price).with("from", "to",  0.75, "value").ordered
      subject.should_receive(:exact_calculate_delivery_price).with("from", "to",  1.25, "value").ordered
      subject.should_receive(:exact_calculate_delivery_price).with("from", "to", 19.75, "value").ordered

      subject.calculate_delivery_price "from", "to", 0.1, "value"
      subject.calculate_delivery_price "from", "to", 0.6, "value"
      subject.calculate_delivery_price "from", "to", 1.0, "value"
      subject.calculate_delivery_price "from", "to", 1.5, "value"
      subject.calculate_delivery_price "from", "to",  20, "value"

      expect {
        subject.calculate_delivery_price "from", "to", 20.1, "value"
      }.to raise_error
    end
  end
end

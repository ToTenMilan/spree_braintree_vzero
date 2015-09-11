require 'spec_helper'

describe Spree::Gateway::BraintreeVzero, :vcr do

  context 'valid credentials' do

    let(:gateway) { create(:vzero_gateway) }
    let(:order) { OrderWalkthrough.up_to(:payment) }

    it 'generates token' do
      expect(gateway.client_token).to_not be_nil
    end

    describe '#purchase' do

      it 'returns suceess with valid nonce' do
        expect(gateway.purchase('fake-valid-nonce', order).success?).to be true
      end

      it 'returns false with invalid nonce' do
        expect(gateway.purchase('fake-invalid-nonce', order).success?).to be false
      end

    end

    describe '#complete_order' do

      it 'completes order with valid nonce' do
        gateway.complete_order(order, gateway.purchase('fake-valid-nonce', order), gateway)
        expect(order.completed?).to be true
      end


      it 'returns false when payment cannot be validated' do
        expect(gateway.complete_order(order, gateway.purchase('fake-invalid-nonce', order), gateway)).to be false
        expect(order.completed?).to be false
      end

    end

  end

  context 'with invalid credentials' do
    let(:gateway) { create(:vzero_gateway, merchant_id: 'invalid_id') }

    it 'raises Braintree error' do
      expect { gateway.client_token }.to raise_error('Braintree::AuthenticationError')
    end

  end
end
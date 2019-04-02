# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'tracing' do

    before do
      class Record < LHS::Record
        endpoint 'https://records'
      end

      expect(LHC).to receive(:request).with(anything) do |arguments|
        expect(arguments[:source]).to include(__FILE__)
        spy(:response)
      end
    end

    context 'find_by' do

      it 'forwards tracing options to lhc' do
        stub_request(:get, "https://records/?color=blue&limit=1")
          .to_return(status: 204)

        Record.find_by(color: :blue)
      end
    end
  end
end

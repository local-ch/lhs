# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do

  context 'tracing' do
    context 'with level set to debug' do

      before do
        allow(Rails.logger).to receive(:level).and_return(0)
      end

      context 'with non-paginated methods' do

        let(:request) do
          stub_request(:get, "https://records/3jg781")
            .to_return(status: 204)
        end

        before do
          class Record < LHS::Record
            endpoint 'https://records'
          end

          expect(LHC).to receive(:request).with(anything) do |arguments|
            expect(arguments[:source]).to include(__FILE__)
            spy(:response)
          end
        end

        %w[find find_by find_by! first first! last!].each do |method|
          context method do
            it 'forwards tracing options to lhc' do
              Record.public_send(method, color: :blue)
            end
          end
        end
      end

      context 'with paginated method last' do

        before do
          class Place < LHS::Record
            endpoint 'http://datastore/places'
          end

          stub_request(:get, "http://datastore/places?limit=1")
            .to_return(
              body: {
                items:  [
                  { id: 'first-1', company_name: 'Localsearch AG' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )

          stub_request(:get, "http://datastore/places?limit=1&offset=499")
            .to_return(
              body: {
                items:  [
                  { id: 'last-500', company_name: 'Curious GmbH' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )

          expect(LHC).to receive(:request).and_call_original
          expect(LHC).to receive(:request).with(hash_including(params: { offset: 499, limit: 1 })) do |arguments|
            expect(arguments[:source]).to include(__FILE__)
            spy(:response)
          end
        end

        it 'forwards tracing options to lhc' do
          # binding.pry
          Place.last
        end
      end
    end

    # test.rb sets config.log_level = :warn purposefully so that only those tests which need tracing can override
    # log_level to debug to enable it
    context 'with level set to other than debug (default in test)' do
      context 'non-paginated methods' do

        before do
          class Record < LHS::Record
            endpoint 'https://records'
          end

          expect(LHC).to receive(:request).with(anything) do |arguments|
            expect(arguments).not_to include(:source)
            spy(:response)
          end
        end

        %w[find find_by find_by! first first! last!].each do |method|
          context method do
            it 'does not forward tracing options to lhc' do
              Record.public_send(method, color: :blue)
            end
          end
        end
      end

      context 'with paginated method last' do
        before do
          class Place < LHS::Record
            endpoint 'http://datastore/places'
          end

          stub_request(:get, "http://datastore/places?limit=1")
            .to_return(
              body: {
                items:  [
                  { id: 'first-1', company_name: 'Localsearch AG' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )

          stub_request(:get, "http://datastore/places?limit=1&offset=499")
            .to_return(
              body: {
                items:  [
                  { id: 'last-500', company_name: 'Curious GmbH' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )

          # for first pagination requets (first-1)
          expect(LHC).to receive(:request).and_call_original

          # for second reques (last-500)
          expect(LHC).to receive(:request).with(hash_including(params: { offset: 499, limit: 1 })) do |arguments|
            expect(arguments).not_to include(:source)
            spy(:response)
          end
        end

        it 'does not forward tracing options to lhc' do
          Place.last
        end
      end
    end
  end
end

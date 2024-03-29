# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'create' do
    let(:datastore) { 'http://local.ch/v2' }

    before do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Record
        endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
      end
    end

    let(:object) do
      {
        recommended: true,
        source_id: 'aaa'
      }
    end

    it 'creates new record on the backend' do
      stub_request(:post, "#{datastore}/feedbacks")
        .with(body: object.to_json)
        .to_return(status: 200, body: object.to_json)
      record = Feedback.create(object)
      expect(record).to be_kind_of Feedback
      expect(record.recommended).to eq true
      expect(record.errors.messages).to eq({})
      expect(record.errors.message).to eq nil
    end

    it 'uses proper endpoint when creating data' do
      stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
        .with(body: object.to_json)
        .to_return(status: 200, body: object.to_json)
      Feedback.create(object.merge(campaign_id: '12345'))
    end

    it 'merges backend response object with object' do
      body = object.merge(additional_key: 1)
      stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
        .with(body: object.to_json)
        .to_return(status: 200, body: body.to_json)
      data = Feedback.create(object.merge(campaign_id: '12345'))
      expect(data.additional_key).to eq 1
    end

    context 'creation errors' do
      let(:creation_error) do
        {
          "status" => 400,
          "fields" => [
            {
              "name" => "ratings",
              "details" => [{ "code" => "REQUIRED_PROPERTY_VALUE" }]
            }, {
              "name" => "recommended",
              "details" => [{ "code" => "REQUIRED_PROPERTY_VALUE" }]
            }
          ]
        }
      end

      it 'provides errors accessor on the record when creation failed using create' do
        stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
          .to_return(status: 400, body: creation_error.to_json)
        feedback = Feedback.create(object.merge(campaign_id: '12345'))
        expect(feedback.errors).to be_kind_of LHS::Problems::Errors
      end

      it 'raises an exception when creation failed using create!' do
        stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
          .to_return(status: 400, body: creation_error.to_json)
        expect(lambda {
          Feedback.create!(object.merge(campaign_id: '12345'))
        }).to raise_error(LHC::Error)
      end
    end

    context 'custom setters' do
      before do
        class Feedback
          def ratings=(ratings)
            _raw[:ratings] = ratings.map { |k, v| { name: k.to_s, value: v } }
          end
        end

        stub_request(:post, "#{datastore}/feedbacks")
          .with(body: { ratings: converted_ratings }.to_json)
          .to_return(status: 200, body: { ratings: converted_ratings }.to_json)
      end

      let(:ratings) do
        {
          a: 1,
          b: 2
        }
      end

      let(:converted_ratings) do
        [
          { name: 'a', value: 1 },
          { name: 'b', value: 2 }
        ]
      end

      it 'are used by create' do
        feedback = Feedback.create(ratings: ratings)
        expect(feedback.ratings._raw).to eq(converted_ratings)
      end

      it 'can be used directly to change raw data' do
        feedback = Feedback.create(ratings: ratings)
        feedback.ratings = { z: 3 }
        expect(feedback.ratings.first.name).to eq 'z'
      end

      context 'and custom getters' do
        before do
          class Feedback
            def ratings
              Hash[_raw[:ratings].map { |r| [r[:name].to_sym, r[:value]] }]
            end
          end
        end

        it 'uses custom getters to show data for exploration' do
          feedback = Feedback.create(ratings: ratings)
          expect(feedback.ratings).to eq(ratings)
        end
      end
    end

    context 'location header' do
      let(:created_at) { '2017-12-21' }
      let(:location)   { 'http://datastore/contact_persons/1' }
      let(:name)       { 'Sebastian' }
      let!(:create_contact_person_request) do
        stub_request(:post, "http://datastore/contact_persons")
          .to_return(status: 204, headers: { Location: location })
      end
      let!(:fetch_contact_person_request) do
        stub_request(:get, "http://datastore/contact_persons/1")
          .to_return(body: { href: location, name: name, created_at: created_at }.to_json)
      end

      context 'without `followlocation` option' do
        before do
          class ContactPerson < LHS::Record
            endpoint 'http://datastore/contact_persons'
          end
        end

        it 'loads the data from the "Location" header after creation' do
          contact_person = ContactPerson.create!(name: name)
          expect(create_contact_person_request).to have_been_made.once
          expect(fetch_contact_person_request).to have_been_made.once
          expect(contact_person.href).to eq location
          expect(contact_person.created_at).to eq Date.parse(created_at)
          expect(contact_person.name).to eq name
        end
      end

      context 'when `followlocation` is set to `true`' do
        before do
          class ContactPerson < LHS::Record
            endpoint 'http://datastore/contact_persons', followlocation: true
          end
        end

        it 'loads the data from the "Location" header after creation' do
          contact_person = ContactPerson.create!(name: name)
          expect(create_contact_person_request).to have_been_made.once
          expect(fetch_contact_person_request).to have_been_made.once
          expect(contact_person.href).to eq location
          expect(contact_person.created_at).to eq Date.parse(created_at)
          expect(contact_person.name).to eq name
        end
      end

      context 'when `followlocation` is set to `false`' do
        before do
          class ContactPerson < LHS::Record
            endpoint 'http://datastore/contact_persons', followlocation: false
          end
        end

        it 'does not load the data from the "Location" header after creation' do
          contact_person = ContactPerson.create!(name: name)
          expect(create_contact_person_request).to have_been_made.once
          expect(fetch_contact_person_request).not_to have_been_made
          expect(contact_person.name).to eq name
        end
      end
    end
  end
end

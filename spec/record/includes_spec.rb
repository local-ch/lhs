require 'rails_helper'

describe LHS::Record do
  let(:datastore) { 'http://local.ch/v2' }
  before(:each) { LHC.config.placeholder('datastore', datastore) }

  let(:stub_campaign_request) do
    stub_request(:get, "#{datastore}/content-ads/51dfc5690cf271c375c5a12d")
      .to_return(body: {
        'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d",
        'entry' => { 'href' => "#{datastore}/local-entries/lakj35asdflkj1203va" },
        'user' => { 'href' => "#{datastore}/users/lakj35asdflkj1203va" }
      }.to_json)
  end

  let(:stub_entry_request) do
    stub_request(:get, "#{datastore}/local-entries/lakj35asdflkj1203va")
      .to_return(body: { 'name' => 'Casa Ferlin' }.to_json)
  end

  let(:stub_user_request) do
    stub_request(:get, "#{datastore}/users/lakj35asdflkj1203va")
      .to_return(body: { 'name' => 'Mario' }.to_json)
  end

  context 'singlelevel includes' do
    before(:each) do
      class LocalEntry < LHS::Record
        endpoint '{+datastore}/local-entries'
        endpoint '{+datastore}/local-entries/{id}'
      end
      class User < LHS::Record
        endpoint '{+datastore}/users'
        endpoint '{+datastore}/users/{id}'
      end
      class Favorite < LHS::Record
        endpoint '{+datastore}/favorites'
        endpoint '{+datastore}/favorites/{id}'
      end
      stub_request(:get, "#{datastore}/local-entries/1")
        .to_return(body: { company_name: 'local.ch' }.to_json)
      stub_request(:get, "#{datastore}/users/1")
        .to_return(body: { name: 'Mario' }.to_json)
      stub_request(:get, "#{datastore}/favorites/1")
        .to_return(body: {
          local_entry: { href: "#{datastore}/local-entries/1" },
          user: { href: "#{datastore}/users/1" }
        }.to_json)
    end

    it 'includes a resource' do
      favorite = Favorite.includes(:local_entry).find(1)
      expect(favorite.local_entry.company_name).to eq 'local.ch'
    end

    it 'duplicates a class' do
      expect(Favorite.object_id).not_to eq(Favorite.includes(:local_entry).object_id)
    end

    it 'includes a list of resources' do
      favorite = Favorite.includes(:local_entry, :user).find(1)
      expect(favorite.local_entry).to be_kind_of LocalEntry
      expect(favorite.local_entry.company_name).to eq 'local.ch'
      expect(favorite.user.name).to eq 'Mario'
    end

    it 'includes an array of resources' do
      favorite = Favorite.includes([:local_entry, :user]).find(1)
      expect(favorite.local_entry.company_name).to eq 'local.ch'
      expect(favorite.user.name).to eq 'Mario'
    end
  end

  context 'multilevel includes' do
    before(:each) do
      class Feedback < LHS::Record
        endpoint '{+datastore}/feedbacks'
        endpoint '{+datastore}/feedbacks/{id}'
      end
      stub_campaign_request
      stub_entry_request
      stub_user_request
    end

    it 'includes linked resources while fetching multiple resources from one service' do
      stub_request(:get, "#{datastore}/feedbacks?has_reviews=true")
        .to_return(status: 200, body: {
          items: [
            {
              'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
              'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
            }
          ]
        }.to_json)

      feedbacks = Feedback.includes(campaign: :entry).where(has_reviews: true)
      expect(feedbacks.first.campaign.entry.name).to eq 'Casa Ferlin'
    end

    it 'includes linked resources while fetching a single resource from one service' do
      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
        }.to_json)

      feedbacks = Feedback.includes(campaign: :entry).find(123)
      expect(feedbacks.campaign.entry.name).to eq 'Casa Ferlin'
    end

    it 'includes linked resources with array while fetching a single resource from one service' do
      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
        }.to_json)

      feedbacks = Feedback.includes(campaign: [:entry, :user]).find(123)
      expect(feedbacks.campaign.entry.name).to eq 'Casa Ferlin'
      expect(feedbacks.campaign.user.name).to eq 'Mario'
    end

    it 'includes list of linked resources while fetching a single resource from one service' do
      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" },
          'user' => { 'href' => "#{datastore}/users/lakj35asdflkj1203va" }
        }.to_json)

      feedbacks = Feedback.includes(:user, campaign: [:entry, :user]).find(123)
      expect(feedbacks.campaign.entry.name).to eq 'Casa Ferlin'
      expect(feedbacks.campaign.user.name).to eq 'Mario'
      expect(feedbacks.user.name).to eq 'Mario'
    end

    context 'include objects from known services' do
      let(:stub_feedback_request) do
        stub_request(:get, "#{datastore}/feedbacks")
          .to_return(status: 200, body: {
            items: [
              {
                'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
                'entry' => {
                  'href' => "#{datastore}/local-entries/lakj35asdflkj1203va"
                }
              }
            ]
          }.to_json)
      end

      let(:interceptor) { spy('interceptor') }

      before(:each) do
        class Entry < LHS::Record
          endpoint '{+datastore}/local-entries/{id}'
        end
        LHC.config.interceptors = [interceptor]
      end

      it 'uses interceptors for included links from known services' do
        stub_feedback_request
        stub_entry_request
        expect(Feedback.includes(:entry).where.first.entry.name).to eq 'Casa Ferlin'
        expect(interceptor).to have_received(:before_request).twice
      end
    end

    context 'includes not present in response' do
      before :each do
        class Parent < LHS::Record
          endpoint '{+datastore}/local-parents'
          endpoint '{+datastore}/local-parents/{id}'
        end

        class OptionalChild < LHS::Record
          endpoint '{+datastore}/local-children/{id}'
        end
      end

      it 'handles missing but included fields in single object response' do
        stub_request(:get, "#{datastore}/local-parents/1")
          .to_return(status: 200, body: {
            'href' => "#{datastore}/local-parents/1",
            'name' => 'RspecName'
          }.to_json)

        parent = Parent.includes(:optional_children).find(1)
        expect(parent).not_to be nil
        expect(parent.name).to eq 'RspecName'
        expect(parent.optional_children).to be nil
      end

      it 'handles missing but included fields in collection response' do
        stub_request(:get, "#{datastore}/local-parents")
          .to_return(status: 200, body: {
            items: [
              {
                'href' => "#{datastore}/local-parents/1",
                'name' => 'RspecParent'
              }, {
                'href'           => "#{datastore}/local-parents/2",
                'name'           => 'RspecParent2',
                'optional_child' => {
                  'href' => "#{datastore}/local-children/1"
                }
              }
            ]
          }.to_json)

        stub_request(:get, "#{datastore}/local-children/1")
          .to_return(status: 200, body: {
            href: "#{datastore}/local_children/1",
            name: 'RspecOptionalChild1'
          }.to_json)

        child = Parent.includes(:optional_child).where[1].optional_child
        expect(child).not_to be nil
        expect(child.name).to eq 'RspecOptionalChild1'
      end
    end
  end

  context 'links pointing to nowhere' do
    it 'sets nil for links that cannot be included' do
      class Feedback < LHS::Record
        endpoint '{+datastore}/feedbacks'
        endpoint '{+datastore}/feedbacks/{id}'
      end

      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
        }.to_json)

      stub_request(:get, "#{datastore}/content-ads/51dfc5690cf271c375c5a12d")
        .to_return(status: 404)

      feedback = Feedback.includes(campaign: :entry).find(123)
      expect(feedback.campaign._raw.keys.count).to eq 1
      expect(feedback.campaign.href).to be
    end
  end

  context 'modules' do
    before(:each) do
      module Services
        class LocalEntry < LHS::Record
          endpoint '{+datastore}/local-entries'
        end

        class Feedback < LHS::Record
          endpoint '{+datastore}/feedbacks'
        end
      end
      stub_request(:get, "http://local.ch/v2/feedbacks?id=123")
        .to_return(body: [].to_json)
    end

    it 'works with modules' do
      Services::Feedback.includes(campaign: :entry).find(123)
    end
  end

  context 'arrays' do
    before(:each) do
      class Place < LHS::Record
        endpoint '{+datastore}/place'
        endpoint '{+datastore}/place/{id}'
      end
    end

    let!(:place_request) do
      stub_request(:get, "#{datastore}/place/1")
        .to_return(body: {
          'relations' => [
            { 'href' => "#{datastore}/place/relations/2" },
            { 'href' => "#{datastore}/place/relations/3" }
          ]
        }.to_json)
    end

    let!(:relation_request_1) do
      stub_request(:get, "#{datastore}/place/relations/2")
        .to_return(body: { name: 'Category' }.to_json)
    end

    let!(:relation_request_2) do
      stub_request(:get, "#{datastore}/place/relations/3")
        .to_return(body: { name: 'ZeFrank' }.to_json)
    end

    it 'includes items of arrays' do
      place = Place.includes(:relations).find(1)
      expect(place.relations.first.name).to eq 'Category'
      expect(place.relations[1].name).to eq 'ZeFrank'
    end

    context 'parallel with empty links' do
      let!(:place_request_2) do
        stub_request(:get, "#{datastore}/place/2")
          .to_return(body: {
            'relations' => []
          }.to_json)
      end

      it 'loads places in parallel and merges included data properly' do
        place = Place.includes(:relations).find(2, 1)
        expect(place[0].relations.empty?)
        expect(place[1].relations[0].name).to eq 'Category'
        expect(place[1].relations[1].name).to eq 'ZeFrank'
      end
    end
  end

  context 'empty collections' do
    it 'skips including empty collections' do
      class Place < LHS::Record
        endpoint '{+datastore}/place'
        endpoint '{+datastore}/place/{id}'
      end

      stub_request(:get, "#{datastore}/place/1")
        .to_return(body: {
          'available_products' => {
            "url" => "#{datastore}/place/1/products",
            "items" => []
          }
        }.to_json)

      place = Place.includes(:available_products).find(1)
      expect(place.available_products.empty?).to eq true
    end
  end

  context 'extend items with arrays' do
    it 'extends base items with arrays' do
      class Place < LHS::Record
        endpoint '{+datastore}/place'
        endpoint '{+datastore}/place/{id}'
      end

      stub_request(:get, "#{datastore}/place/1")
        .to_return(body: {
          'contracts' => {
            'items' => [{ 'href' => "#{datastore}/place/1/contacts/1" }]
          }
        }.to_json)

      stub_request(:get, "#{datastore}/place/1/contacts/1")
        .to_return(body: {
          'products' => { 'href' => "#{datastore}/place/1/contacts/1/products" }
        }.to_json)

      place = Place.includes(:contracts).find(1)
      expect(place.contracts.first.products.href).to eq "#{datastore}/place/1/contacts/1/products"
    end
  end

  context 'unexpanded response when requesting the included collection' do
    before(:each) do
      class Customer < LHS::Record
        endpoint '{+datastore}/customer/{id}'
      end
    end

    let!(:customer_request) do
      stub_request(:get, "#{datastore}/customer/1")
        .to_return(body: {
          places: {
            href: "#{datastore}/places"
          }
        }.to_json)
    end

    let!(:places_request) do
      stub_request(:get, "#{datastore}/places")
        .to_return(body: {
          items: [{ href: "#{datastore}/places/1" }]
        }.to_json)
    end

    let!(:place_request) do
      stub_request(:get, "#{datastore}/places/1")
        .to_return(body: {
          name: 'Casa Ferlin'
        }.to_json)
    end

    it 'loads the collection and the single items, if not already expanded' do
      place = Customer.includes(:places).find(1).places.first
      assert_requested(place_request)
      expect(place.name).to eq 'Casa Ferlin'
    end

    context 'forwarding options' do
      let!(:places_request) do
        stub_request(:get, "#{datastore}/places")
          .with(headers: { 'Authorization' => 'Bearer 123' })
          .to_return(
            body: {
              items: [{ href: "#{datastore}/places/1" }]
            }.to_json
          )
      end

      let!(:place_request) do
        stub_request(:get, "#{datastore}/places/1")
          .with(headers: { 'Authorization' => 'Bearer 123' })
          .to_return(
            body: {
              name: 'Casa Ferlin'
            }.to_json
          )
      end

      it 'forwards options used to expand those unexpanded items' do
        place = Customer
          .includes(:places)
          .references(places: { headers: { 'Authorization' => 'Bearer 123' } })
          .find(1)
          .places.first
        assert_requested(place_request)
        expect(place.name).to eq 'Casa Ferlin'
      end
    end
  end

  context 'includes with options' do
    before(:each) do
      class Customer < LHS::Record
        endpoint '{+datastore}/customers/{id}'
        endpoint '{+datastore}/customers'
      end

      class Place < LHS::Record
        endpoint '{+datastore}/places'
      end

      stub_request(:get, "#{datastore}/places?forwarded_params=123")
        .to_return(body: {
          'items' => [{ id: 1 }]
        }.to_json)
    end

    it 'forwards includes options to requests made for those includes' do
      stub_request(:get, "#{datastore}/customers/1")
        .to_return(body: {
          'places' => {
            'href' => "#{datastore}/places"
          }
        }.to_json)
      customer = Customer
        .includes(:places)
        .references(places: { params: { forwarded_params: 123 } })
        .find(1)
      expect(customer.places.first.id).to eq 1
    end

    it 'is chain-able' do
      stub_request(:get, "#{datastore}/customers?name=Steve")
        .to_return(body: [
          'places' => {
            'href' => "#{datastore}/places"
          }
        ].to_json)
      customers = Customer
        .where(name: 'Steve')
        .references(places: { params: { forwarded_params: 123 } })
        .includes(:places)
      expect(customers.first.places.first.id).to eq 1
    end
  end

  context 'more complex examples' do
    before(:each) do
      class Place < LHS::Record
        endpoint 'http://datastore/places/{id}'
      end
    end

    it 'forwards complex references' do
      stub_request(:get, "http://datastore/places/123?limit=1&forwarded_params=for_place")
        .to_return(body: {
          'contracts' => {
            'href' => "http://datastore/places/123/contracts"
          }
        }.to_json)
      stub_request(:get, "http://datastore/places/123/contracts?forwarded_params=for_contracts")
        .to_return(body: {
          href: "http://datastore/places/123/contracts?forwarded_params=for_contracts",
          items: [
            { product: { 'href' => "http://datastore/products/llo" } }
          ]
        }.to_json)
      stub_request(:get, "http://datastore/products/llo?forwarded_params=for_product")
        .to_return(body: {
          'href' => "http://datastore/products/llo",
          'name' => 'Local Logo'
        }.to_json)
      place = Place
        .options(params: { forwarded_params: 'for_place' })
        .includes(contracts: :product)
        .references(
          contracts: {
            params: { forwarded_params: 'for_contracts' },
            product: { params: { forwarded_params: 'for_product' } }
          }
        )
        .find_by(id: '123')
      expect(
        place.contracts.first.product.name
      ).to eq 'Local Logo'
    end

    it 'expands empty arrays' do
      stub_request(:get, "http://datastore/places/123")
        .to_return(body: {
          'contracts' => {
            'href' => "http://datastore/places/123/contracts"
          }
        }.to_json)
      stub_request(:get, "http://datastore/places/123/contracts")
        .to_return(body: {
          href: "http://datastore/places/123/contracts",
          items: []
        }.to_json)
      place = Place.includes(:contracts).find('123')
      expect(place.contracts.collection?).to eq true
      expect(
        place.contracts.as_json
      ).to eq('href' => 'http://datastore/places/123/contracts', 'items' => [])
      expect(place.contracts.to_a).to eq([])
    end
  end

  context 'include and merge arrays when calling find in parallel' do
    before(:each) do
      class Place < LHS::Record
        endpoint 'http://datastore/places/{id}'
      end
      stub_request(:get, 'http://datastore/places/1')
        .to_return(body: {
          category_relations: [{ href: 'http://datastore/category/1' }, { href: 'http://datastore/category/2' }]
        }.to_json)
      stub_request(:get, 'http://datastore/places/2')
        .to_return(body: {
          category_relations: [{ href: 'http://datastore/category/2' }, { href: 'http://datastore/category/1' }]
        }.to_json)
      stub_request(:get, "http://datastore/category/1").to_return(body: { name: 'Food' }.to_json)
      stub_request(:get, "http://datastore/category/2").to_return(body: { name: 'Drinks' }.to_json)
    end

    it 'includes and merges linked resources in case of an array of links' do
      places = Place
        .includes(:category_relations)
        .find(1, 2)
      expect(places[0].category_relations[0].name).to eq 'Food'
      expect(places[1].category_relations[0].name).to eq 'Drinks'
    end
  end

  context 'single href with array response' do
    it 'extends base items with arrays' do
      class Sector < LHS::Record
        endpoint '{+datastore}/sectors'
        endpoint '{+datastore}/sectors/{id}'
      end

      stub_request(:get, "#{datastore}/sectors")
        .with(query: hash_including(key: 'my_service'))
        .to_return(body: [
          {
            href: "#{datastore}/sectors/1",
            services: {
              href: "#{datastore}/sectors/1/services"
            },
            keys: [
              {
                key: 'my_service',
                language: 'de'
              }
            ]
          }
        ].to_json)

      stub_request(:get, "#{datastore}/sectors/1/services")
        .to_return(body: [
          {
            href: "#{datastore}/services/s1",
            price_in_cents: 9900,
            key: 'my_service_service_1'
          },
          {
            href: "#{datastore}/services/s2",
            price_in_cents: 19900,
            key: 'my_service_service_2'
          }
        ].to_json)

      sector = Sector.includes(:services).find_by(key: 'my_service')
      expect(sector.services.length).to eq 2
      expect(sector.services.first.key).to eq 'my_service_service_1'
    end
  end
end

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
        endpoint ':datastore/local-entries'
        endpoint ':datastore/local-entries/:id'
      end
      class User < LHS::Record
        endpoint ':datastore/users'
        endpoint ':datastore/users/:id'
      end
      class Favorite < LHS::Record
        endpoint ':datastore/favorites'
        endpoint ':datastore/favorites/:id'
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
        endpoint ':datastore/feedbacks'
        endpoint ':datastore/feedbacks/:id'
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

      before(:each) do
        class Entry < LHS::Record
          endpoint ':datastore/local-entries/:id'
        end
        class SomeInterceptor < LHC::Interceptor; end
        LHC.config.interceptors = [SomeInterceptor]
      end

      it 'uses interceptors for included links from known services' do
        # rubocop:disable RSpec/InstanceVariable
        stub_feedback_request
        stub_entry_request

        @called = 0
        allow_any_instance_of(SomeInterceptor).to receive(:before_request) { @called += 1 }

        expect(Feedback.includes(:entry).where.first.entry.name).to eq 'Casa Ferlin'
        expect(@called).to eq 2
        # rubocop:enable RSpec/InstanceVariable
      end
    end

    context 'includes not present in response' do
      before :each do
        class Parent < LHS::Record
          endpoint ':datastore/local-parents'
          endpoint ':datastore/local-parents/:id'
        end

        class OptionalChild < LHS::Record
          endpoint ':datastore/local-children/:id'
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
              }]
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
        endpoint ':datastore/feedbacks'
        endpoint ':datastore/feedbacks/:id'
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
          endpoint ':datastore/local-entries'
        end

        class Feedback < LHS::Record
          endpoint ':datastore/feedbacks'
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
    it 'includes items of arrays' do
      class Place < LHS::Record
        endpoint ':datastore/place'
        endpoint ':datastore/place/:id'
      end

      stub_request(:get, "#{datastore}/place/1")
        .to_return(body: {
          'relations' => [
            { 'href' => "#{datastore}/place/relations/2" },
            { 'href' => "#{datastore}/place/relations/3" }
          ]
        }.to_json)

      stub_request(:get, "#{datastore}/place/relations/2")
        .to_return(body: { name: 'Category' }.to_json)
      stub_request(:get, "#{datastore}/place/relations/3")
        .to_return(body: { name: 'ZeFrank' }.to_json)

      place = Place.includes(:relations).find(1)
      expect(place.relations.first.name).to eq 'Category'
      expect(place.relations[1].name).to eq 'ZeFrank'
    end
  end

  context 'empty collections' do
    it 'skips including empty collections' do
      class Place < LHS::Record
        endpoint ':datastore/place'
        endpoint ':datastore/place/:id'
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
        endpoint ':datastore/place'
        endpoint ':datastore/place/:id'
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

  context 'includes with options' do

    before(:each) do
      class Customer < LHS::Record
        endpoint ':datastore/customers/:id'
      end

      class Place < LHS::Record
        endpoint ':datastore/places'
      end
    end

    it 'forwards includes options to requests made for those includes' do
      stub_request(:get, "#{datastore}/customers/1")
        .to_return(body: {
          'places' => {
            'href' => "#{datastore}/places"
          }
        }.to_json)
      stub_request(:get, "#{datastore}/places?forwarded_params=123")
        .to_return(body: {
          'items' => [{ id: 1 }]
        }.to_json)
      customer = Customer
        .includes(:places)
        .references(places: { params: { forwarded_params: 123 } })
        .find(1)
      expect(customer.places.first.id).to eq 1
    end
  end
end

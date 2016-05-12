LHS
===

LHS uses [LHC](//github.com/local-ch/LHC) for http requests.

## Very Short Introduction

Access data that is provided by an http json service with ease using a LHS::Record.

```ruby
class Feedback < LHS::Record

  endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
  endpoint ':datastore/v2/feedbacks'

end

feedback = Feedback.find_by(email: 'somebody@mail.com') #<Feedback>
feedback.review # "Lunch was great"
```

## Where to store LHS::Records

Please store all defined LHS::Records in `app/models` as they are not autoloaded by rails otherwise.

## Endpoints

You setup a LHS::Record by configuring one or multiple endpoints. You can also add request options for an endpoint (see following example).

```ruby
class Feedback < LHS::Record

  endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
  endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks/:id'
  endpoint ':datastore/v2/feedbacks', cache: true, cache_expires_in: 1.day
  endpoint ':datastore/v2/feedbacks/:id', cache: true, cache_expires_in: 1.day

end
```

If you try to setup a LHS::Record with clashing endpoints it will immediately raise an exception.

```ruby
class Feedback < LHS::Record

  endpoint ':datastore/v2/reviews'
  endpoint ':datastore/v2/feedbacks'

end
# raises: Clashing endpoints.
```

## Find multiple records

You can query a service for records by using `where`.

```ruby
  Feedback.where(has_reviews: true)
```

This uses the `:datastore/v2/feedbacks` endpoint, cause `:campaign_id` was not provided. In addition it would add `?has_reviews=true` to the get parameters.

```ruby
  Feedback.where(campaign_id: 'fq-a81ngsl1d')
```

Uses the `:datastore/v2/content-ads/:campaign_id/feedbacks` endpoint.

## Chaining where statements

LHS supports chaining where statements. 
That allows you to chain multiple where-queries:

```ruby
class Record < LHS::Record
  endpoint 'records/'
  endpoint 'records/:id'
end

records = Record.where(color: 'blue')
...
records.where(available: true).each do |record|
  ...
end
```
The example would fetch records with the following parameters: `{color: blue, available: true}`.

## Where values hash

Returns a hash of where conditions.
Common to use in tests, as where queries are not performing any HTTP-requests when no data is accessed.

```ruby
records = Record.where(color: 'blue').where(available: true).where(color: 'red')

expect(
  records
).to have_requested(:get, %r{records/})
  .with(query: hash_including(color: 'blue', available: true))
# will fail as no http request is made (no data requested)

expect(
  records.where_values_hash
).to eq {color: 'red', available: true}
```

## Scopes: Reuse where statements

In order to make common where statements reusable you can organise them in scopes:

```ruby
class Record < LHS::Record
  endpoint 'records/'
  endpoint 'records/:id'
  scope :blue, -> { where(color: 'blue') }
  scope :available, ->(state) { where(available: state) }
end

records = Record.blue.available(true)
The example would fetch records with the following parameters: `{color: blue, visible: true}`.
```

## Find single records

`find` finds a unique record by uniqe identifier (usualy id).

If no record is found an error is raised.

## Proxy
Instead of mapping data when it arrives from the service, the proxy makes data accessible when you access it, not when you fetch it. The proxy is used to access data and it is divided in `Collection` and `Item`.

`find` can also be used to find a single uniqe record with parameters:

```ruby
  Feedback.find(campaign_id: 123, id: 456)
```

`find_by` finds the first record matching the specified conditions.

If no record is found, `nil` is returned.

`find_by!` raises LHC::NotFound if nothing was found.

```ruby
  Feedback.find_by(id: 'z12f-3asm3ngals')
  Feedback.find_by(id: 'doesntexist') # nil
```

`first` is an alias for finding the first record without parameters.

```ruby
  Feedback.first
```

If no record is found, `nil` is returned.

`first!` raises LHC::NotFound if nothing was found.

## Batch processing

**Be careful using methods for batch processing. They could result in a lot of HTTP requests!**

`all` fetches all records from the service by doing multiple requests if necessary.

```ruby
data = Feedback.all
data.count # 998
data.length # 998
```

[Count vs. Length](#count-vs-length)

`find_each` is a more fine grained way to process single records that are fetched in batches.

```ruby
Feedback.find_each(start: 50, batch_size: 20, params: { has_reviews: true }) do |feedback|
  # Iterates over each record. Starts with record nr. 50 and fetches 20 records each batch.
  feedback
  break if feedback.some_attribute == some_value
end
```

`find_in_batches` is used by `find_each` and processes batches.
```ruby
Feedback.find_in_batches(start: 50, batch_size: 20, params: { has_reviews: true }) do |feedbacks|
  # Iterates over multiple records (batch size is 20). Starts with record nr. 50 and fetches 20 records each batch.
  feedbacks
  break if feedback.some_attribute == some_value
end
```

## Create records

```ruby
  feedback = Feedback.create(
    recommended: true,
    source_id: 'aaa',
    content_ad_id: '1z-5r1fkaj'
  )
```

When creation fails, the object contains errors. It provides them through the `errors` attribute:

```ruby
  feedback.errors #<LHS::Errors>
  feedback.errors.include?(:ratings) # true
  feedback.errors[:ratings] # ['REQUIRED_PROPERTY_VALUE']
  record.errors.messages # {:ratings=>["REQUIRED_PROPERTY_VALUE"], :recommended=>["REQUIRED_PROPERTY_VALUE"]}
  record.errors.message # ratings must be set when review or name or review_title is set | The property value is required; it cannot be null, empty, or blank."
```

## Build new records

Build and persist new items from scratch are done either with `new` or it's alias `build`.

```ruby
  feedback = Feedback.new(recommended: true)
  feedback.save
```

## Custom setters and getters

Sometimes it is the case that you want to have your custom getters and setters and convert the data to a processable format behind the scenes. 
The initializer will now use custom setter if one is defined:

```ruby
class Feedback < LHS::Record
  def ratings=(ratings)
    _raw[:ratings] = ratings.map { |k, v| { name: k, value: v } }
  end
end

feedback = Feedback.new(ratings: { quality: 3 }) # <Feedback{:ratings=>[{:name=>:quality, :value=>3}]}>
feedback.ratings # #<LHS::Data:0x007fc8fa6d4050 ... @_raw=[{:name=>:quality, :value=>3}]>

```

If you have an accompanying getter the whole data manipulation would be internal only.

```ruby
class Feedback < LHS::Record
  def ratings=(ratings)
    _raw[:ratings] = ratings.map { |k, v| { name: k, value: v } }
  end

  def ratings
    Hash[_raw[:ratings].map { |r| [r[:name], r[:value]] }]
  end
end

feedback = Feedback.new(ratings: { quality: 3 }) # <Feedback{:ratings=>[{:name=>:quality, :value=>3}]}>
feedback.ratings # {:quality=>3}

```

## Include linked resources

When fetching records, you can specify in advance all the linked resources that you want to include in the results. With `includes`, LHS ensures that all matching and explicitly linked resources are loaded and merged.

The implementation is heavily influenced by [http://guides.rubyonrails.org/active_record_class_querying](http://guides.rubyonrails.org/active_record_class_querying.html#eager-loading-associations) and you should read it to understand this feature in all its glory.

### One-Level `includes`

```ruby
  # a claim has a localch_account
  claims = Claims.includes(:localch_account).where(place_id: 'huU90mB_6vAfUdVz_uDoyA')
  claims.first.localch_account.email # 'test@email.com'
```
* [see the JSON without include](examples/claim_no_include.json)
* [see the JSON with include](examples/claim_with_include.json)

### Two-Level `includes`

```ruby
  # a feedback has a campaign, which has an entry
  feedbacks = Feedback.includes(campaign: :entry).where(has_reviews: true)
  feedbacks.first.campaign.entry.name # 'Casa Ferlin'
```

### Multiple `includes`

```ruby
  # list of includes
  claims = Claims.includes(:localch_account, :entry).where(place_id: 'huU90mB_6vAfUdVz_uDoyA')

  # array of includes
  claims = Claims.includes([:localch_account, :entry]).where(place_id: 'huU90mB_6vAfUdVz_uDoyA')

  # Two-level with array of includes
  feedbacks = Feedback.includes(campaign: [:entry, :user]).where(has_reviews: true)
```

### Known LHS::Records are used to request linked resources

When including linked resources with `includes`, known/defined services and endpoints are used to make those requests.
That also means that options for endpoints of linked resources are applied when requesting those in addition.
This allows you to include protected resources (e.g. OAuth) as endpoint options for oauth authentication get applied.

The [Auth Inteceptor](https://github.com/local-ch/lhc-core-interceptors#auth-interceptor) from [lhc-core-interceptors](https://github.com/local-ch/lhc-core-interceptors) is used to configure the following endpoints.

```ruby
class Favorite < LHS::Record

  endpoint ':datastore/:user_id/favorites', auth: { bearer: -> { bearer_token } }
  endpoint ':datastore/:user_id/favorites/:id', auth: { bearer: -> { bearer_token } }

end

class Place < LHS::Record

  endpoint ':datastore/v2/places', auth: { bearer: -> { bearer_token } }
  endpoint ':datastore/v2/places/:id', auth: { bearer: -> { bearer_token } }

end

Favorite.includes(:place).where(user_id: current_user.id)
# Will include places and applies endpoint options to authenticate the request.
```

## Map data

To influence how data is accessed/provied, you can use mappings to either map deep nested data or to manipulate data when its accessed. Simply create methods inside the LHS::Record. They can access underlying data:

```ruby
class LocalEntry < LHS::Record
  endpoint ':datastore/v2/local-entries'

  def name
    addresses.first.business.identities.first.name
  end

end
```

### Nested records

Nested records (in nested data) are automaticaly casted when the href matches any defined endpoint of any LHS::Record.

```
class Place < LHS::Record
  endpoint ':datastore/v2/places'

  def name
    addresses.first.business.identities.first.name
  end
end

class Favorite < LHS::Record
  endpoint ':datastore/v2/favorites'
end

favorite = Favorite.includes(:place).find(1)
favorite.place.name # local.ch AG
```

If automatic-detection of nested records does not work, make sure your LHS::Records are stored in `app/models`!

## Setters

You can change attributes of LHS::Records:

```
  record = Feedback.find(id: 'z12f-3asm3ngals')
  rcord.recommended = false
```

## Save

You can persist changes with `save`. `save` will return `false` if persisting fails. `save!` instead will raise an exception.

```ruby
  feedback = Feedback.find('1z-5r1fkaj')
  feedback.recommended = false
  feedback.save
```

## Update

`update` will return false if persisting fails. `update!` instead will an raise exception.

`update` always updates the data of the local object first, before it tries to sync with an endpoint. So even if persisting fails, the local object is updated.

```ruby
feedback = Feedback.find('1z-5r1fkaj')
feedback.update(recommended: false)
```

## Destroy

You can delete records remotely by calling `destroy` on an LHS::Record.

```ruby
  feedback = Feedback.find('1z-5r1fkaj')
  feedback.destroy
```

## Validation

In order to validate LHS::Records before persisting them, you can use the `valid?` (`validate` alias) method.

The specific endpoint has to support validations with the `persist=false` parameter. The endpoint has to be enabled (opt-in) for validations in the service configuration.

```
class User < LHS::Record
  endpoint ':datastore/v2/users', validates: true
end

user = User.build(email: 'im not an email address')
unless user.valid?
  fail(user.errors[:email])
end
```

## How to work with paginated APIs

LHS supports paginated APIs and it also supports various pagination strategies and by providing configuration possibilities.

LHS diffentiates between the *pagination strategy* (how items/pages are navigated) itself and *pagination keys* (how stuff is named).

*Example 1 "offset"-strategy (default configuration)*
```ruby
# API response
{
  items: [{...}, ...]
  total: 300,
  limit: 100,
  offset: 0
}
# Next 'pages' are navigated with offset: 100, offset: 200, ...

# Nothing has to be configured in LHS because this is default pagination naming and strategy
class Results < LHS::Record
  endpoint 'results'
end
```

*Example 2 "page"-strategy and some naming configuration*
```ruby
# API response
{
  docs: [{...}, ...]
  totalPages: 3,
  limit: 100,
  page: 1
}
# Next 'pages' are navigated with page: 1, offset: 2, ...

# How LHS has to be configured
class Results < LHS::Record
  configuration items_key: 'docs', total_key: 'totalPages', pagination_key: 'page', pagination_strategy: 'page'
  endpoint 'results'
end
```

*Example 3 "start"-strategy and naming configuration*
```ruby
# API response
{
  results: [{...}, ...]
  total: 300,
  badgeSize: 100,
  startAt: 1
}
# Next 'pages' are navigated with startWith: 101, startWith: 201, ...

# How LHS has to be configured
class Results < LHS::Record
  configuration items_key: 'results', limit_key: 'badgeSize', pagination_key: 'startAt', pagination_strategy: 'start'
  endpoint 'results'
end
```

`items_key` key used to determine items of the current page (e.g. `docs`, `items`, etc.).

`limit_key` key used to work with page limits (e.g. `size`, `limit`, etc.)

`pagination_key` key used to paginate multiple pages (e.g. `offset`, `page`, `startAt` etc.).

`pagination_strategy` used to configure the strategy used for navigating (e.g. `offset`, `page`, `start`, etc.).

`total_key` key used to determine the total amount of items (e.g. `total`, `totalResults`, etc.).

In case of paginated resources it's important to know the difference between [count vs. length](#count-vs-length)

### Partial Kaminari support

LHS implements an interface that makes it partially working with Kaminari.

The kaminari’s page parameter is in params[:page]. For example, you can use kaminari to render paginations based on LHS Records. Typically, your code will look like this:

```ruby
# controller
params[:page] = 0 if params[:page].nil?
page = params[:page].to_i
limit = 100
offset = (page - 1) * limit
@items = Record.where({ limit: limit, offset: offset }))
```

```ruby
# view
= paginate @items
```

## form_for Helper
Rails `form_for` view-helper can be used in combination with instances of LHS::Record to autogenerate forms:
```
<%= form_for(@instance, url: '/create') do |f| %>
  <%= f.text_field :name %>
  <%= f.text_area :text %>
  <%= f.submit "Create" %>
<% end %>
```

## Count vs. Length

The behaviour of `count` and `length` is based on ActiveRecord's behaviour.

`count` Determine the number of elements by taking the number of total elements that is provided by the endpoint/api.

`length` This returns the number of elements loaded from an endpoint/api. In case of paginated resources this can be different to count, as it depends on how many pages have been loaded.

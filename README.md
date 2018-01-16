LHS
===

LHS uses [LHC](//github.com/local-ch/LHC) for http requests.

## Quickstart

```
gem 'lhs'
```

LHS comes with Request Cycle Cache – enabled by default. It requires [LHC Caching Interceptor](https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md) to be enabled:

```ruby
# intializers/lhc.rb
LHC.configure do |config|
  config.interceptors = [LHC::Caching]
end
```

## Very Short Introduction

Access data that is provided by an http JSON service with ease using a LHS::Record.

```ruby
class Record < LHS::Record

  endpoint '{+service}/v2/records'
  endpoint '{+service}/v2/association/{association_id}/records'

end

record = Record.find_by(email: 'somebody@mail.com') #<Record>
record.review # "Lunch was great"
```

## Where to store LHS::Records

Please store all defined LHS::Records in `app/models` as they are not auto loaded by rails otherwise.

## Endpoints

You setup a LHS::Record by configuring one or multiple endpoints. You can also add request options for an endpoint (see following example).

```ruby
class Record < LHS::Record

  endpoint '{+service}/v2/association/{association_id}/records'
  endpoint '{+service}/v2/association/{association_id}/records/{id}'
  endpoint '{+service}/v2/records', auth: { basic: 'PASSWORD' }
  endpoint '{+service}/v2/records/{id}', auth: { basic: 'PASSWORD' }

end
```

Please use placeholders when configuring endpoints also for hosts. Otherwise LHS will match them strictly, which can result in problems when mixing URLs containing `http`, `https` or no protocol at all.
[https://github.com/local-ch/lhc/blob/master/docs/configuration.md#placeholders](LHC Placeholder Configuration)

If you try to setup a LHS::Record with clashing endpoints it will immediately raise an exception.

```ruby
class Record < LHS::Record

  endpoint '{+service}/v2/records'
  endpoint '{+service}/v2/something_else'

end
# raises: Clashing endpoints.
```

## Find multiple records

You can query a service for records by using `where`.

```ruby
  Record.where(color: 'blue')
```

This uses the `{+service}/v2/records` endpoint, cause `{association_id}` was not provided. In addition it would add `?color=blue` to the get parameters.

```ruby
  Record.where(association_id: 'fq-a81ngsl1d')
```

Uses the `{+service}/v2/association/{association_id}/records` endpoint.

### Expand plain collection of links

Some endpoints could respond a plain list of links without any expanded data. Like search endpoints.
If you want to have LHS expand those items, use `expanded` as part of a Query-Chain:

```json
  {
    "items" : [
      {"href": "http://local.ch/customer/1/accounts/1"},
      {"href": "http://local.ch/customer/1/accounts/2"},
      {"href": "http://local.ch/customer/1/accounts/3"}
    ]
  }
end
```

```ruby
  Account.where(customer_id: 123).expanded
```

You can also apply options to `expanded` in order to apply anything on the requests made to expand the links:

```ruby
  Account.where(customer_id: 123).expanded(auth: { bearer: access_token })
```

## Chaining where statements

LHS supports chaining where statements.
That allows you to chain multiple where-queries:

```ruby
class Record < LHS::Record
  endpoint 'records/'
  endpoint 'records/{id}'
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

In order to make common where statements reusable you can organize them in scopes:

```ruby
class Record < LHS::Record
  endpoint 'records/'
  endpoint 'records/{id}'
  scope :blue, -> { where(color: 'blue') }
  scope :available, ->(state) { where(available: state) }
end

records = Record.blue.available(true)
The example would fetch records with the following parameters: `{color: blue, visible: true}`.
```

## Error handling with chains

One benefit of chains is lazy evaluation. This means they get resolved when data is accessed. This makes it hard to catch errors with normal `rescue` blocks.

To simplify error handling with chains, you can also chain error handlers to be resolved, as part of the chain.

In case no matching error handler is found the error gets re-raised.

```ruby
record = Record.where(color: 'blue')
  .handle(LHC::BadRequest, ->(error){ show_error })
  .handle(LHC::Unauthorized, ->(error){ authorize })
```

[List of possible error classes](https://github.com/local-ch/lhc/tree/master/lib/lhc/errors)

If an error handler returns `nil` an empty LHS::Record is returned, not `nil`!

In case you want to ignore errors and continue working with `nil` in those cases,
please use `ignore`:

```ruby
record = Record.ignore(LHC::NotFound).find_by(color: 'blue')
record # nil
```

## Resolve chains

LHS Chains can be resolved with `fetch`, similar to ActiveRecord:

```ruby
records = Record.where(color: 'blue').fetch
```

## Find single records

`find` finds a unique record by unique identifier (usually id or href).

```ruby
  Record.find(123)
  Record.find('https://api.example.com/records/123')
```

If no record is found an error is raised.

`find` can also be used to find a single unique record with parameters:

```ruby
  Record.find(association_id: 123, id: 456)
```

`find_by` finds the first record matching the specified conditions.

If no record is found, `nil` is returned.

`find_by!` raises LHC::NotFound if nothing was found.

```ruby
  Record.find_by(id: 'z12f-3asm3ngals')
  Record.find_by(id: 'doesntexist') # nil
```

`first` is an alias for finding the first record without parameters.

```ruby
  Record.first
```

If no record is found, `nil` is returned.

`first!` raises LHC::NotFound if nothing was found.

# Find multiple single records in parallel

In case you want to fetch multiple records by id in parallel, you can also do this with `find`:

```ruby
Record.find(1, 2, 3)
```

If you want to inject values for the failing records, that might not have been found, you can inject values for them with error handlers:

```ruby
data = Record
  .handle(LHC::Unauthorized, ->(response) { Record.new(name: 'unknown') })
  .find(1, 2, 3)
data[1].name # 'unknown'
```

## Navigate data

After fetching [single](#find-single-records) or [multiple](#find-multiple-records) records you can navigate the received data with ease.

```ruby
  records = Record.where(color: 'blue')
  records.collection? # true
  record = records.first
  record.item? # true
  record.parent == records # true
```

## Relations

Even though, nested data is automatically casted when accessed, see: [Nested records](#nested-records), sometimes api's don't provide dedicated endpoints to retrieve these records.

As those records also don't have an href, nested records can not be casted automatically, when accessed.

Those kind of relations, you can still configure manually:

```ruby

class Location < LHS::Record

  endpoint 'http://uberall/locations/{id}'

  has_many :listings

end

class Listing < LHS::Record

  def supported?
    type == 'SUPPORTED'
  end
end

Location.find(1).listings.first.supported? # true

```


## Request based options

You can apply options to the request chain. Those options will be forwarded to the request perfomed by the chain/query.

```ruby
  # Authenticate with OAuth
  options = { auth: { bearer: '123456' } }

  AuthenticatedRecord = Record.options(options)

  blue_records = AuthenticatedRecord.where(color: 'blue')
  active_records = AuthenticatedRecord.where(active: true)

  AuthenticatedRecord.create(color: 'red')

  record = AuthenticatedRecord.find(123)
  # Find resolves the current query and applies all options from the chain
  # All further requests are made from scratch and not based on the previous options
  record.name = 'Walter'

  authenticated_record = record.options(options)
  authenticated_record.valid?
  authenticated_record.save
  authenticated_record.destroy
  authenticated_record.update(name: 'Steve')
```

## Request Cycle Cache

By default, LHS does not perform the same http request during one request cycle multiple times.

It uses the [LHC Caching Interceptor](https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md) as caching mechanism base and sets a unique request id for every request cycle with Railties to ensure data is just cached within one request cycle and not shared with other requests.

Only GET requests are considered for caching by using LHC Caching Interceptor's `cache_methods` option internally and considers request headers when caching requests, so requests with different headers are not served from cache.

The LHS Request Cycle Cache is opt-out, so it's enabled by default and will require you to enable the [LHC Caching Interceptor](https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md) in your project.

If you want to disable the LHS Request Cycle Cache, simply disable it within configuration:

```ruby
LHS.config.request_cycle_cache_enabled = false
```

By default the LHS Request Cycle Cache will use `ActiveSupport::Cache::MemoryStore` as its cache store. Feel free to configure a cache that is better suited for your needs by:

```ruby
LHS.config.request_cycle_cache = ActiveSupport::Cache::MemoryStore.new
```

## Batch processing

**Be careful using methods for batch processing. They could result in a lot of HTTP requests!**

`all` fetches all records from the service by doing multiple requests and resolving endpoint pagination if necessary.

```ruby
data = Record.all
data.count # 998
data.length # 998
```

`all` is chainable and has the same interface like `where` (See: [Find multiple records](https://github.com/local-ch/lhs#find-multiple-records))

```ruby
Record.where(color: 'blue').all
Record.all.where(color: 'blue')
Record.all(color: 'blue')
# All three are doing the same thing: fetching all records with the color 'blue' from the endpoint while resolving pagingation if endpoint is paginated
```

In case an API does not provide pagination information (limit, offset and total), LHS keeps on loading pages when requesting `all` until the first empty page responds.

[Count vs. Length](#count-vs-length)

`find_each` is a more fine grained way to process single records that are fetched in batches.

```ruby
Record.find_each(start: 50, batch_size: 20, params: { has_reviews: true }) do |record|
  # Iterates over each record. Starts with record no. 50 and fetches 20 records each batch.
  record
  break if record.some_attribute == some_value
end
```

`find_in_batches` is used by `find_each` and processes batches.
```ruby
Record.find_in_batches(start: 50, batch_size: 20, params: { has_reviews: true }) do |records|
  # Iterates over multiple records (batch size is 20). Starts with record no. 50 and fetches 20 records each batch.
  records
  break if records.first.name == some_value
end
```

## Create records

```ruby
  record = Record.create(
    recommended: true,
    source_id: 'aaa',
    content_ad_id: '1z-5r1fkaj'
  )
```

See [Validation](#Validation) for handling validation errors when creating records.

## Create records through associations (nested resources)

```ruby
  class Review < LHS::Record
    endpoint '{+service}/reviews'
  end

  class Comment < LHS::Record
    endpoint '{+service}/reviews/{review_id/}comments'
  end
```

### Item
```ruby
  review = Review.find(1)
  # Review#1
  # :href => '{+service}/reviews/1
  # :text => 'Simply awesome'
  # :comment => { :href => '{+service}/reviews/1/comments }

  review.comment.create(text: 'Thank you!')
  # Comment#1
  # :href => '{+service}/reviews/1/comments
  # :text => 'Thank you!'

  review
  # Review#1
  # :href => '{+service}/reviews/1
  # :text => 'Simply awesome'
  # :comment => { :href => '{+service}/reviews/1/comments, :text => 'Thank you!' }
```

If the item already exists `ArgumentError` is raised.

### Expanded collection
```ruby
  review = Review.includes(:comments).find(1)
  # Review#1
  # :href => '{+service}/reviews/1'
  # :text => 'Simply awesome'
  # :comments => { :href => '{+service}/reviews/1/comments, :items => [] }

  review.comments.create(text: 'Thank you!')
  # Comment#1
  # :href => '{+service}/reviews/1/comments/1'
  # :text => 'Thank you!'

  review
  # Review#1
  # :href => '{+service}/reviews/1'
  # :text => 'Simply awesome'
  # :comments => { :href => '{+service}/reviews/1/comments, :items => [{ :href => '{+service}/reviews/1/comments/1', :text => 'Thank you!' }] }
```

### Not expanded collection
```ruby
  review = Review.find(1)
  # Review#1
  # :href => '{+service}/reviews/1'
  # :text => 'Simply awesome'
  # :comments => { :href => '{+service}/reviews/1/comments' }

  review.comments.create(text: 'Thank you!')
  # Comment#1
  # :href => '{+service}/reviews/1/comments/1'
  # :text => 'Thank you!'

  review
  # Review#1
  # :href => '{+service}/reviews/1
  # :text => 'Simply awesome'
  # :comments => { :href => '{+service}/reviews/1/comments', :items => [{ :href => '{+service}/reviews/1/comments/1', :text => 'Thank you!' }] }
```

## Build new records

Build and persist new items from scratch are done either with `new` or it's alias `build`.

```ruby
  record = Record.new(recommended: true)
  record.save
```

## Custom setters and getters

Sometimes it is the case that you want to have your custom getters and setters and convert the data to a processable format behind the scenes.
The initializer will now use custom setter if one is defined:

```ruby

module RatingsConversions
  def ratings=(values)
    super(
      values.map { |k, v| { name: k, value: v } }
    )
  end
end

class Record < LHS::Record
  prepend RatingsConversions
end

record = Record.new(ratings: { quality: 3 })
record.ratings # [{ :name=>:quality, :value=>3 }]

```

If you have an accompanying getter the whole data manipulation would be internal only.

```ruby
module RatingsConversions
  def ratings=(values)
    super(
      values.map { |k, v| { name: k, value: v } }
    )
  end

  def ratings
    super.map { |r| [r[:name], r[:value]] }]
  end
end

class Record < LHS::Record
  prepend RatingsConversions
end

record = Record.new(ratings: { quality: 3 }) # [{ :name=>:quality, :value=>3 }]
record.ratings # {:quality=>3}

```

## Include linked resources

When fetching records, you can specify in advance all the linked resources that you want to include in the results. With `includes` or `includes_all` (to enforce fetching all remote objects for paginated endpoints), LHS ensures that all matching and explicitly linked resources are loaded and merged.

The implementation is heavily influenced by [http://guides.rubyonrails.org/active_record_class_querying](http://guides.rubyonrails.org/active_record_class_querying.html#eager-loading-associations) and you should read it to understand this feature in all its glory.

### `includes_all` for paginated endpoints

In case endpoints are paginated and you are certain that you'll need all objects of a set and not only the first page/batch, use `includes_all`.

LHS will ensure that all linked resources are around by loading all pages (parallelized/performance optimized).

```ruby
customer = Customer.includes_all(contracts: :products).find(1)

# GET http://datastore/customers/1
# GET http://datastore/customers/1/contracts?limit=100
# GET http://datastore/customers/1/contracts?limit=10&offset=10
# GET http://datastore/customers/1/contracts?limit=10&offset=20
# GET http://datastore/products?limit=100
# GET http://datastore/products?limit=10&offset=10

customer.contracts.length # 33
customer.contracts.first.products.length # 22
```

### One-Level `includes`

```ruby
  # a claim has a localch_account
  claims = Claims.includes(:localch_account).where(place_id: 'huU90mB_6vAfUdVz_uDoyA')
  claims.first.localch_account.email # 'test@email.com'
```

Before include:
```json
{
  "href" : "http://datastore/v2/places/huU90mB_6vAfUdVz_uDoyA/claims",
  "items" : [
    {
      "href" : "http://datastore/v2/localch-accounts/6bSss0y93lK0MrVsgdNNdg/claims/huU90mB_6vAfUdVz_uDoyA",
      "localch_account" : {
        "href" : "http://datastore/v2/localch-accounts/6bSss0y93lK0MrVsgdNNdg"
      }
    }
  ]
}
```

After include:
```json
{
  "href" : "http://datastore/v2/places/huU90mB_6vAfUdVz_uDoyA/claims",
  "items" : [
    {
      "href" : "http://datastore/v2/localch-accounts/6bSss0y93lK0MrVsgdNNdg/claims/huU90mB_6vAfUdVz_uDoyA",
      "localch_account" : {
        "href" : "http://datastore/v2/localch-accounts/6bSss0y93lK0MrVsgdNNdg",
        "id" : "6bSss0y93lK0MrVsgdNNdg",
        "name" : "Myriam",
        "phone" : "12345678",
        "email" : "email@gmail.com"
      }
    }
  ]
}
```

### Two-Level `includes`

```ruby
  # a record has a association, which has an entry
  records = Record.includes(association: :entry).where(has_reviews: true)
  records.first.association.entry.name # 'Casa Ferlin'
```

### Multiple `includes`

```ruby
  # list of includes
  claims = Claims.includes(:localch_account, :entry).where(place_id: 'huU90mB_6vAfUdVz_uDoyA')

  # array of includes
  claims = Claims.includes([:localch_account, :entry]).where(place_id: 'huU90mB_6vAfUdVz_uDoyA')

  # Two-level with array of includes
  records = Record.includes(campaign: [:entry, :user]).where(has_reviews: true)
```

### Known LHS::Records are used to request linked resources

When including linked resources with `includes`, known/defined services and endpoints are used to make those requests.
That also means that options for endpoints of linked resources are applied when requesting those in addition.
This allows you to include protected resources (e.g. Basic auth) as endpoint options for oauth authentication get applied.

The [Auth Inteceptor](https://github.com/local-ch/lhc-core-interceptors#auth-interceptor) from [lhc-core-interceptors](https://github.com/local-ch/lhc-core-interceptors) is used to configure the following endpoints.

```ruby
class Favorite < LHS::Record

  endpoint '{+service}/{user_id}/favorites', auth: { basic: { username: 'steve', password: 'can' } }
  endpoint '{+service}/{user_id}/favorites/:id', auth: { basic: { username: 'steve', password: 'can' } }

end

class Place < LHS::Record

  endpoint '{+service}/v2/places', auth: { basic: { username: 'steve', password: 'can' } }
  endpoint '{+service}/v2/places/{id}', auth: { basic: { username: 'steve', password: 'can' } }

end

Favorite.includes(:place).where(user_id: current_user.id)
# Will include places and applies endpoint options to authenticate the request.
```

### Forward options used for request made to include referenced resources

Provide options to the requests made to include referenced resources:

```

  Favorite.includes(:place).references(place: { auth: { bearer: '123' }})

```

## Map data

To influence how data is accessed/provided, you can use mappings to either map deep nested data or to manipulate data when its accessed. Simply create methods inside the LHS::Record. They can access underlying data:

```ruby
class LocalEntry < LHS::Record
  endpoint ':service/v2/local-entries'

  def name
    addresses.first.business.identities.first.name
  end

end
```

## Nested records

Nested records (in nested data) are automatically casted when the href matches any defined endpoint of any LHS::Record.

```ruby
class Place < LHS::Record
  endpoint '{+service}/v2/places'

  def name
    addresses.first.business.identities.first.name
  end
end

class Favorite < LHS::Record
  endpoint '{+service}/v2/favorites'
end

favorite = Favorite.includes(:place).find(1)
favorite.place.name # local.ch AG
```

If automatic-detection of nested records does not work, make sure your LHS::Records are stored in `app/models`!

## Setters

You can change attributes of LHS::Records:

```ruby
  record = Record.find(id: 'z12f-3asm3ngals')
  rcord.recommended = false
```

## Save

You can persist changes with `save`. `save` will return `false` if persisting fails. `save!` instead will raise an exception.

```ruby
  record = Record.find('1z-5r1fkaj')
  record.recommended = false
  record.save
```

## Update

`update` will return false if persisting fails. `update!` instead will an raise exception.

`update` always updates the data of the local object first, before it tries to sync with an endpoint. So even if persisting fails, the local object is updated.

```ruby
record = Record.find('1z-5r1fkaj')
record.update(recommended: false)
```

## Partial Update

Often you just want to update a single attribute on an existing record. As ActiveRecord's `update_attribute` skips validation, which is unlikely with api services, and `update_attributes` is just an alias for `update`, LHS introduces `partial_update` for that matter.

`partial_update` will return false if persisting fails. `partial_update!` instead will an raise exception.

`partial_update` always updates the data of the local object first, before it tries to sync with an endpoint. So even if persisting fails, the local object is updated.

```ruby
record = Record.find('1z-5r1fkaj')
record.partial_update(recommended: false)
# POST /records/1z-5r1fkaj
{
  recommended: true
}
```

## Becomes

Based on [ActiveRecord's implementation](http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-becomes), LHS implements `becomes`, too.
It's a way to convert records of a certain type A to another certain type B.

_NOTE: RPC-style actions, that are discouraged in REST anyway, are utilizable with this functionality, too. See the following example:_

```ruby
class Location < LHS::Record
  endpoint 'http://sync/locations'
  endpoint 'http://sync/locations/{id}'
end

class Synchronization < LHS::Record
  endpoint 'http://sync/locations/{id}/sync'
end

location = Location.find(1)
synchronization = location.becomes(Synchronization)
synchronization.save!
```

## Destroy

You can delete records remotely by calling `destroy` on an LHS::Record.

```ruby
  record = Record.find('1z-5r1fkaj')
  record.destroy
```

You can also destroy records directly without fetching them first:

```ruby
  destroyed_record = Record.destroy('1z-5r1fkaj')
```

or with parameters:

```ruby
  destroyed_records = Record.destroy(name: 'Steve')
```

## Validation

In order to validate LHS::Records before persisting them, you can use the `valid?` (`validate` alias) method.

The specific endpoint has to support validations without persistence. An endpoint has to be enabled (opt-in) for validations in the service configuration.

```ruby
class User < LHS::Record
  endpoint '{+service}/v2/users', validates: { params: { persist: false } }
end

user = User.build(email: 'i\'m not an email address')
unless user.valid?
  fail(user.errors[:email])
end

user.errors #<LHS::Problems::Errors>
user.errors.include?(:email) # true
user.errors[:email] # ['REQUIRED_PROPERTY_VALUE']
user.errors.messages # {:email=>["Translated error message that this value is required"]}
user.errors.codes # {:email=>["REQUIRED_PROPERTY_VALUE"]}
user.errors.message # email must be set when user is created."
```

The parameters passed to the `validates` endpoint option are used to perform the validation:

```ruby
  endpoint '{+service}/v2/users', validates: { params: { persist: false } }  # will add ?persist=false to the request
  endpoint '{+service}/v2/users', validates: { params: { publish: false } }  # will add ?publish=false to the request
  endpoint '{+service}/v2/users', validates: { params: { validates: true } } # will add ?validates=true to the request
  endpoint '{+service}/v2/users', validates: { path: 'validate' }            # will perform a validation via :service/v2/users/validate
```

### HTTP Status Codes for validation errors

LHS provides the http status code received when performing validations on a record, through the errors object:

```ruby
record.save
record.errors.status_code #400
```

### Reset validation errors

Clear the error messages. Compatible with [ActiveRecord](https://github.com/rails/rails/blob/6c8cf21584ced73ade45529d11463c74b5a0c58f/activemodel/lib/active_model/errors.rb#L85).

```ruby
record.errors.clear
```

### Custom validation errors

In case you want to add custom validation errors to an instance of LHS::Record:

```ruby
user.errors.add(:name, 'The name you provided is not valid.')
```

### Validation errors for nested data

If you work with complex data structures, you sometimes need to have validation errors delegated/scoped to nested data.

This also makes LHS::Records compatible with how Rails or Simpleform renders/builds forms and especially error messages.

```ruby
# controller.rb
unless @customer.save
  @errors = @customer.errors
end

# view.html
= form_for @customer, as: :customer do |customer_form|

  = fields_for 'customer[:address]', @customer.address, do |address_form|

    = fields_for 'customer[:address][:street]', @customer.address.street, do |street_form|

      = street_form.input :name
      = street_form.input :house_number
```

Would render nested forms and would also render nested form errors for nested data structures.

You can also access those nested errors like:

```ruby
@customer.address.errors
@customer.address.street.errors
```

### Translation of validation errors

Just like Activerecord, LHS tries to translate validation error messages.
If a translation exists for one of the following translation keys, LHS will take a translated error (also in the following order) rather than the plain error message/code:

```ruby
lhs.errors.records.customer.attributes.name.unsupported_property_value
lhs.errors.records.customer.unsupported_property_value
lhs.errors.messages.unsupported_property_value
lhs.errors.attributes.name.unsupported_property_value
lhs.errors.fallback_message
```

### Know issue with `ActiveModel::Validations`
If you are using `ActiveModel::Validations` and add errors to the LHS::Record instance - as described above - then those errors will be overwritten by the errors from `ActiveModel::Validations` when using `save`  or `valid?`. [Open issue](https://github.com/local-ch/lhs/issues/159)

### Blocking errors, original "errors"

The fact that records could have errors is not coupled to any response status code.

LHS makes errors accessible, if they are present:

```
  {
    company_name: 'localsearch',
    field_errors: [{
      code: 'REQUIRED_PROPERTY_VALUE',
      path: ['place', 'opening_hours']
    }
  }
```

LHS makes those errors available when accessing `.errors`:

```ruby
  presence = Presence.create(
    place: { href: 'http://storage/places/1' }
  )

  presence.errors.any? # true
  presence.place.errors.messages[:opening_hours] # ['This field needs to be present']
  presence.place.errors.codes[:opening_hours] # ['REQUIRED_PROPERTY_VALUE']
```

### Non blocking validation errors, so called warnings

In some cases, you need non blocking meta information about potential problems with the created record, so called warnings.

If the API endpoint implements warnings:

```
  {
    field_warnings: [{
      code: 'WILL_BE_RESIZED',
      path: ['place', 'photos', 0],
      message: 'The image will be resized.'
    }
  }
```

LHS makes those warnings available:

```ruby
  presence = Presence.options(params: { synchronize: false }).create(
    place: { href: 'http://storage/places/1' }
  )

  presence.warnings.any? # true
  presence.place.photos[0].warnings.messages.first # 'The photos will be resized'
```

Warnings behave like [Validation Errors](#Validation) and implements the same interfaces and methods.

## Pagination

LHS supports paginated APIs and it also supports various pagination strategies and by providing configuration possibilities.

LHS differentiates between the *pagination strategy* (how items/pages are navigated) itself and *pagination keys* (how stuff is named).

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

In case of paginated resources it's important to know the difference between [count vs. length](#count-vs-length)

## Configuration of Records

```ruby
class Search < LHS::Record
  configuration items_key: 'searchResults', total_key: 'total', limit_key: 'limit', pagination_key: 'offset', pagination_strategy: 'offset'
  endpoint 'https://search'
end
```

`item_key` key used to unwrap the actual object from within the response body.

`items_key` key used to determine items of the current page (e.g. `docs`, `items`, etc.).

`item_created_key` key used to merge record data thats nested in the creation response body.

`limit_key` key used to work with page limits (e.g. `size`, `limit`, etc.)

In case the `limit_key` parameter differs for where it's located in the body and how it's provided as get parameter, when retreiving pages, provide a hash with `body` and `parameter` key, to keep those two use cases separated:

```ruby
  configuration limit_key: { body: [:response, :max], parameter: :max }
```

`pagination_key` key used to paginate multiple pages (e.g. `offset`, `page`, `startAt` etc.).

In case the `pagination_key` parameter differs for where it's located in the body and how it's provided as get parameter, when retreiving pages, provide a hash with `body` and `parameter` key, to keep those two use cases separated:

```ruby
  configuration pagination_key: { body: [:response, :page], parameter: :page }
```

`pagination_strategy` used to configure the strategy used for navigating (e.g. `offset`, `page`, `start`, etc.).

`total_key` key used to determine the total amount of items (e.g. `total`, `totalResults`, etc.).

### Unwrap nested items

```json
{
  "response": {
    "location": {
      "id": 123
    }
  }
}
```

```ruby
class Location < LHS::Record
  configuration item_key: [:response, :location]
end

location = Location.find(123)
location.id # 123
```

### Configure complex accessors for nested data

If items, limit, pagination, total etc. is nested in the responding objects, use complex data structures for configuring a record.

```
  response: {
    offset: 0,
    max: 50,
    count: 1,
    businesses: [
      {}
    ]
  }
```

```ruby
  class Business < LHS::Record
    configuration items_key: [:response, :businesses], limit_key: [:response, :max], pagination_key: [:response, :offset], total_key: [:response, :count], pagination_strategy: :offset
    endpoint 'http://uberall/businesses'
  end
```

If record data after creation is nested in the response body, configure the record, so that it gets properl merged with the your record instance:

```
POST /businesses
  response: {
    business: {
      id: 123
    }
  }
```

```ruby
  class Business < LHS::Record
    configuration item_created_key: [:response, :business]
    endpoint 'http://uberall/businesses'
  end

  business = Business.create(name: 'localsearch')
  business.id # 123
```

### Pagination Chains

You can use chainable pagination in combination with query chains:

```ruby
  class Record < LHS::Record
    endpoint ':service/records'
  end
  Record.page(3).per(20).where(color: 'blue')
  # /records?offset=40&limit=20&color=blue
```

The applied pagination strategy depends on the actual configured pagination, so the interface is the same for all strategies:

```ruby
  class Record < LHS::Record
    endpoint '{+service}/records'
    configuration pagination_strategy: 'page'
  end
  Record.page(3).per(20).where(color: 'blue')
  # /records?page=3&limit=20&color=blue
```

```ruby
  class Record < LHS::Record
    endpoint '{+service}/records'
    configuration pagination_strategy: 'start'
  end
  Record.page(3).per(20).where(color: 'blue')
  # /records?start=41&limit=20&color=blue
```

`limit(argument)` is an alias for `per(argument)`. Take notice that `limit` without argument instead, makes the query resolve and provides the current limit from the responds.

### Partial Kaminari support

LHS implements an interface that makes it partially working with Kaminari.

The kaminari’s page parameter is in params[:page]. For example, you can use kaminari to render paginations based on LHS Records. Typically, your code will look like this:

```ruby
# controller
@items = Record.page(params[:page]).per(100)
```

```ruby
# view
= paginate @items
```

### Pagination Links

When endpoints provide indicators for current page position with links (like `next` and `previous`), LHS provides some functionalities to interact/use those links/information:

`next?` Tells you if there is a next link or not.

`previous?` Tells you if there is a previous link or not.


## Automatic Detection of Collections

How to configure endpoints for automatic collection detection?

LHS detects automatically if the responded data is a single business object or a set of business objects (collection).

Conventionally, when the responds contains an `items` key `{ items: [] }` it's treated as a collection, but also if the responds contains a plain raw array: `[{ href: '' }]` it's also treated as a collection.

In case the responds uses another key than `items`, you can configure it within an `LHS::Record`:

```ruby
class Results < LHS::Record
  configuration items_key: 'docs'
end
```

## form_for Helper
Rails `form_for` view-helper can be used in combination with instances of LHS::Record to autogenerate forms:
```ruby
<%= form_for(@instance, url: '/create') do |f| %>
  <%= f.text_field :name %>
  <%= f.text_area :text %>
  <%= f.submit "Create" %>
<% end %>
```

## Count vs. Length

The behavior of `count` and `length` is based on ActiveRecord's behavior.

`count` Determine the number of elements by taking the number of total elements that is provided by the endpoint/api.

`length` This returns the number of elements loaded from an endpoint/api. In case of paginated resources this can be different to count, as it depends on how many pages have been loaded.

## Inheritance

You can inherit from previously defined records and also inherit endpoints that way:

```
class Base < LHS::Record
  endpoint 'records/{id}'
end

class Example < Base
end

Example.find(1) # GET records/1
```

## Testing: How to write tests when using LHS

[WebMock](https://github.com/bblimke/webmock)!

Best practice is to let LHS fetch your records and Webmock to stub/mock endpoints responses.
This follows the [Black Box Testing](https://en.wikipedia.org/wiki/Black-box_testing) approach and prevents you from building up constraints to LHS' internal structures/mechanisms, which will break when we change internal things.
LHS provides interfaces that result in HTTP requests, this is what you should test.

```ruby
let(:contracts) do
  [
    {number: '1'},
    {number: '2'},
    {number: '3'}
  ]
end

before(:each) do
  stub_request(:get, "http://datastore/user/:id/contracts")
    .to_return(
      body: {
        items: contracts,
        limit: 10,
        total: contracts.length,
        offset: 0
      }.to_json
    )
end

it 'displays contracts' do
  visit 'contracts'
  contracts.each do |contract|
    expect(page).to have_content(contract[:number])
  end
end
```

## Test support (caching)

Add to your spec_helper.rb:

```ruby
  require 'lhs/test/request_cycle_cache_helper'
```

This will initialize a MemoryStore cache for LHC::Caching interceptor and resets the cache before every test.

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

## License

[GNU Affero General Public License Version 3.](https://www.gnu.org/licenses/agpl-3.0.en.html)

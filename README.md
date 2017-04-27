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

Access data that is provided by an http json service with ease using a LHS::Record.

```ruby
class Record < LHS::Record

  endpoint ':service/v2/records'
  endpoint ':service/v2/association/:association_id/records'

end

record = Record.find_by(email: 'somebody@mail.com') #<Record>
record.review # "Lunch was great"
```

## Where to store LHS::Records

Please store all defined LHS::Records in `app/models` as they are not autoloaded by rails otherwise.

## Endpoints

You setup a LHS::Record by configuring one or multiple endpoints. You can also add request options for an endpoint (see following example).

```ruby
class Record < LHS::Record

  endpoint ':service/v2/association/:association_id/records'
  endpoint ':service/v2/association/:association_id/records/:id'
  endpoint ':service/v2/records', auth: { basic: 'PASSWORD' }
  endpoint ':service/v2/records/:id', auth: { basic: 'PASSWORD' }

end
```

Please use placeholders when configuring endpoints also for hosts. Otherwise LHS will match them strictly, which can result in problems when mixing URLs containing `http`, `https` or no protocol at all.
[https://github.com/local-ch/lhc/blob/master/docs/configuration.md#placeholders](LHC Placeholder Configuration)

If you try to setup a LHS::Record with clashing endpoints it will immediately raise an exception.

```ruby
class Record < LHS::Record

  endpoint ':service/v2/records'
  endpoint ':service/v2/something_else'

end
# raises: Clashing endpoints.
```

## Find multiple records

You can query a service for records by using `where`.

```ruby
  Record.where(color: 'blue')
```

This uses the `:service/v2/records` endpoint, cause `:association_id` was not provided. In addition it would add `?color=blue` to the get parameters.

```ruby
  Record.where(association_id: 'fq-a81ngsl1d')
```

Uses the `:service/v2/association/:association_id/records` endpoint.

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

## Error handling with chains

One benefit of chains is lazy evaluation. This means they get resolved when data is accessed. This makes it hard to catch errors with normal `rescue` blocks.

To simplify error handling with chains, you can also chain error handlers to be resolved, as part of the chain.

In case no matchin error handler is found the error gets re-raised.

```ruby
record = Record.where(color: 'blue')
  .handle(LHC::BadRequest, ->(error){ show_error })
  .handle(LHC::Unauthorized, ->(error){ authorize })
```

[List of possible error classes](https://github.com/local-ch/lhc/tree/master/lib/lhc/errors)

## Find single records

`find` finds a unique record by unique identifier (usualy id or href).

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

Only GET requests are considered for caching by using LHC Caching Interceptor's `cache_methods` option internaly and considers request headers when caching requests, so requests with different headers are not served from cache.

The LHS Request Cycle Cache is opt-out, so it's enabled by default and will require you to enable the [LHC Caching Interceptor](https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md) in your project.

If you want to disable the LHS Request Cycle Cache, simply disable it within configuration:

```ruby
LHS.config.request_cycle_cache_enabled = false
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

[Count vs. Length](#count-vs-length)

`find_each` is a more fine grained way to process single records that are fetched in batches.

```ruby
Record.find_each(start: 50, batch_size: 20, params: { has_reviews: true }) do |record|
  # Iterates over each record. Starts with record nr. 50 and fetches 20 records each batch.
  record
  break if record.some_attribute == some_value
end
```

`find_in_batches` is used by `find_each` and processes batches.
```ruby
Record.find_in_batches(start: 50, batch_size: 20, params: { has_reviews: true }) do |records|
  # Iterates over multiple records (batch size is 20). Starts with record nr. 50 and fetches 20 records each batch.
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
    endpoint ':service/reviews'
  end

  class Comment < LHS::Record
    endpoint ':service/reviews/:review_id/comments'
  end
```

### Item
```ruby
  review = Review.find(1)
  # Review#1
  # :href => ':service/reviews/1
  # :text => 'Simply awesome'
  # :comment => { :href => ':service/reviews/1/comments }

  review.comment.create(text: 'Thank you!')
  # Comment#1
  # :href => ':service/reviews/1/comments
  # :text => 'Thank you!'

  review
  # Review#1
  # :href => ':service/reviews/1
  # :text => 'Simply awesome'
  # :comment => { :href => ':service/reviews/1/comments, :text => 'Thank you!' }
```

If the item already exists `ArgumentError` is raised.

### Expanded collection
```ruby
  review = Review.includes(:comments).find(1)
  # Review#1
  # :href => ':service/reviews/1'
  # :text => 'Simply awesome'
  # :comments => { :href => ':service/reviews/1/comments, :items => [] }

  review.comments.create(text: 'Thank you!')
  # Comment#1
  # :href => ':service/reviews/1/comments/1'
  # :text => 'Thank you!'

  review
  # Review#1
  # :href => ':service/reviews/1'
  # :text => 'Simply awesome'
  # :comments => { :href => ':service/reviews/1/comments, :items => [{ :href => ':service/reviews/1/comments/1', :text => 'Thank you!' }] }
```

### Not expanded collection
```ruby
  review = Review.find(1)
  # Review#1
  # :href => ':service/reviews/1'
  # :text => 'Simply awesome'
  # :comments => { :href => ':service/reviews/1/comments' }

  review.comments.create(text: 'Thank you!')
  # Comment#1
  # :href => ':service/reviews/1/comments/1'
  # :text => 'Thank you!'

  review
  # Review#1
  # :href => ':service/reviews/1
  # :text => 'Simply awesome'
  # :comments => { :href => ':service/reviews/1/comments', :items => [{ :href => ':service/reviews/1/comments/1', :text => 'Thank you!' }] }
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

  endpoint ':service/:user_id/favorites', auth: { basic: { username: 'steve', password: 'can' } }
  endpoint ':service/:user_id/favorites/:id', auth: { basic: { username: 'steve', password: 'can' } }

end

class Place < LHS::Record

  endpoint ':service/v2/places', auth: { basic: { username: 'steve', password: 'can' } }
  endpoint ':service/v2/places/:id', auth: { basic: { username: 'steve', password: 'can' } }

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

To influence how data is accessed/provied, you can use mappings to either map deep nested data or to manipulate data when its accessed. Simply create methods inside the LHS::Record. They can access underlying data:

```ruby
class LocalEntry < LHS::Record
  endpoint ':service/v2/local-entries'

  def name
    addresses.first.business.identities.first.name
  end

end
```

### Nested records

Nested records (in nested data) are automaticaly casted when the href matches any defined endpoint of any LHS::Record.

```ruby
class Place < LHS::Record
  endpoint ':service/v2/places'

  def name
    addresses.first.business.identities.first.name
  end
end

class Favorite < LHS::Record
  endpoint ':service/v2/favorites'
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

The specific endpoint has to support validations without peristance. An endpoint has to be enabled (opt-in) for validations in the service configuration.

```ruby
class User < LHS::Record
  endpoint ':service/v2/users', validates: { params: { persist: false } }
end

user = User.build(email: 'im not an email address')
unless user.valid?
  fail(user.errors[:email])
end

user.errors #<LHS::Errors>
user.errors.include?(:email) # true
user.errors[:email] # ['REQUIRED_PROPERTY_VALUE']
user.errors.messages # {:email=>["REQUIRED_PROPERTY_VALUE"]}
user.errors.message # email must be set when user is created."
```

The parameters passed to the `validates` endpoint option are used to perform the validation:

```ruby
  endpoint ':service/v2/users', validates: { params: { persist: false } }  # will add ?persist=false to the request
  endpoint ':service/v2/users', validates: { params: { publish: false } }  # will add ?publish=false to the request
  endpoint ':service/v2/users', validates: { params: { validates: true } } # will add ?validates=true to the request
  endpoint ':service/v2/users', validates: { path: 'validate' }            # will perform a validation via :service/v2/users/validate
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

### Know issue with `ActiveModel::Validations`
If you are using `ActiveModel::Validations` and add errors to the LHS::Record instance - as described above - then those errors will be overwritten by the errors from `ActiveModel::Validations` when using `save`  or `valid?`. [Open issue](https://github.com/local-ch/lhs/issues/159)

## Pagination

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
    endpoint ':service/records'
    configuration pagination_strategy: 'page'
  end
  Record.page(3).per(20).where(color: 'blue')
  # /records?page=3&limit=20&color=blue
```

```ruby
  class Record < LHS::Record
    endpoint ':service/records'
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

LHS detects autmatically if the responded data is a single business object or a set of business objects (collection).

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

The behaviour of `count` and `length` is based on ActiveRecord's behaviour.

`count` Determine the number of elements by taking the number of total elements that is provided by the endpoint/api.

`length` This returns the number of elements loaded from an endpoint/api. In case of paginated resources this can be different to count, as it depends on how many pages have been loaded.

## Inheritance

You can inherit from previously defined records and also inherit endpoints that way:

```
class Base < LHS::Record
  endpoint 'records/:id'
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

mLHS
===

LHS uses [LHC](//github.com/local-ch/LHC) for advanced http requests.

## Quickstart

```
gem 'lhs'
```

```ruby
# config/initializers/lhc.rb

LHC.configure do |config|
  config.placeholder(:service, 'https://my.service.dev')
end
```

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+service}/records'
  endpoint '{+service}/records/{id}'

end
```

```ruby
# app/controllers/application_controller.rb

record = Record.find_by(email: 'somebody@mail.com')
record.review # "Lunch was great
```

## Table of contents
   * [LHS](#lhs)
      * [Quickstart](#quickstart)
      * [Table of contents](#table-of-contents)
      * [Installation/Startup checklist](#installationstartup-checklist)
      * [Record](#record)
         * [Endpoints](#endpoints)
            * [Configure endpoint hosts](#configure-endpoint-hosts)
            * [Ambiguous endpoints](#ambiguous-endpoints)
         * [Record inheritance](#record-inheritance)
         * [Find multiple records](#find-multiple-records)
            * [where](#where)
            * [Reuse/Dry where statements: Use scopes](#reusedry-where-statements-use-scopes)
            * [Retrieve the amount of a collection of items: count vs. length](#retrieve-the-amount-of-a-collection-of-items-count-vs-length)
         * [Find single records](#find-single-records)
            * [find](#find)
            * [find_by](#find_by)
            * [first](#first)
            * [last](#last)
         * [Work with retrieved data](#work-with-retrieved-data)
            * [Automatic detection/conversion of collections](#automatic-detectionconversion-of-collections)
            * [Map complex data for easy access](#map-complex-data-for-easy-access)
            * [Access and identify nested records](#access-and-identify-nested-records)
               * [Relations / Associations](#relations--associations)
                  * [has_many](#has_many)
                  * [has_one](#has_one)
            * [Unwrap nested items from the response body](#unwrap-nested-items-from-the-response-body)
            * [Determine collections from the response body](#determine-collections-from-the-response-body)
         * [Chain complex queries](#chain-complex-queries)
            * [Chain where queries](#chain-where-queries)
            * [Expand plain collections of links: expanded](#expand-plain-collections-of-links-expanded)
            * [Error handling with chains](#error-handling-with-chains)
            * [Resolve chains: fetch](#resolve-chains-fetch)
            * [Add request options to a query chain: options](#add-request-options-to-a-query-chain-options)
            * [Control pagination within a query chain](#control-pagination-within-a-query-chain)
         * [Record pagination](#record-pagination)
            * [Pagination strategy](#pagination-strategy)
               * [Pagination strategy: offset (default)](#pagination-strategy-offset-default)
               * [Pagination strategy: page](#pagination-strategy-page)
               * [Pagination strategy: start](#pagination-strategy-start)
            * [Pagination keys](#pagination-keys)
               * [limit_key](#limit_key)
               * [pagination_key](#pagination_key)
               * [total_key](#total_key)
            * [Pagination links](#pagination-links)
               * [next?](#next)
               * [previous?](#previous)
            * [Kaminari support (limited)](#kaminari-support-limited)
         * [Build, create and update records](#build-create-and-update-records)
            * [Create new records](#create-new-records)
               * [create](#create)
                  * [Unwrap nested data when creation response nests created record data](#unwrap-nested-data-when-creation-response-nests-created-record-data)
                  * [Create records through associations: Nested sub resources](#create-records-through-associations-nested-sub-resources)
            * [Start building new records](#start-building-new-records)
            * [Change/Update existing records](#changeupdate-existing-records)
               * [save](#save)
               * [update](#update)
               * [partial_update](#partial_update)
            * [Endpoint url parameter injection during record creation/change](#endpoint-url-parameter-injection-during-record-creationchange)
            * [Record validation](#record-validation)
               * [Configure record validations](#configure-record-validations)
               * [HTTP Status Codes for validation errors](#http-status-codes-for-validation-errors)
               * [Reset validation errors](#reset-validation-errors)
               * [Add validation errors](#add-validation-errors)
               * [Validation errors for nested data](#validation-errors-for-nested-data)
               * [Translation of validation errors](#translation-of-validation-errors)
               * [Validation error types: errors vs. warnings](#validation-error-types-errors-vs-warnings)
                  * [Persistance failed: errors](#persistance-failed-errors)
                  * [Persistance succeeded: warnings](#persistance-succeeded-warnings)
               * [Using ActiveModel::Validations none the less](#using-activemodelvalidations-none-the-less)
            * [Use form_helper to create and update records](#use-form_helper-to-create-and-update-records)
         * [Destroy records](#destroy-records)
         * [Record getters and setters](#record-getters-and-setters)
            * [Record setters](#record-setters)
            * [Record getters](#record-getters)
         * [Include linked resources (hyperlinks and hypermedia)](#include-linked-resources-hyperlinks-and-hypermedia)
            * [Ensure the whole linked collection is included: includes_all](#ensure-the-whole-linked-collection-is-included-includes_all)
            * [Include the first linked page or single item is included: include](#include-the-first-linked-page-or-single-item-is-included-include)
            * [Include various levels of linked data](#include-various-levels-of-linked-data)
            * [Identify and cast known records when including records](#identify-and-cast-known-records-when-including-records)
            * [Apply options for requests performed to fetch included records](#apply-options-for-requests-performed-to-fetch-included-records)
         * [Record batch processing](#record-batch-processing)
            * [all](#all)
               * [Using all, when endpoint does not implement response pagination meta data](#using-all-when-endpoint-does-not-implement-response-pagination-meta-data)
            * [find_each](#find_each)
            * [find_in_batches](#find_in_batches)
         * [Convert/Cast specific record types: becomes](#convertcast-specific-record-types-becomes)
      * [Request Cycle Cache](#request-cycle-cache)
         * [Change store for LHS' request cycle cache](#change-store-for-lhs-request-cycle-cache)
         * [Disable request cycle cache](#disable-request-cycle-cache)
      * [Testing with LHS](#testing-with-lhs)
         * [Test helper for request cycle cache](#test-helper-for-request-cycle-cache)
         * [Test query chains](#test-query-chains)
            * [By explicitly resolving the chain: fetch](#by-explicitly-resolving-the-chain-fetch)
            * [Without resolving the chain: where_values_hash](#without-resolving-the-chain-where_values_hash)
      * [License](#license)

## Installation/Startup checklist

- [ ] Install LHS gem, preferably via `Gemfile`
- [ ] Configure [LHC](https://github.com/local-ch/lhc) via an `config/initializers/lhc.rb` (See: https://github.com/local-ch/lhc#configuration)
- [ ] Add `LHC::Caching` to `LHC.config.interceptors` to facilitate LHS' [Request Cycle Cache](#request-cycle-cache)
- [ ] Store all LHS::Records in `app/models` for autoload/preload reasons
- [ ] Request data from services via `LHS` from within your rails controllers

## Record

### Endpoints

> Endpoint, the entry point to a service, a process, or a queue or topic destination in service-oriented architecture

Start a record with configuring one or multiple endpoints.

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+service}/records'
  endpoint '{+service}/records/{id}'
  endpoint '{+service}/accociation/{accociation_id}/records'
  endpoint '{+service}/accociation/{accociation_id}/records/{id}'

end
```

You can also add request options to be used with configured endpoints:

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+service}/records', auth: { bearer: -> { access_token } }
  endpoint '{+service}/records/{id}', auth: { bearer: -> { access_token } }

end
```

-> Check [LHC](https://github.com/local-ch/lhc) for more information about request options

#### Configure endpoint hosts

It's common practice to use different hosts accross different environments in a service-oriented architecture.

Use [LHC placeholders](https://github.com/local-ch/lhc#configuring-placeholders) to configure different hosts per environment:

```ruby
# config/initializers/lhc.rb

LHC.configure do |config|
  config.placeholder(:search, ENV['SEARCH'])
end
```

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+search}/api/search.json'

end
```

**DON'T!**

Please DO NOT mix host placeholders with and endpoint's resource path, as otherwise LHS will not work properly.

```ruby
# config/initializers/lhc.rb

LHC.configure do |config|
  config.placeholder(:search, 'http://tel.search.ch/api/search.json')
end
```

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+search}'
  
end
```

#### Ambiguous endpoints

If you try to setup a Record with ambiguous endpoints, LHS will immediately raise an exception:

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+service}/records'
  endpoint '{+service}/bananas'

end

# raises: Ambiguous endpoints
```

### Record inheritance

You can inherit from previously defined records and also inherit endpoints that way:

```ruby
# app/models/base.rb

class Base < LHS::Record
  endpoint '{+service}/records/{id}'
end
```

```ruby
# app/models/record.rb

class Record < Base
end
```

```ruby
# app/controllers/some_controller.rb

Record.find(1)
```
```
GET https://service.example.com/records/1
```

### Find multiple records

#### fetch

In case you want to just fetch the records endpoint, without applying any further queries, you can simply call `fetch`:

```ruby
# app/controllers/some_controller.rb

records = Record.fetch

```
```
  GET https://service.example.com/records
```

#### where

You can query a service for records by using `where`:

```ruby
# app/controllers/some_controller.rb

Record.where(color: 'blue')

```
```
  GET https://service.example.com/records?color=blue
```

If the provided parameter – `color: 'blue'` in this case – is not part of the endpoint path, it will be added as query parameter.

```ruby
# app/controllers/some_controller.rb

Record.where(accociation_id: '12345')

```
```
GET https://service.example.com/accociation/12345/records
```

If the provided parameter – `accociation_id` in this case – is part of the endpoint path, it will be injected into the path:

#### Reuse/Dry where statements: Use scopes

In order to reuse/dry where statements organize them in scopes:

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+service}/records'
  endpoint '{+service}/records/{id}'

  scope :blue, -> { where(color: 'blue') }
  scope :available, ->(state) { where(available: state) }

end
```

```ruby
# app/controllers/some_controller.rb

records = Record.blue.available(true)
```
```
GET https://service.example.com/records?color=blue&available=true
```

#### all

You can fetch all remote records by using `all`. Pagination will be performed automatically (See: [Record pagination](#record-pagination))

```ruby
# app/controllers/some_controller.rb

records = Record.all

```
```
  GET https://service.example.com/records?limit=100
  GET https://service.example.com/records?limit=100&offset=100
  GET https://service.example.com/records?limit=100&offset=200
```

```ruby
# app/controllers/some_controller.rb

records.size # 300

```

#### all with unpaginated endpoints

In case your record endpoints are not implementing any pagination, configure it to be `paginated: false`. Pagination will not be performed automatically in those cases:

```ruby
# app/models/record.rb

class Record < LHS::Record
  configuration paginated: false
end

```

```ruby
# app/controllers/some_controller.rb

records = Record.all

```
```
  GET https://service.example.com/records
```

#### Retrieve the amount of a collection of items: count vs. length

The different behavior of `count` and `length` is based on ActiveRecord's behavior.

`count` The total number of items available remotly via the provided endpoint/api, communicated via pagination meta data.

`length` The number of items already loaded from the endpoint/api and kept in memmory right now. In case of a paginated endpoint this can differ to what `count` returns, as it depends on how many pages have been loaded already.

### Find single records

#### find

`find` finds a unique record by unique identifier (usually `id` or `href`). If no record is found an error is raised.

```ruby
Record.find(123)
```
```
GET https://service.example.com/records/123
```

```ruby
Record.find('https://anotherservice.example.com/records/123')
```
```
GET https://anotherservice.example.com/records/123
```

`find` can also be used to find a single unique record with parameters:

```ruby
Record.find(another_identifier: 456)
```
```
GET https://service.example.com/records?another_identifier=456
```

You can also fetch multiple records by `id` in parallel:

```ruby
Record.find(1, 2, 3)
```
```
# In parallel:
  GET https://service.example.com/records/1
  GET https://service.example.com/records/2
  GET https://service.example.com/records/3
```

#### find_by

`find_by` finds the first record matching the specified conditions. If no record is found, `nil` is returned.

`find_by!` raises `LHC::NotFound` if nothing was found.

```ruby
Record.find_by(color: 'blue')
```
```
GET https://service.example.com/records?color=blue
```

#### first

`first` is an alias for finding the first record without parameters. If no record is found, `nil` is returned.

`first!` raises `LHC::NotFound` if nothing was found.

```ruby
Record.first
```
```
GET https://service.example.com/records?limit=1
```

`first` can also be used with options:

```ruby
Record.first(params: { color: :blue })
```
```
GET https://service.example.com/records?color=blue&limit=1
```

#### last

`last` is an alias for finding the last record without parameters. If no record is found, `nil` is returned.

`last!` raises `LHC::NotFound` if nothing was found.

```ruby
Record.last
```

`last` can also be used with options:

```ruby
Record.last(params: { color: :blue })
```

### Work with retrieved data

After fetching [single](#find-single-records) or [multiple](#find-multiple-records) records you can navigate the received data with ease:

```ruby
records = Record.where(color: 'blue')
records.length # 4
records.count # 400
record = records.first
record.type # 'Business'
record[:type] # 'Business'
record['type'] # 'Business'
```

#### Automatic detection/conversion of collections

How to configure endpoints for automatic collection detection?

LHS detects automatically if the responded data is a single business object or a set of business objects (collection).

Conventionally, when the responds contains an `items` key `{ items: [] }` it's treated as a collection, but also if the responds contains a plain raw array: `[{ href: '' }]` it's also treated as a collection.

If you need to configure the attribute of the response providing the collection, configure `items_key` as explained here: (Determine collections from the response body)[#determine-collections-from-the-response-body]

#### Map complex data for easy access

To influence how data is accessed, simply create methods inside your Record to access complex data structures:

```ruby
# app/models/record.rb

class Record < LHS::Record

  endpoint '{+service}/records'

  def name
    dig(:addresses, :first, :business, :identities, :first, :name)
  end
end
```

#### Access and identify nested records

Nested records, in nested data, are automatically casted to the correct Record class, when they provide an `href` and that `href` matches any defined endpoint of any defined Record:

```ruby
# app/models/place.rb

class Place < LHS::Record
  endpoint '{+service}/places'
  endpoint '{+service}/places/{id}'

  def name
    dig(:addresses, :first, :business, :identities, :first, :name)
  end
end
```

```ruby
# app/models/favorite.rb

class Favorite < LHS::Record
  endpoint '{+service}/favorites'
  endpoint '{+service}/favorites/{id}'
end
```

```ruby
# app/controllers/some_controller.rb

favorite = Favorite.includes(:place).find(123)
favorite.place.name # local.ch AG
```
```
GET https://service.example.com/favorites/123

{... place: { href: 'https://service.example.com/places/456' }}

GET https://service.example.com/places/456
```

If automatic detection of nested records does not work, make sure your Records are stored in `app/models`! See: (Insallation/Startup checklist)[#installation-startup-checklist]

##### Relations / Associations

Typically nested data is automatically casted when accessed (See: [Access and identify nested records](#access-and-identify-nested-records)), but sometimes API's don't provide dedicated endpoints to retrieve these records.
In those cases, those records are only available through other records and don't have an `href` on their own and can't be casted automatically, when accessed. 

To be able to implement Record-specific logic for those nested records, you can define relations/associations.

###### has_many

```ruby
# app/models/location.rb

class Location < LHS::Record

  endpoint '{+service}/locations/{id}'

  has_many :listings

end
```

```ruby
# app/models/listing.rb

class Listing < LHS::Record

  def supported?
    type == 'SUPPORTED'
  end
end
```

```ruby
# app/controllers/some_controller.rb

Location.find(1).listings.first.supported? # true
```
```
GET https://service.example.com/locations/1
{... listings: [{ type: 'SUPPORTED' }] }
```

`class_name`: Specify the class name of the relation. Use it only if that name can't be inferred from the relation name. So has_many :photos will by default be linked to the Photo class, but if the real class name is e.g. CustomPhoto or namespaced Custom::Photo, you'll have to specify it with this option.

```ruby
# app/models/custom/location.rb

module Custom
  class Location < LHS::Record
    endpoint '{+service}/locations'
    endpoint '{+service}/locations/{id}'
    
    has_many :photos, class_name: 'Custom::Photo'
  end
end
```

```ruby
# app/models/custom/photo.rb

module Custom
  class Photo < LHS::Record
  end
end
```

###### has_one

```ruby
# app/models/transaction.rb

class Transaction < LHS::Record

  endpoint '{+service}/transaction/{id}'

  has_one :user
end
```

```ruby
# app/models/user.rb

class User < LHS::Record

  def email
    self[:email_address]
  end
end
```

```ruby
# app/controllers/some_controller.rb

Transaction.find(1).user.email_address # steve@local.ch
```
```
GET https://service.example.com/transaction/1
{... user: { email_address: 'steve@local.ch' } }
```

`class_name`: Specify the class name of the relation. Use it only if that name can't be inferred from the relation name. So has_many :photos will by default be linked to the Photo class, but if the real class name is e.g. CustomPhoto or namespaced Custom::Photo, you'll have to specify it with this option.

```ruby
# app/models/custom/location.rb

module Custom
  class Location < LHS::Record
    endpoint '{+service}/locations'
    endpoint '{+service}/locations/{id}'
    
    has_one :photo, class_name: 'Custom::Photo'
  end
end
```

```ruby
# app/models/custom/photo.rb

module Custom
  class Photo < LHS::Record
  end
end
```

#### Unwrap nested items from the response body

If the actual item data is mixed with meta data in the response body, LHS allows you to configure a record in a way to automatically unwrap items from within nested response data.

`item_key` is used to unwrap the actual object from within the response body.

```ruby
# app/models/location.rb

class Location < LHS::Record
  configuration item_key: [:response, :location]
end
```

```ruby
# app/controllers/some_controller.rb

location = Location.find(123)
location.id # 123
```
```
GET https://service.example.com/locations/123
{... response: { location: { id: 123 } } }
```

#### Determine collections from the response body

`items_key` key used to determine the collection of items of the current page (e.g. `docs`, `items`, etc.), defaults to 'items':

```ruby
# app/models/search.rb

class Search < LHS::Record
  configuration items_key: :docs
end
```

```ruby
# app/controllers/some_controller.rb

search_result = Search.where(q: 'Starbucks')
search_result.first.address # Bahnhofstrasse 5, 8000 Zürich
```
```
GET https://service.example.com/search?q=Starbucks
{... docs: [... {...  address: 'Bahnhofstrasse 5, 8000 Zürich' }] }
```

### Chain complex queries

> [Method chaining](https://en.wikipedia.org/wiki/Method_chaining), also known as named parameter idiom, is a common syntax for invoking multiple method calls in object-oriented programming languages. Each method returns an object, allowing the calls to be chained together without requiring variables to store the intermediate results

In order to simplify and enhance preparing complex queries for performing single or multiple requests, LHS implements query chains to find single or multiple records. 

LHS query chains do [lazy evaluation](https://de.wikipedia.org/wiki/Lazy_Evaluation) to only perform as many requests as needed, when the data to be retrieved is actually needed.

Any method, accessing the content of the data to be retrieved, is resolving the chain in place – like `.each`, `.first`, `.some_attribute_name`. Nevertheless, if you just want to resolve the chain in place, and nothing else, `fetch` should be the method of your choice:

```ruby
# app/controllers/some_controller.rb

Record.where(color: 'blue').fetch
```

#### Chain where queries

```ruby
# app/controllers/some_controller.rb

records = Record.where(color: 'blue')
[...]
records.where(available: true).each do |record|
  [...]
end
```
```
  GET https://service.example.com/records?color=blue&available=true
```

In case you wan't to check/debug the current values for where in the chain, you can use `where_values_hash`:

```ruby
records.where_values_hash

# {color: 'blue', available: true}
```

#### Expand plain collections of links: expanded

Some endpoints could respond only with a plain list of links and without any expanded data, like search results.

Use `expanded` to have LHS expand that data, by performing necessary requests in parallel:

```ruby
# app/controllers/some_controller.rb

Search.where(what: 'Cafe').expanded
```
```
GET https://service.example.com/search?what=Cafe
{...
  "items" : [
    {"href": "https://service.example.com/records/1"},
    {"href": "https://service.example.com/records/2"},
    {"href": "https://service.example.com/records/3"}
  ]
}

In parallel:
  > GET https://service.example.com/records/1
  < {... name: 'Cafe Einstein'}
  > GET https://service.example.com/records/2
  < {... name: 'Starbucks'}
  > GET https://service.example.com/records/3
  < {... name: 'Plaza Cafe'}

{
  ...
  "items" : [
    {
      "href": "https://service.example.com/records/1",
      "name": 'Cafe Einstein',
      ...
    },
    {
      "href": "https://service.example.com/records/2",
      "name": 'Starbucks',
      ...
    },
    {
      "href": "https://service.example.com/records/3",
      "name": 'Plaza Cafe',
      ...
    }
  ]
}
```

You can also apply request options to `expanded`. Those options will be used to perform the additional requests to expand the data:

```ruby
# app/controllers/some_controller.rb

Search.where(what: 'Cafe').expanded(auth: { bearer: access_token })
```

#### Error handling with chains

One benefit of chains is lazy evaluation. But that also means they only get resolved when data is accessed. This makes it hard to catch errors with normal `rescue` blocks:

```ruby
# app/controllers/some_controller.rb

def show
  @records = Record.where(color: blue) # returns a chain, nothing is resolved, no http requests are performed
rescue => e
  # never ending up here, because the http requests are actually performed in the view, when the query chain is resolved
end
```

```ruby
# app/views/some/view.haml

= @records.each do |record| # .each resolves the query chain, leads to http requests beeing performed, which might raises an exception
  = record.name
```

To simplify error handling with chains, you can also chain error handlers to be resolved, as part of the chain.

If you need to render some different view in Rails based on an LHS error raised during rendering the view, please proceed as following:

```ruby
# app/controllers/some_controller.rb

def show
  @records = Record
    .handle(LHC::Error, ->(error){ handle_error(error) })
    .where(color: 'blue')
  render 'show'
  render_error if @error
end

private

def handle_error(error)
  @error = error
  nil
end

def render_error
  self.response_body = nil # required to not raise AbstractController::DoubleRenderError
  render 'error'
end
```
```
> GET https://service.example.com/records?color=blue
< 406
```

In case no matching error handler is found the error gets re-raised.

-> Read more about [LHC error types/classes](https://github.com/local-ch/lhc#exceptions)

If you want to inject values for the failing records, that might not have been found, you can inject values for them with error handlers:

```ruby
# app/controllers/some_controller.rb

data = Record
  .handle(LHC::Unauthorized, ->(response) { Record.new(name: 'unknown') })
  .find(1, 2, 3)

data[1].name # 'unknown'
```
```
In parallel:
  > GET https://service.example.com/records/1
  < 200
  > GET https://service.example.com/records/2
  < 400
  > GET https://service.example.com/records/3
  < 200
```

-> Read more about [LHC error types/classes](https://github.com/local-ch/lhc#exceptions)

**If an error handler returns `nil` an empty LHS::Record is returned, not `nil`!**

In case you want to ignore errors and continue working with `nil` in those cases,
please use `ignore`:

```ruby
# app/controllers/some_controller.rb

record = Record.ignore(LHC::NotFound).find_by(color: 'blue')

record # nil
```

#### Resolve chains: fetch

In case you need to resolve a query chain in place, use `fetch`:

```ruby
# app/controllers/some_controller.rb

records = Record.where(color: 'blue').fetch
```

#### Add request options to a query chain: options

You can apply options to the request chain. Those options will be forwarded to the request perfomed by the chain/query:

```ruby
# app/controllers/some_controller.rb

options = { auth: { bearer: '123456' } } # authenticated with OAuth token

```

```ruby
# app/controllers/some_controller.rb

AuthenticatedRecord = Record.options(options)

```

```ruby
# app/controllers/some_controller.rb

blue_records = AuthenticatedRecord.where(color: 'blue')

```
```
GET https://service.example.com/records?color=blue { headers: { 'Authentication': 'Bearer 123456' } }
```

```ruby
# app/controllers/some_controller.rb

AuthenticatedRecord.create(color: 'red')

```
```
POST https://service.example.com/records { body: '{ color: "red" }' }, headers: { 'Authentication': 'Bearer 123456' } }
```

```ruby
# app/controllers/some_controller.rb

record = AuthenticatedRecord.find(123)

```
```
GET https://service.example.com/records/123 { headers: { 'Authentication': 'Bearer 123456' } }
```

```ruby
# app/controllers/some_controller.rb

authenticated_record = record.options(options) # starting a new chain based on the found record

```

```ruby
# app/controllers/some_controller.rb

authenticated_record.valid?

```
```
POST https://service.example.com/records/validate { body: '{...}', headers: { 'Authentication': 'Bearer 123456' } }
```

```ruby
# app/controllers/some_controller.rb

authenticated_record.save
```
```
POST https://service.example.com/records { body: '{...}', headers: { 'Authentication': 'Bearer 123456' } }
```

```ruby
# app/controllers/some_controller.rb

authenticated_record.destroy

```
```
DELETE https://service.example.com/records/123 { headers: { 'Authentication': 'Bearer 123456' } }
```

```ruby
# app/controllers/some_controller.rb

authenticated_record.update(name: 'Steve')

```
```
POST https://service.example.com/records/123 { body: '{...}', headers: { 'Authentication': 'Bearer 123456' } }
```

#### Control pagination within a query chain

`page` sets the page that you want to request.

`per` sets the amount of items requested per page.

`limit` is an alias for `per`. **But without providing arguments, it resolves the query and provides the current response limit per page**

```ruby
# app/controllers/some_controller.rb

Record.page(3).per(20).where(color: 'blue')

```
```
GET https://service.example.com/records?offset=40&limit=20&color=blue
```

```ruby
# app/controllers/some_controller.rb

Record.page(3).per(20).where(color: 'blue')

```
```
GET https://service.example.com/records?offset=40&limit=20&color=blue
```

The applied pagination strategy depends on whats configured for the particular record: See [Record pagination](#record-pagination)

### Record pagination

You can configure pagination on a per record base. 
LHS differentiates between the [pagination strategy](#pagination-strategy) (how items/pages are navigated and calculated) and [pagination keys](#pagination-keys) (how stuff is named and accessed).

#### Pagination strategy

##### Pagination strategy: offset (default)

The offset pagination strategy is LHS's default pagination strategy, so nothing needs to be (re-)configured.

The `offset` pagination strategy starts with 0 and offsets by the amount of items, thay you've already recived – typically `limit`.

```ruby
# app/models/record.rb

class Search < LHS::Record
  endpoint '{+service}/search'
end
```

```ruby
# app/controllers/some_controller.rb

Record.all

```
```
GET https://service.example.com/records?limit=100
{
  items: [{...}, ...]
  total: 300,
  limit: 100,
  offset: 0
}
In parallel:
  GET https://service.example.com/records?limit=100&offset=100
  GET https://service.example.com/records?limit=100&offset=200
```

##### Pagination strategy: page

In comparison to the `offset` strategy, the `page` strategy just increases by 1 (page) and sends the next batch of items for the next page.

```ruby
# app/models/record.rb

class Search < LHS::Record
  configuration pagination_strategy: 'page', pagination_key: 'page'

  endpoint '{+service}/search'
end
```

```ruby
# app/controllers/some_controller.rb

Record.all

```
```
GET https://service.example.com/records?limit=100
{
  items: [{...}, ...]
  total: 300,
  limit: 100,
  page: 1
}
In parallel:
  GET https://service.example.com/records?limit=100&page=2
  GET https://service.example.com/records?limit=100&page=3
```

##### Pagination strategy: start

In comparison to the `offset` strategy, the `start` strategy indicates with which item the current page starts. 
Typically it starts with 1 and if you get 100 items per page, the next start is 101.

```ruby
# app/models/record.rb

class Search < LHS::Record
  configuration pagination_strategy: 'start', pagination_key: 'startAt'

  endpoint '{+service}/search'
end
```

```ruby
# app/controllers/some_controller.rb

Record.all

```
```
GET https://service.example.com/records?limit=100
{
  items: [{...}, ...]
  total: 300,
  limit: 100,
  page: 1
}
In parallel:
  GET https://service.example.com/records?limit=100&startAt=101
  GET https://service.example.com/records?limit=100&startAt=201
```

#### Pagination keys

##### limit_key

`limit_key` sets the key used to indicate how many items you want to retrieve per page e.g. `size`, `limit`, etc.
In case the `limit_key` parameter differs for how it needs to be requested from how it's provided in the reponse, use `body` and `parameter` subkeys.

```ruby
# app/models/record.rb

class Record < LHS::Record
  configuration limit_key: { body: [:pagination, :max], parameter: :max }

  endpoint '{+service}/records'
end
```

```ruby
# app/controllers/some_controller.rb

records = Record.where(color: 'blue')
records.limit # 20
```
```
GET https://service.example.com/records?color=blue&max=100
{ ...
  items: [...],
  pagination: { max: 20 }
}
```

##### pagination_key

`pagination_key` defines which key to use to paginate a page (e.g. `offset`, `page`, `startAt` etc.).
In case the `limit_key` parameter differs for how it needs to be requested from how it's provided in the reponse, use `body` and `parameter` subkeys.

```ruby
# app/models/record.rb

class Record < LHS::Record
  configuration pagination_key: { body: [:pagination, :page], parameter: :page }, pagination_strategy: :page

  endpoint '{+service}/records'
end
```

```ruby
# app/controllers/some_controller.rb

records = Record.where(color: 'blue').all
records.length # 300
```
```
GET https://service.example.com/records?color=blue&limit=100
{... pagination: { page: 1 } }
In parallel:
  GET https://service.example.com/records?color=blue&limit=100&page=2
  {... pagination: { page: 2 } }
  GET https://service.example.com/records?color=blue&limit=100&page=3
  {... pagination: { page: 3 } }
```

##### total_key

`total_key` defines which key to user for pagination to describe the total amount of remote items (e.g. `total`, `totalResults`, etc.).

```ruby
# app/models/record.rb

class Record < LHS::Record
  configuration total_key: [:pagination, :total]

  endpoint '{+service}/records'
end
```

```ruby
# app/controllers/some_controller.rb

records = Record.where(color: 'blue').fetch
records.length # 100
records.count # 300
```
```
GET https://service.example.com/records?color=blue&limit=100
{... pagination: { total: 300 } }
```

#### Pagination links

##### next?

`next?` Tells you if there is a next link or not.

```ruby
# app/controllers/some_controller.rb

@records = Record.where(color: 'blue').fetch
```
```
GET https://service.example.com/records?color=blue&limit=100
{... items: [...], next: 'https://service.example.com/records?color=blue&limit=100&offset=100' }
```

```ruby
# app/views/some_view.haml

- if @records.next?
  = render partial: 'next_arrow'
```

##### previous?

`previous?` Tells you if there is a previous link or not.

```ruby
# app/controllers/some_controller.rb

@records = Record.where(color: 'blue').fetch
```
```
GET https://service.example.com/records?color=blue&limit=100
{... items: [...], previous: 'https://service.example.com/records?color=blue&limit=100&offset=100' }
```

```ruby
# app/views/some_view.haml

- if @records.previous?
  = render partial: 'previous_arrow'
```

#### Kaminari support (limited)

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

### Build, create and update records

#### Create new records

##### create

`create` will return false if persisting fails. `create!` instead will an raise exception.

`create` always builds the data of the local object first, before it tries to sync with an endpoint. So even if persisting fails, the local object is build.

```ruby
# app/controllers/some_controller.rb

record = Record.create(
  text: 'Hello world'
)

```
```
POST https://service.example.com/records { body: "{ 'text' : 'Hello world' }" }
```

-> See [record validation](#record-validation) for how to handle validation errors when creating records.

###### Unwrap nested data when creation response nests created record data

`item_created_key` key used to merge record data thats nested in the creation response body:

```ruby
# app/models/location.rb

class Location < LHS::Record

  configuration item_created_key: [:response, :location]

end
```

```ruby
# app/controllers/some_controller.rb

location.create(lat: '47.3920152', long: '8.5127981')
location.address # Förrlibuckstrasse 62, 8005 Zürich
```
```
POST https://service.example.com/locations { body: "{ 'lat': '47.3920152', long: '8.5127981' }" }
{... { response: { location: {... address: 'Förrlibuckstrasse 62, 8005 Zürich' } } } } 
```

###### Create records through associations: Nested sub resources

```ruby
# app/models/restaurant.rb

class Restaurant < LHS::Record
  endpoint '{+service}/restaurants/{id}'
end

```

```ruby
# app/models/feedback.rb

class Feedback < LHS::Record
  endpoint '{+service}/restaurants/{restaurant_id}/feedbacks'
end

```

```ruby
# app/controllers/some_controller.rb

restaurant = Restaurant.find(1)
```
```
GET https://service.example.com/restaurants/1
{... reviews: { href: 'https://service.example.com/restaurants/1/reviews' }}
```

```ruby
# app/controllers/some_controller.rb

restaurant.reviews.create(
  text: 'Simply awesome!'
)
```
```
POST https://service.example.com/restaurants/1/reviews { body: "{ 'text': 'Simply awesome!' }" }
```

#### Start building new records

With `new` or `build` you can start building new records from scratch, which can be persisted with `save`:

```ruby
# app/controllers/some_controller.rb

record = Record.new # or Record.build
record.name = 'Starbucks'
record.save
```
```
POST https://service.example.com/records { body: "{ 'name' : 'Starbucks' }" }
```

#### Change/Update existing records

##### save

`save` persist the whole object in it's current state. 

`save` will return `false` if persisting fails. `save!` instead will raise an exception.

```ruby
# app/controllers/some_controller.rb

record = Record.find('1z-5r1fkaj')

```
```
GET https://service.example.com/records/1z-5r1fkaj
{ name: 'Starbucks', recommended: null }
```

```ruby
# app/controllers/some_controller.rb

record.recommended = true
record.save

```
```
POST https://service.example.com/records/1z-5r1fkaj { body: "{ 'name': 'Starbucks', 'recommended': true }" }
```

-> See [record validation](#record-validation) for how to handle validation errors when updating records.

##### update

`update` persists the whole object after new parameters are applied through arguments.

`update` will return false if persisting fails. `update!` instead will an raise exception.

`update` always updates the data of the local object first, before it tries to sync with an endpoint. So even if persisting fails, the local object is updated.

```ruby
# app/controllers/some_controller.rb

record = Record.find('1z-5r1fkaj')

```
```
GET https://service.example.com/records/1z-5r1fkaj
{ name: 'Starbucks', recommended: null }
```

```ruby
# app/controllers/some_controller.rb

record.update(recommended: true)

```
```
POST https://service.example.com/records/1z-5r1fkaj { body: "{ 'name': 'Starbucks', 'recommended': true }" }
```

-> See [record validation](#record-validation) for how to handle validation errors when updating records.

##### partial_update

`partial_update` updates just the provided parameters.

`partial_update` will return false if persisting fails. `partial_update!` instead will an raise exception.

`partial_update` always updates the data of the local object first, before it tries to sync with an endpoint. So even if persisting fails, the local object is updated.

```ruby
# app/controllers/some_controller.rb

record = Record.find('1z-5r1fkaj')

```
```
GET https://service.example.com/records/1z-5r1fkaj
{ name: 'Starbucks', recommended: null }
```

```ruby
# app/controllers/some_controller.rb

record.partial_update(recommended: true)

```
```
POST https://service.example.com/records/1z-5r1fkaj { body: "{ 'name': 'Starbucks', 'recommended': true }" }
```

-> See [record validation](#record-validation) for how to handle validation errors when updating records.

#### Endpoint url parameter injection during record creation/change

LHS injects parameters provided to `create`, `update`, `partial_update`, `save` etc. into an endpoint's URL when matching:

```ruby
# app/models/feedback.rb

class Feedback << LHS::Record
  endpoint '{+service}/records/{record_id}/feedbacks'
end
```

```ruby
# app/controllers/some_controller.rb

Feedback.create(record_id: 51232, text: 'Great Restaurant!')
```
```
POST https://service.example.com/records/51232/feedbacks { body: "{ 'text' : 'Great Restaurant!' }" }
```

#### Record validation

In order to validate records before persisting them, you can use the `valid?` (`validate` alias) method.

It's **not recommended** to validate records anywhere, including application side validation via `ActiveModel::Validations`, except, if you validate them via the same endpoint/service, that also creates them.

The specific endpoint has to support validations without persistence. An endpoint has to be enabled (opt-in) in your record configurations:

```ruby
# app/models/user.rb

class User < LHS::Record

  endpoint '{+service}/users', validates: { params: { persist: false } }

end
```

```ruby
# app/controllers/some_controller.rb

user = User.build(email: 'i\'m not an email address')

unless user.valid?
  @errors = user.errors
  render 'new' and return
end
```
```
POST https://service.example.com/users?persist=false { body: '{ "email" : "i'm not an email address"}' }
{ 
  "field_errors": [{
    "path": ["email"],
    "code": "WRONG_FORMAT",
    "message": "The property value's format is incorrect."
  }],
  "message": "Email must have the correct format."
}
```

The functionalities of `LHS::Errors` pretty much follow those of `ActiveModel::Validation`:

```ruby
# app/views/some_view.haml

@errors.any? # true
@errors.include?(:email) # true
@errors[:email] # ['WRONG_FORMAT']
@errors.messages # {:email=>["Translated error message that this value has the wrong format"]}
@errors.codes # {:email=>["WRONG_FORMAT"]}
@errors.message # Email must have the correct format."
```

##### Configure record validations

The parameters passed to the `validates` endpoint option are used to perform record validations:

```ruby
# app/models/user.rb

class User < LHS::Record

  endpoint '{+service}/users', validates: { params: { persist: false } }  # will add ?persist=false to the request
  endpoint '{+service}/users', validates: { params: { publish: false } }  # will add ?publish=false to the request
  endpoint '{+service}/users', validates: { params: { validates: true } } # will add ?validates=true to the request
  endpoint '{+service}/users', validates: { path: 'validate' }            # will perform a validation via ...users/validate

end
```

##### HTTP Status Codes for validation errors

The HTTP status code received from the endpoint when performing validations on a record, is available through the errors object:

```ruby
# app/controllers/some_controller.rb

record.save
record.errors.status_code # 400
```

##### Reset validation errors

Clear the error messages like:

```ruby
# app/controllers/some_controller.rb

record.errors.clear
```

##### Add validation errors

In case you want to add application side validation errors, even though it's not recommended, do it as following:

```ruby
user.errors.add(:name, 'WRONG_FORMAT')
```

##### Validation errors for nested data

If you work with complex data structures, you sometimes need to have validation errors delegated/scoped to nested data.

This features makes `LHS::Record`s compatible with how Rails or Simpleform renders/builds forms and especially error messages:

```ruby
# app/controllers/some_controller.rb

unless @customer.save
  @errors = @customer.errors
end
```
```
POST https://service.example.com/customers { body: "{ 'address' : { 'street': 'invalid', housenumber: '' } }" }
{ 
  "field_errors": [{
    "path": ["address", "street"],
    "code": "REQUIRED_PROPERTY_VALUE_INCORRECT",
    "message": "The property value is incorrect."
  },{
    "path": ["address", "housenumber"],
    "code": "REQUIRED_PROPERTY_VALUE",
    "message": "The property value is required."
  }],
  "message": "Some data is invalid."
}
```

```ruby
# app/views/some_view.haml

= form_for @customer, as: :customer do |customer_form|

  = fields_for 'customer[:address]', @customer.address, do |address_form|

    = fields_for 'customer[:address][:street]', @customer.address.street, do |street_form|

      = street_form.input :name
      = street_form.input :house_number
```

This would render nested forms and would also render nested form errors for nested data structures.

You can also access those nested errors like:

```ruby
@customer.address.errors
@customer.address.street.errors
```

##### Translation of validation errors

If a translation exists for one of the following translation keys, LHS will provide a translated error (also in the following order) rather than the plain error message/code, when building forms or accessing `@errors.messages`:

```ruby
lhs.errors.records.<record_name>.attributes.<attribute_name>.<error_code>
e.g. lhs.errors.records.customer.attributes.name.unsupported_property_value

lhs.errors.records.<record_name>.<error_code>
e.g. lhs.errors.records.customer.unsupported_property_value

lhs.errors.messages.<error_code>
e.g. lhs.errors.messages.unsupported_property_value

lhs.errors.attributes.<attribute_name>.<error_code>
e.g. lhs.errors.attributes.name.unsupported_property_value

lhs.errors.fallback_message
```

##### Validation error types: errors vs. warnings

###### Persistance failed: errors

If an endpoint returns errors in the response body, that is enough to interpret it as: persistance failed.
The response status code in this scenario is neglected.

###### Persistance succeeded: warnings

In some cases, you need non blocking meta information about potential problems with the created record, so called warnings.

If the API endpoint implements warnings, returned when validating, they are provided just as `errors` (same interface and methods) through the `warnings` attribute:

```ruby
# app/controllres/some_controller.rb

@presence = Presence.options(params: { synchronize: false }).create(
  place: { href: 'http://storage/places/1' }
)
```
```
POST https://service.example.com/presences { body: '{ "place": { "href": "http://storage/places/1" } }' }
{
    field_warnings: [{
      code: 'WILL_BE_RESIZED',
      path: ['place', 'photos', 0],
      message: 'This photo is too small and will be resized.'
    }
  }
```

```ruby

presence.warnings.any? # true
presence.place.photos[0].warnings.messages.first # 'This photo is too small and will be resized.'

```

##### Using `ActiveModel::Validations` none the less

If you are using `ActiveModel::Validations`, even though it's not recommended, and you add errors to the LHS::Record instance, then those errors will be overwritten by the errors from `ActiveModel::Validations` when using `save`  or `valid?`. 

So in essence, mixing `ActiveModel::Validations` and LHS built-in validations (via endpoints), is not compatible, yet.

[Open issue](https://github.com/local-ch/lhs/issues/159)

#### Use form_helper to create and update records

Rails `form_for` view-helper can be used in combination with instances of `LHS::Record`s to autogenerate forms:

```ruby
<%= form_for(@instance, url: '/create') do |f| %>
  <%= f.text_field :name %>
  <%= f.text_area :text %>
  <%= f.submit "Create" %>
<% end %>
```

### Destroy records

`destroy`  deletes a record.

```ruby
# app/controllers/some_controller.rb

record = Record.find('1z-5r1fkaj')
```
```
GET https://service.example.com/records/1z-5r1fkaj
```

```ruby
# app/controllers/some_controller.rb

record.destroy
```
```
DELETE https://service.example.com/records/1z-5r1fkaj
```

You can also destroy records directly without fetching them first:

```ruby
# app/controllers/some_controller.rb

destroyed_record = Record.destroy('1z-5r1fkaj')
```
```
DELETE https://service.example.com/records/1z-5r1fkaj
```

or with parameters:

```ruby
# app/controllers/some_controller.rb

destroyed_records = Record.destroy(name: 'Steve')
```
```
DELETE https://service.example.com/records?name='Steve'
```

### Record getters and setters

Sometimes it is neccessary to implement custom getters and setters and convert data to a processable (endpoint) format behind the scenes.

#### Record setters

You can define setter methods in `LHS::Record`s that will be used by initializers (`new`) and setter methods, that convert data provided, before storing it in the record and persisting it with a remote endpoint:

```ruby
# app/models/user.rb

class Feedback < LHS::Record

  def ratings=(values)
    super(
      values.map { |k, v| { name: k, value: v } }
    )
  end
end
```

```ruby
# app/controllers/some_controller.rb

record = Record.new(ratings: { quality: 3 })
record.ratings # [{ :name=>:quality, :value=>3 }]
```

#### Record getters

If you implement accompanying getter methods, the whole data conversion would be internal only:

```ruby
# app/models/user.rb

class Feedback < LHS::Record

  def ratings=(values)
    super(
      values.map { |k, v| { name: k, value: v } }
    )
  end

  def ratings
    super.map { |r| [r[:name], r[:value]] }]
  end
end
```

```ruby
# app/controllers/some_controller.rb

record = Record.new(ratings: { quality: 3 })
record.ratings # {:quality=>3}
```

### Include linked resources (hyperlinks and hypermedia)

In a service-oriented architecture using [hyperlinks](https://en.wikipedia.org/wiki/Hyperlink)/[hypermedia](https://en.wikipedia.org/wiki/Hypermedia), records/resources can contain hyperlinks to other records/resources.

When fetching records with LHS, you can specify in advance all the linked resources that you want to include in the results. 

With `includes` or `includes_all` (to enforce fetching all remote objects for paginated endpoints), LHS ensures that all matching and explicitly linked resources are loaded and merged.

Including linked resources/records is heavily influenced by [http://guides.rubyonrails.org/active_record_class_querying](http://guides.rubyonrails.org/active_record_class_querying.html#eager-loading-associations) and you should read it to understand this feature in all it's glo

#### Ensure the whole linked collection is included: includes_all

In case endpoints are paginated and you are certain that you'll need all objects of a set and not only the first page/batch, use `includes_all`.

LHS will ensure that all linked resources are around by loading all pages (parallelized/performance optimized).

```ruby
# app/controllers/some_controller.rb

customer = Customer.includes_all(contracts: :products).find(1)
```
```
> GET https://service.example.com/customers/1
< {... contracts: { href: 'https://service.example.com/customers/1/contracts' } }
> GET https://service.example.com/customers/1/contracts?limit=100
< {... items: [...], limit: 10, offset: 0, total: 32 }
In parallel: 
  > GET https://service.example.com/customers/1/contracts?limit=10&offset=10
  < {... products: [{ href: 'https://service.example.com/product/LBC' }] }
  > GET https://service.example.com/customers/1/contracts?limit=10&offset=20
  < {... products: [{ href: 'https://service.example.com/product/LBB' }] }
In parallel:
  > GET https://service.example.com/product/LBC
  < {... name: 'Local Business Card' }
  > GET https://service.example.com/product/LBB
  < {... name: 'Local Business Basic' }
```

```ruby
# app/controllers/some_controller.rb

customer.contracts.length # 32
customer.contracts.first.products.first.name # Local Business Card

```

#### Include the first linked page or single item is included: include

`includes` includes the first page/response when loading the linked resource. **If the endpoint is paginated, only the first page will be included.**

```ruby
# app/controllers/some_controller.rb

customer = Customer.includes(contracts: :products).find(1)
```
```
> GET https://service.example.com/customers/1
< {... contracts: { href: 'https://service.example.com/customers/1/contracts' } }
> GET https://service.example.com/customers/1/contracts?limit=100
< {... items: [...], limit: 10, offset: 0, total: 32 }
In parallel:
  > GET https://service.example.com/product/LBC
  < {... name: 'Local Business Card' }
  > GET https://service.example.com/product/LBB
  < {... name: 'Local Business Basic' }
```

```ruby
# app/controllers/some_controller.rb

customer.contracts.length # 10
customer.contracts.first.products.first.name # Local Business Card

```

#### Include various levels of linked data

The method syntax of `includes` and `includes_all`, allows you include hyperlinks stored in deep nested data strutures:

Some examples:

```ruby
Record.includes(:localch_account, :entry)
# Includes localch_account -> entry
# { localch_account: { href: '...', entry: { href: '...' } } }

Record.includes([:localch_account, :entry])
# Includes localch_account and entry
# { localch_account: { href: '...' }, entry: { href: '...' } }

Record.includes(campaign: [:entry, :user])
# Includes campaign and entry and user from campaign
# { campaign: { href: '...' , entry: { href: '...' }, user: { href: '...' } } }
```

#### Identify and cast known records when including records

When including linked resources with `includes` or `includes_all`, already defined records and their endpoints and configurations are used to make the requests to fetch the additional data.

That also means that options for endpoints of linked resources are applied when requesting those in addition.

This applies for example a records endpoint configuration even though it's fetched/included through another record:

```ruby
# app/models/favorite.rb

class Favorite < LHS::Record

  endpoint '{+service}/users/{user_id}/favorites', auth: { basic: { username: 'steve', password: 'can' } }
  endpoint '{+service}/users/{user_id}/favorites/:id', auth: { basic: { username: 'steve', password: 'can' } }

end
```

```ruby
# app/models/place.rb

class Place < LHS::Record

  endpoint '{+service}/v2/places', auth: { basic: { username: 'steve', password: 'can' } }
  endpoint '{+service}/v2/places/{id}', auth: { basic: { username: 'steve', password: 'can' } }

end
```

```ruby
# app/controllers/some_controller.rb

Favorite.includes(:place).where(user_id: current_user.id)

```
```
> GET https://service.example.com/users/123/favorites { headers: { 'Authentication': 'Basic c3RldmU6Y2Fu' } }
< {... items: [... { place: { href: 'https://service.example.com/place/456' } } ] }
In parallel:
  > GET https://service.example.com/place/456 { headers: { 'Authentication': 'Basic c3RldmU6Y2Fu' } }
  > GET https://service.example.com/place/789 { headers: { 'Authentication': 'Basic c3RldmU6Y2Fu' } }
  > GET https://service.example.com/place/1112 { headers: { 'Authentication': 'Basic c3RldmU6Y2Fu' } }
  > GET https://service.example.com/place/5423 { headers: { 'Authentication': 'Basic c3RldmU6Y2Fu' } }
```

#### Apply options for requests performed to fetch included records

Use `references` to apply request options to requests performed to fetch included records:

```ruby
# app/controllers/some_controller.rb

Favorite.includes(:place).references(place: { auth: { bearer: '123' }}).where(user_id: 1)
```
```
GET https://service.example.com/users/1/favorites
{... items: [... { place: { href: 'https://service.example.com/places/2' } }] }
In parallel:
  GET https://service.example.com/places/2 { headers: { 'Authentication': 'Bearer 123' } }
  GET https://service.example.com/places/3 { headers: { 'Authentication': 'Bearer 123' } }
  GET https://service.example.com/places/4 { headers: { 'Authentication': 'Bearer 123' } }
```

### Record batch processing

**Be careful using methods for batch processing. They could result in a lot of HTTP requests!**

#### all

`all` fetches all records from the service by doing multiple requests, best-effort parallelization, and resolving endpoint pagination if necessary:

```ruby
records = Record.all
```
```
> GET https://service.example.com/records?limit=100
< {...
  items: [...]
  total: 900,
  limit: 100,
  offset: 0
}
In parallel:
  > GET https://service.example.com/records?limit=100&offset=100
  > GET https://service.example.com/records?limit=100&offset=200
  > GET https://service.example.com/records?limit=100&offset=300
  > GET https://service.example.com/records?limit=100&offset=400
  > GET https://service.example.com/records?limit=100&offset=500
  > GET https://service.example.com/records?limit=100&offset=600
  > GET https://service.example.com/records?limit=100&offset=700
  > GET https://service.example.com/records?limit=100&offset=800
```

`all` is chainable and has the same interface like `where`:

```ruby
Record.where(color: 'blue').all
Record.all.where(color: 'blue')
Record.all(color: 'blue')
```

All three are doing the same thing: fetching all records with the color 'blue' from the endpoint while resolving pagingation if endpoint is paginated.

##### Using all, when endpoint does not implement response pagination meta data

In case an API does not provide pagination information in the repsponse data (limit, offset and total), LHS keeps on loading pages when requesting `all` until the first empty page responds.

#### find_each

`find_each` is a more fine grained way to process single records that are fetched in batches.

```ruby
Record.find_each(start: 50, batch_size: 20, params: { has_reviews: true }) do |record|
  # Iterates over each record. Starts with record no. 50 and fetches 20 records each batch.
  record
  break if record.some_attribute == some_value
end
```

#### find_in_batches

`find_in_batches` is used by `find_each` and processes batches.

```ruby
Record.find_in_batches(start: 50, batch_size: 20, params: { has_reviews: true }) do |records|
  # Iterates over multiple records (batch size is 20). Starts with record no. 50 and fetches 20 records each batch.
  records
  break if records.first.name == some_value
end
```

### Convert/Cast specific record types: becomes

Based on [ActiveRecord's implementation](http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-becomes), LHS implements `becomes`, too.

It's a way to convert records of a certain type A to another certain type B.

_NOTE: RPC-style actions, that are discouraged in REST anyway, are utilizable with this functionality, too. See the following example:_

```ruby
# app/models/location.rb

class Location < LHS::Record
  endpoint '{+service}/locations'
  endpoint '{+service}/locations/{id}'
end
```

```ruby
# app/models/synchronization.rb

class Synchronization < LHS::Record
  endpoint '{+service}/locations/{id}/sync'
end
```

```ruby
# app/controllers/some_controller.rb

location = Location.find(1)
```
```
GET https://service.example.com/location/1
```

```ruby
# app/controllers/some_controller.rb

synchronization = location.becomes(Synchronization)
synchronization.save!
```
```
POST https://service.example.com/location/1/sync { body: '{ ... }' }
```

## Request Cycle Cache

By default, LHS does not perform the same http request multiple times during one request/response cycle.

```ruby
# app/models/user.rb

class User < LHS::Record
  endpoint '{+service}/users/{id}'
end
```

```ruby
# app/models/location.rb

class Location < LHS::Record
  endpoint '{+service}/locations/{id}'
end
```

```ruby
# app/controllers/some_controller.rb

def index
  @user = User.find(1)
  @locations = Location.includes(:owner).find(2)
end
```
```
GET https://service.example.com/users/1
GET https://service.example.com/location/2
{... owner: { href: 'https://service.example.com/users/1' } }
From cache:
  GET https://service.example.com/users/1
```

It uses the [LHC Caching Interceptor](https://github.com/local-ch/lhc#caching-interceptor) as caching mechanism base and sets a unique request id for every request cycle with Railties to ensure data is just cached within one request cycle and not shared with other requests.

Only GET requests are considered for caching by using LHC Caching Interceptor's `cache_methods` option internally and considers request headers when caching requests, so requests with different headers are not served from cache.

The LHS Request Cycle Cache is opt-out, so it's enabled by default and will require you to enable the [LHC Caching Interceptor](https://github.com/local-ch/lhc#caching-interceptor) in your project.

### Change store for LHS' request cycle cache

By default the LHS Request Cycle Cache will use `ActiveSupport::Cache::MemoryStore` as its cache store. Feel free to configure a cache that is better suited for your needs by:

```ruby
# config/initializers/lhc.rb

LHC.configure do |config|
  config.request_cycle_cache = ActiveSupport::Cache::MemoryStore.new
end
```

### Disable request cycle cache

If you want to disable the LHS Request Cycle Cache, simply disable it within configuration:

```ruby
# config/initializers/lhc.rb

LHC.configure do |config|
  config.request_cycle_cache_enabled = false
end
```

## Testing with LHS

**Best practice in regards of testing applications using LHS, is to let LHS fetch your records, actually perform HTTP requests and [WebMock](https://github.com/bblimke/webmock) to stub/mock those http requests/responses.**

This follows the [Black Box Testing](https://en.wikipedia.org/wiki/Black-box_testing) approach and prevents you from creating constraints to LHS' internal structures and mechanisms, which will break as soon as we change internals.

```ruby
# specs/*/some_spec.rb 

let(:contracts) do
  [
    {number: '1'},
    {number: '2'},
    {number: '3'}
  ]
end

before do
  stub_request(:get, "https://service.example.com/contracts")
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

### Test helper for request cycle cache

In order to not run into caching issues during your tests, when (request cycle cache)[#request-cycle-cache] is enabled, simply require the following helper in your tests:

```ruby
# spec/spec_helper.rb

require 'lhs/test/request_cycle_cache_helper'
```

This will initialize a MemoryStore cache for LHC::Caching interceptor and resets the cache before every test.

### Test query chains

#### By explicitly resolving the chain: fetch

Use `fetch` in tests to resolve chains in place and expect WebMock stubs to be requested.

```ruby
# specs/*/some_spec.rb 

records = Record.where(color: 'blue').where(available: true).where(color: 'red')

expect(
  records.fetch
).to have_requested(:get, %r{records/})
  .with(query: hash_including(color: 'blue', available: true))
```

#### Without resolving the chain: where_values_hash

As `where` chains are not resolving to HTTP-requests when no data is accessed, you can use `where_values_hash` to access the values that would be used to resolve the chain, and test those:

```ruby
# specs/*/some_spec.rb 

records = Record.where(color: 'blue').where(available: true).where(color: 'red')

expect(
  records.where_values_hash
).to eq {color: 'red', available: true}
```

## License

[GNU Affero General Public License Version 3.](https://www.gnu.org/licenses/agpl-3.0.en.html)


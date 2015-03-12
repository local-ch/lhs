Services
===

A LHS::Service makes data available using multiple endpoints.

![Service](service.jpg)

## Endpoints

You setup a service by configure one or multiple backend endpoints.
You can also add request options for an endpoint (see following example).

```ruby
class Feedback < LHS::Service

  endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
  endpoint ':datastore/v2/feedbacks', cache: true, cache_expires_in: 1.day

end
```

If you try to setup a service with clashing endpoints it will immediately raise an exception.

```ruby
class Feedback < LHS::Service

  endpoint ':datastore/v2/reviews'
  endpoint ':datastore/v2/feedbacks'

end
# raises: Clashing endpoints.

```

## Find multiple records

You can query the services by using `where`.

```ruby
  Feedback.where(has_reviews: true) #<LHS::Data @_proxy=#<LHS::Collection>>
```

This uses the `:datastore/v2/feedbacks` endpoint, cause `:campaign_id` was not provided.
In addition it would add `?has_reviews=true` to the get parameters.

```ruby
  Feedback.where(campaign_id: 'fq-a81ngsl1d') #<LHS::Data @_proxy=#<LHS::Collection>>
```
Uses the `:datastore/v2/content-ads/:campaign_id/feedbacks` endpoint.

→ [Read more about collections](collections.md)

## Find single records

`find` finds a unique item by uniqe identifier (usualy id).

If no record is found an error is raised.

```ruby
  Feedback.find('z12f-3asm3ngals') #<LHS::Data @_proxy=#<LHS::Item>>
```

`find` can also be used to find a single uniqe item with parameters:

```ruby
  Feedback.find(campaign_id: 123, id: 456)
```

`find_by` finds the first record matching the specified conditions.

If no record is found, `nil` is returned.

`find_by!` raises LHC::NotFound if nothing was found.

```ruby
  Feedback.find_by(id: 'z12f-3asm3ngals') #<LHS::Data @_proxy=#<LHS::Item>>
  Feedback.find_by(id: 'doesntexist') # nil
```

`first` is a alias for finding the first of a service without parameters.

```ruby
  Feedback.first
```

If no record is found, `nil` is returned.

`first!` raises LHC::NotFound if nothing was found.

→ [Read more about items](items.md)

## Batch processing

** Be carefull using methods for batch processing. They could result in a lot of HTTP requests! **

`all` fetches all records from the backend by doing multiple requests if necessary.

```ruby
data = Feedback.all #<LHS::Data @_proxy=#<LHS::Collection>>
data.count # 998
data.total # 998
```

→ [Read more about collections](collections.md)

`find_each` is a more fine grained way to process single records that are fetched in batches.

```ruby
Feedback.find_each(start: 50, batch_size: 20, params: { has_reviews: true }) do |feedback|
  # Iterates over each record. Starts with record nr. 50 and fetches 20 records each batch.
  feedback #<LHS::Data @_proxy=#<LHS::Item>>
end
```

`find_in_batches` is used by `find_each` and processes batches.
```ruby
Feedback.find_in_batches(start: 50, batch_size: 20, params: { has_reviews: true }) do |feedbacks|
  # Iterates over multiple records (batch size is 20). Starts with record nr. 50 and fetches 20 records each batch.
  feedbacks #<LHS::Data @_proxy=#<LHS::Collection>>
end
```

## Create records

```ruby
  feedback = Feedback.create(
    recommended: true,
    source_id: 'aaa',
    content_ad_id: '1z-5r1fkaj'
  ) #<LHS::Data @_proxy=#<LHS::Item>>
```

When creation fails, the object contains errors in its `errors` attribute:

```ruby
  feedback.errors #<LHS::Errors>
  feedback.errors.include?(:ratings) # true
  feedback.errors[:ratings] # ['REQUIRED_PROPERTY_VALUE']
  record.errors.messages # {:ratings=>["REQUIRED_PROPERTY_VALUE"], :recommended=>["REQUIRED_PROPERTY_VALUE"]}
  record.errors.message # ratings must be set when review or name or review_title is set | The property value is required; it cannot be null, empty, or blank."
```

## Build new records

Build and persist new items from scratch.

```ruby
  feedback = Feedback.build(recommended: true)
  feedback.save
```

→ [Read more about items](items.md)


## Include linked resources

A service lets you specify in advance all the linked resources that you want to include in the results. With includes, a service ensures that all matching and explicitly linked resources are loaded and merged.

The implementation is heavily influenced by [http://guides.rubyonrails.org/active_record_querying](http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations)
and you should read it to understand this feature in all its glory.

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

## Map data

To influence how data is accessed/provied, you can use mapping to either map deep nested data or to manipulate data when its accessed:

```ruby
class LocalEntry < LHS::Service
  endpoint ':datastore/v2/local-entries'

  map :name, ->(entry){ entry.addresses.first.business.identities.first.name }

end
```

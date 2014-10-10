Service
===

A Service makes data available using multiple endpoints.

## Endpoints

You setup a service by configure one or multiple backend endpoints that provide data for that service.

```ruby
class LHS::Feedback < LHS::Service

  endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
  endpoint ':datastore/v2/feedbacks'

end
```

## Query

You can query the services by using `where`.

```ruby
  LHS::Feedback.where(has_reviews: true) // #<LHS::Data @_proxy_=#<LHS::Collection>>
```

This uses the `:datastore/v2/feedbacks` endpoint, cause `:campaign_id` was not provided.
In addition it would add `?has_reviews=true` to the get parameters.

```ruby
  LHS::Feedback.where(campaign_id: 'fq-a81ngsl1d') // #<LHS::Data @_proxy_=#<LHS::Collection>>
```
Uses the `:datastore/v2/content-ads/:campaign_id/feedbacks` endpoint.

## All

`all` fetches all records from the backend by doing multiple requests if necessary.

** Be carefull using `all`, it could result in a lot of HTTP requests **

```ruby
data = LHS::Feedback.all // #<LHS::Data @_proxy_=#<LHS::Collection>>
data.count // 998
data.total // 998
```

## Create

```ruby
  feedback = LHS::Feedback.create(
    recommended: true,
    source_id: 'aaa',
    content_ad_id: '1z-5r1fkaj'
  ) // #<LHS::Data @_proxy_=#<LHS::Item>>
```

### Errors while creating

When creation fails, the object contains errors in its `errors` attribute:

```ruby
  feedback.errors // #<LHS::Errors>
  feedback.errors.include?(:ratings) // true
  feedback.errors[:ratings] // ['REQUIRED_PROPERTY_VALUE']
```

## Find

`find` finds a unique item by uniqe identifier (usualy id).

If no record is found an error is raised.

```ruby
  LHS::Feedback.find('z12f-3asm3ngals') // #<LHS::Data @_proxy_=#<LHS::Item>>
```

## Find by

`find_by` finds the first record matching the specified conditions.

If no record is found, returns `nil`.

```ruby
  LHS::Feedback.find_by(id: 'z12f-3asm3ngals') // #<LHS::Data @_proxy_=#<LHS::Item>>
  LHS::Feedback.find_by(id: 'doesntexist') // nil
```

## Item

An item is a concrete record. It can be part of another proxy like collection.
→ [Read more about items](docs/item.md)

## Misconfiguration

If you try to setup a service with clashing endpoints it will immediately raise an exception.

```ruby
class LHS::Feedback < LHS::Service

  endpoint ':datastore/v2/reviews'
  endpoint ':datastore/v2/feedbacks'

end
// raises: Clashing endpoints.
```

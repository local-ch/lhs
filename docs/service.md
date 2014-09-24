Service
===

A Service makes data available using multiple endpoints.

## Endpoints

You setup a service by configure one or multiple backend endpoints that provide data for that service.

```
class LHS::Feedback < LHS::Service

  endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
  endpoint ':datastore/v2/feedbacks'

end
```

## Query

You can query the services by using `where`.

```
  LHS::Feedback.where(has_reviews: true) // #<LHS::Data>
```
This uses the `:datastore/v2/feedbacks` endpoint, cause `:campaign_id` was not provided.
In addition it would add `?has_reviews=true` to the get parameters.

```
  LHS::Feedback.where(campaign_id: 'fq-a81ngsl1d') // #<LHS::Data>
```
Uses the `:datastore/v2/content-ads/:campaign_id/feedbacks` endpoint.

## Find by

`find_by` finds the first record matching the specified conditions.

If no record is found, returns `nil`.

```
  LHS::Feedback.find_by(id: 'z12f-3asm3ngals') // #<LHS::Data>
```

## Create

```
  feedback = LHS::Feedback.create(
    recommended: true,
    source_id: 'aaa',
    content_ad_id: '1z-5r1fkaj'
  ) // #<LHS::Data>
```

### Errors while creating

When creation fails, the object contains errors in its `errors` attribute:

```
  feedback.errors // #<LHS::Errors>
  feedback.errors.include?(:ratings) // true
  feedback.errors[:ratings] // ['REQUIRED_PROPERTY_VALUE']
```

## Misconfiguration

If you try to setup a service with clashing endpoints it will immediately raise an exception.

```
class LHS::Feedback < LHS::Service

  endpoint ':datastore/v2/reviews'
  endpoint ':datastore/v2/feedbacks'

end
// raises: Clashing endpoints.
```

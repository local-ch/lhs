LHS
===

LHS uses [LHC](//github.com/local-ch/LHC) for http requests.

## Service
A service connects your application to backend endpoints and provides you access to their data.

```ruby
class LHS::Feedback < LHS::Service

  endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
  endpoint ':datastore/v2/feedbacks'

end

data = LHS::Feedback.where(has_reviews: true) // #<LHS::Data>
```

→ [Read more about services](docs/services.md)

## Data
Data contains raw data (json) and a proxy that is used to access data.

```ruby
data.first.recommended # true
```

## Proxy
A proxy is used to access data. It is separated in the three types: Collection, Item and Link.

## Collection
A collection is a special type of data that contains multiple items.

```ruby
data = LHS::Feedback.where(has_reviews: true) // #<LHS::Data @_proxy_=#<LHS::Collection>>
data.count // 10
data.total // 98
```

→ [Read more about collections](docs/collection.md)

## Item
An item is a concrete record. It can be part of another proxy like collection.

```ruby
data = LHS::Feedback.where(has_reviews: true).first // #<LHS::Data @_proxy_=#<LHS::Item>>
data.recommended // true
data.created_date // Fri, 19 Sep 2014 14:03:35 +0200
data._raw_ // {...}
```

→ [Read more about items](docs/item.md)

## Link
A link is pointing to a backend resource. Sometimes a link contains data already.

```ruby
data = LHS::Feedback.where(has_reviews: true).first.campaign // #<LHS::Data @_proxy_=#<LHS::Link>>
data._raw_ // {"href"=>"http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/51dfc5690cf271c375c5a12d"}
data.id // "51dfc5690cf271c375c5a12d" (fetched from the backend)
```

→ [Read more about links](docs/link.md)

Link
===

As soon as an Item contains a key called `href` its treated as link.

`load!` can be used to explicitly load the item from the backend.

```ruby
{
  "href" => "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/51dfc5690cf271c375c5a12d"
}

item.load!.id
```
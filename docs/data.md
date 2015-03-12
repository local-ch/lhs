Data
===

Everytime you interact with back-end data you will get an instance of LHS::Data.

```ruby
Service.where #<LHS::Data @_proxy=#<LHS::Collection>>
Service.find(123) #<LHS::Data @_proxy=#<LHS::Item>>
```

## Internals

```ruby
data = Service.where(entry_id: 123)

# Proxy that is used to access the data
data._proxy #<LHS::Collection>

# Raw data that is underlying
data._raw #<Hash>

# The parent
data.first._proxy #<LHS::Item>
data.first._parent._proxy #<LHS::Collection>
data.first._parent === data

# The root
data.first.some_relation.first._proxy #<LHS::Item>
data.first._root._proxy #<LHS::Collection>
data.first.some_relation.first._root === data

# Service that was used to fetch the data
data._service #<Service>

# The request that was used to fetch the data
data._request #<LHC::Request>
```

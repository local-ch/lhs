Data
===

Everytime you interact with back-end data you will get an instance of LHS::Data.

```ruby
Service.where #<LHS::Data @_proxy_=#<LHS::Collection>>
Service.find(123) #<LHS::Data @_proxy_=#<LHS::Item>>
```

## Internals

```ruby
data = Service.where(entry_id: 123)

# Proxy that is used to access the data
data._proxy_ #<LHS::Collection>

# Raw data that is underlying
data._raw_ #<Hash>

# The parent
data.first._proxy_ #<LHS::Item>
data.first._parent_._proxy_ #<LHS::Collection>
data.first._parent_ === data

# The root
data.first.some_relation.first._proxy_ #<LHS::Item>
data.first._root_._proxy_ #<LHS::Collection>
data.first.some_relation.first._root_ === data

# Service that was used to fetch the data
data._service_ #<Service>

# The request that was used to fetch the data
data._request_ #<LHC::Request>
```

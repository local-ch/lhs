Item
===

An item is a concrete record. It can be part of a collection.

You can access data by using dot operator `item.name_of_attribte_you_wanna_access`.

Sometimes data gets converted when accessed. For example parseable dates will be returned as Date or DateTime.

## Setter

An item proxy contains setter methods, in order to set/change values.

```
  record = Feedback.find(id: 'z12f-3asm3ngals') #<LHS::Data @_proxy=#<LHS::Item>>
  rcord.recommended = false
```

## Build (new)

Build and persist new items from scratch.

```ruby
feedback = Feedback.build(recommended: true)
feedback.save
```

`new` is an alias for `build`:

```ruby
Feedback.new(recommended: true)
```

## Save

You can persist changes like you would usually do with `save`.
`save` will return false if persisting fails. `save!` instead will raise an exception.

```ruby
  feedback = Feedback.find('1z-5r1fkaj')
  feedback.recommended = false
  feedback.save
```

## Update

`update` will return false if persisting fails. `update!` instead will an raise exception.
Update always updates the data of the local object first, before it tries to sync with an endpoint.

```ruby
feedback = Feedback.find('1z-5r1fkaj')
feedback.update(recommended: false)
```

## Destroy

You can delete records remotely by calling `destroy` on an item.

```ruby
  feedback = Feedback.find('1z-5r1fkaj')
  feedback.destroy
```

## Validation

In order to validate objects before persisting them, you can use the `valid?` (`validate` alias) method.
The specific endpoint has to support validations with the `persist=false` parameter. 
The endpoint has to be enabled (opt-in) for validations in the service configuration.

```
class User < LHS::Service
  endpoint ':datastore/v2/users', validates: true
end

user = User.build(email: 'im not an email address')
unless user.valid?
  fail(user.errors[:email])
end
```

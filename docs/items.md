Item
===

An item is a concrete record. It can be part of another proxy like collection.

You can access data by using dot operator `item.name_of_attribte_you_wanna_access`.
Sometimes data gets converted when accessed. For example in case of parsable dates you will receive a Date or DateTime.

## Setter

An item proxy contains setter methods, in order to set/change values.

```
  record = Feedback.find(id: 'z12f-3asm3ngals') #<LHS::Data @_proxy_=#<LHS::Item>>
  rcord.recommended = false
```

## Build

Build and persist new items from scratch.

```ruby
feedback = Feedback.build(recommended: true)
feedback.save
```

## Save

You can persist changes like you would usually do with `save`.
`save` will return false if persisting failed, but `save!` instead will raise exception.

```ruby
  feedback = Feedback.find('1z-5r1fkaj')
  feedback.recommended = false
  feedback.save
```

## Update

`update` will return false if persting failed, but `update!` instead will raise exception.

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

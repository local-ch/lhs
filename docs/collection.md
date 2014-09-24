Collection
===

A collection is a special type of data that contains multiple items.

In general you can use any method that you also could call on an array (like count, [0], first etc.).

## Total

`total` provides total amount of items (even if paginated).

## Page

Access a specific page of the collection.
```
data = LHS::Feedback.where()
data.count // 10
data.page(3) // #<LHS::Data>
```

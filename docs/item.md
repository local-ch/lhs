Item
===

An item is a concrete record. It can be part of another proxy like collection.

You can access data by using dot operator `item.name_of_attribte_you_wanna_access`.
Sometimes data gets converted when accessed. For example in case of parsable dates you will receive a Date or DateTime rather than a useless string.
If no data is present for an attribute that you try to acccess `nil` is returned.

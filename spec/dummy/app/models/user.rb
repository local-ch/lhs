class User < LHS::Record
  endpoint 'http://datastore/v2/users'
  endpoint 'http://datastore/v2/users/{id}'
end

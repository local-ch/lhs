class User < LHS::Record
  endpoint ':datastore/v2/users'
  endpoint ':datastore/v2/users/:id'
end

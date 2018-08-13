class Record < LHS::Record
  endpoint 'http://datastore/v2/records'
  endpoint 'http://datastore/v2/records/{id}'
end

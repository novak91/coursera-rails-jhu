require 'mongo'

include Mongo

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'raceday_development')
database = client.database

p database.collections #=> Returns an array of Collection objects.
p database.collection_names #=> Returns an array of collection names as strings.
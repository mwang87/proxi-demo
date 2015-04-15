require 'data_mapper'
require 'redis'


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/data.db")


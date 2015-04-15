require 'data_mapper'
require 'redis'


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/data.db")
#DataMapper.setup(:default, 'postgres://postgres:postgres@localhost/postgres' )

PAGINATION_SIZE = 30

# puts ENV["RACK_ENV"]
# configure :test do
#     
# end
# configure :development do
#     DataMapper.setup(:default, ENV['DATABASE_URL'] )
# end
# configure :production do
#     DataMapper.setup(:default, ENV['DATABASE_URL'] )
# end
# 
# def setting_initialize()
# 
#     puts "SETTINGS INITIALIZE"
#     
# end

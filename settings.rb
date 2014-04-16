require 'data_mapper'
require 'redis'



puts ENV["RACK_ENV"]
configure :test do
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/data.db")
end
configure :development do
    DataMapper.setup(:default, ENV['DATABASE_URL'] )
end
configure :production do
    require 'newrelic_rpm'
    DataMapper.setup(:default, ENV['DATABASE_URL'] )
end

def setting_initialize()

    configure :production do
        uri = URI.parse(ENV["REDISCLOUD_URL"])
        redis_pusher = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        set :redischatchannel, "chat-demo"
        set :redispusher, redis_pusher
    end
    configure :development do
        uri = URI.parse(ENV["REDISCLOUD_URL"])
        redis_pusher = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        set :redischatchannel, "chat-demo"
        set :redispusher, redis_pusher
    end
    configure :test do
        redis_pusher = Redis.new
        set :redischatchannel, "chat-demo"
        set :redispusher, redis_pusher
    end


    puts "SETTINGS INITIALIZE"
    
end

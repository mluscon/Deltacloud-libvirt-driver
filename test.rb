require 'rubygems'
require './web'

require 'redis'

redis = Redis.new

Thread.new do
  Web.run!
end

9.times do | it |
  redis.sadd "waiting", it
  puts it
end

sleep 10
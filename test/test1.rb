require 'rubygems'
require './web.rb'
require './test/spec.rb'
require 'redis'



spec = Spec.XML
$redis = Redis.new
$redis.flushall

4.times do
  x = rand(10)
  $redis.sadd "waiting", x
  $redis.hmset( x, 'spec', spec)
end

4.times do
  x =10 + rand(10)
  $redis.sadd "copying", x
  $redis.hmset( x, 'spec', spec)
end

4.times do
  x =20 + rand(20)
  $redis.sadd "running", x
  $redis.hmset( x, 'spec', spec)
end

Web.run!



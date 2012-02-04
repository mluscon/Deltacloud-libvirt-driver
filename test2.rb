require 'rubygems'
require 'resque'
require 'redis'

require './instance'
require './configuration_xml'
require './helper'

redis = Redis.new


config = Nokogiri::XML( Xml_conf.new.config)

uuid = config.xpath('/query/domain/uuid').first.text

help = Helper.new

help.add( config )

stat = help.status( uuid )

help.transform( uuid )

puts redis.hget( uuid, 'spec' )

 
 
 
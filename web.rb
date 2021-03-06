require 'sinatra'
require 'haml'
require 'redis'
require 'nokogiri'
require 'sinatra/static_assets'
require 'rack'


class Web < Sinatra::Base
  
  get '/' do
    redis = Redis.new
    @waiting = Hash.new
    redis.smembers('waiting').each do | uuid |
      spec = Nokogiri::XML( $redis.hget(uuid, 'spec') )
      name = spec.xpath( '/domain/name' ).first.text
      @waiting[ uuid ] = name
    end
    
    @copying = Hash.new
    redis.smembers('copying').each do | uuid |
      spec = Nokogiri::XML( redis.hget(uuid, 'spec') )
      name = spec.xpath( '/domain/name' ).first.text
      @copying[ uuid ] = name
    end
    
    @running = Hash.new
    redis.smembers('running').each do | uuid |
      spec = Nokogiri::XML( redis.hget(uuid, 'spec') )
      name = spec.xpath( '/domain/name' ).first.text
      state = 'running'
      @running[ uuid ] = name
    end
    
    haml :index
    
  end
  
  get '/instances/:uuid' do
    redis = Redis.new
    @uuid = params[:uuid]
    @spec = Nokogiri::XML( redis.hget(@uuid, 'spec') )
    @name = @spec.xpath('/domain/name').first

    haml :instance

  end
end

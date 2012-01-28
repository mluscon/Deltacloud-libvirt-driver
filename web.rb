require 'sinatra'

class Web < Sinatra::Base
 get '/' do
   erb :instances
  end
end

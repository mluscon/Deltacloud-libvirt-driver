require 'sinatra'

class Web < Sinatra::Base
 get '/' do
   erb :index
  end
end

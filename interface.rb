require 'sinatra'



class Driver_web < Sinatra::Base
  

 get '/' do
   @inst = Hash.new
   erb :instances
  end
end

require 'sinatra/base'

# This is a rack app.
module GeeklistWS
  module Frontend	
	class Web < Sinatra::Base

  		get "/" do 
  			data = GeeklistWS::API::Internal.get("178608")

  			@converter = GeeklistWS::Frontend::Converter.new data

    		haml :table
  		end
	end
  end
end



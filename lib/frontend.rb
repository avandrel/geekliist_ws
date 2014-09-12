require 'sinatra/base'

# This is a rack app.
module GeeklistWS
  module Frontend	
	class Web < Sinatra::Base

  		get "/:id" do |id|
  			@title = id
  			@converter = GeeklistWS::Frontend::Converter.new GeeklistWS::API::Internal.get(id)
    		haml :table
  		end
	end
  end
end



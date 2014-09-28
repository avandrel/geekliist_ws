require 'sinatra/base'
require 'haml'

# This is a rack app.
module GeeklistWS
  module Frontend	
	  class Web < Sinatra::Base
      configure do
        set :id, '178608'
      end

      get "/" do 
        redirect '/list'
      end

      get "/list*" do
        puts "Get"
        data = GeeklistWS::API::Internal.get_geeklist(settings.id)
        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        @converter = GeeklistWS::Frontend::ListConverter.new data, params[:splat][0][1..-1]

        haml :listview
      end

      get "/checklist" do
        @post = false
        haml :checklistview
      end

      post "/checklist" do
          puts "checklist"
          @post = true
          puts params["list"].inspect
          data = GeeklistWS::API::Internal.get_checklist(params["list"], settings.id)
          #puts data.inspect
          @converter = GeeklistWS::Frontend::CheckListConverter.new data
          haml :checklistview
      end
	  end
  end
end



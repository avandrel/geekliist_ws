require 'sinatra/base'
require 'sinatra/json'
require 'haml'

# This is a rack app.
module GeeklistWS
  module Frontend	
	  class Web < Sinatra::Base
      helpers Sinatra::JSON

      configure do
        #set :id, '178608' - mathtrade 19
        #set :id, '180671' # mathtrade 19.5
        set :id, '185291' # mathtrade 20
        #set :id, '178867' #testlist
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

      get "/results*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_resultlist

        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        #@converter = GeeklistWS::Frontend::ListConverter.new data, params[:splat][0][1..-1]

        haml :jsonview
      end

      get "/json_results*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_resultlist(settings.id)

        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        #@converter = GeeklistWS::Frontend::ListConverter.new data, params[:splat][0][1..-1]

        json @data.to_json
      end

      get "/checklist" do
        @post = false
        haml :checklistview
      end

      post "/checklist" do
          puts "checklist"
          @post = true
          data = GeeklistWS::API::Internal.get_checklist(params["list"], settings.id)
          #puts data.inspect
          @converter = GeeklistWS::Frontend::CheckListConverter.new data
          haml :checklistview
      end
	  end
  end
end



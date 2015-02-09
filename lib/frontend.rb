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
        #set :id, '185291' # mathtrade 20
        #set :id, '178867' #testlist
        set :id, '187035' #mathtrade 20,5
        
        set :results, { 178608 => "https://dl.dropboxusercontent.com/u/17622107/MatHandel%20%2319%20-%20Wyniki.txt",
                        180671 => "https://dl.dropboxusercontent.com/u/17622107/MatHandel%20%2319,5%20-%20Wyniki.txt",
                        185291 => "https://dl.dropboxusercontent.com/u/17622107/MatHandel%20%2320%20-%20Wyniki.txt"
                      }
        set :lists, { 178608 => "https://dl.dropboxusercontent.com/u/17622107/MatHandel%20%2319%20-%20Listy.txt",
                        180671 => "https://dl.dropboxusercontent.com/u/17622107/MatHandel%20%2319,5%20-%20Listy.txt",
                        185291 => "https://dl.dropboxusercontent.com/u/17622107/MatHandel%20%2320%20-%20Listy.txt"
                      }
      end

      get "/" do 
        redirect '/list'
      end

      get "/list*" do
        puts "Method: GET, User: #{params[:bgguser]}"
        data = GeeklistWS::API::Internal.get_geeklist(settings.id)
        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        @converter = GeeklistWS::Frontend::ListConverter.new data, params[:splat][0][1..-1], params[:bgguser]

        haml :listview
      end

      get "/stats*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_stats(185291)

        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        #@converter = GeeklistWS::Frontend::ListConverter.new data, params[:splat][0][1..-1]

        haml :jsonview
      end

      get "/json_results*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_resultlist(185291, settings.results[185291])

        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        #@converter = GeeklistWS::Frontend::ListConverter.new data, params[:splat][0][1..-1]

        json @data.to_json
      end

      get "/json_lists*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_wantlist(185291, settings.lists[185291])

        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        #@converter = GeeklistWS::Frontend::ListConverter.new data, params[:splat][0][1..-1]

        json @data.to_json
      end

      get "/results*" do
        puts "Get"
        data = GeeklistWS::API::Internal.get_resultlist(185291, settings.results[185291])
        #data = GeeklistWS::API::Internal.get_geeklist("178867")
        @converter = GeeklistWS::Frontend::ResultsConverter.new data

        haml :resultsview
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

      error do
        "Application error. Probably BGG timeout. Please try again later."
      end
	  end
  end
end



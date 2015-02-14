require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/config_file'
require 'haml'

# This is a rack app.
module GeeklistWS
  module Frontend	
	  class Web < Sinatra::Base
      register Sinatra::ConfigFile
      helpers Sinatra::JSON

      root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      config_file File.join( [root, 'config.yml'] )

      get "/" do 
        haml :index
      end

      get "/list" do
        puts "Method: GET, User: #{params[:bgguser]} Button: #{params[:button]}"
        data = GeeklistWS::API::Internal.get_geeklist(params[:id].to_s)
        @converter = GeeklistWS::Frontend::ListConverter.new data, params[:button], params[:bgguser], settings.url

        haml :listview
      end

      get "/checklist" do
        @post = false
        @url = settings.url
        haml :checklistview
      end

      post "/checklist" do
          puts "checklist"
          @post = true
          @url = settings.url
          data = GeeklistWS::API::Internal.get_checklist(params["list"], settings.current_id)
          @converter = GeeklistWS::Frontend::CheckListConverter.new data, settings.url
          haml :checklistview
      end

      get "/results" do
        puts "Method: GET, ID: #{params[:id]}"
        data = GeeklistWS::API::Internal.get_resultlist(params[:id], settings.results[params[:id].to_i])
        @converter = GeeklistWS::Frontend::ResultsConverter.new data, settings.url

        haml :resultsview
      end

      get "/nottraded" do
        puts "Method: GET, ID: #{params[:id]}"
        nottradedlist = GeeklistWS::API::Internal.get_nottradedlist(params[:id], settings.results[params[:id].to_i])
        wantlist = GeeklistWS::API::Internal.get_wantlist(params[:id], settings.lists[params[:id].to_i], nottradedlist[:games])
        @converter = GeeklistWS::Frontend::NotTradedConverter.new nottradedlist, wantlist, settings.url, params[:name]

        haml :nottradedview
      end

      get "/stats*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_stats(settings.current_id)


        haml :jsonview
      end

      get "/json_results*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_resultlist(settings.current_id, settings.results[settings.current_id])

        json @data.to_json
      end

      get "/json_lists*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_wantlist(settings.current_id, settings.lists[settings.current_id], nil)


        json @data.to_json
      end

      get "/results*" do
        puts "Get"
        data = GeeklistWS::API::Internal.get_resultlist(settings.last_id, settings.results[settings.last_id])
        @converter = GeeklistWS::Frontend::ResultsConverter.new data, settings.url

        haml :resultsview
      end

      error do
        "Application error. Probably BGG timeout. Please try again later."
      end
	  end
  end
end



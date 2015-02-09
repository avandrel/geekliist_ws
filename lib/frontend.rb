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
        data = GeeklistWS::API::Internal.get_geeklist(settings.current_id.to_s)
        @converter = GeeklistWS::Frontend::ListConverter.new data, params[:button], params[:bgguser], settings.url

        haml :listview
      end

      post "/list" do
        puts "Method: POST, ID: #{params[:id]} User: #{params[:bgguser]}"
        data = GeeklistWS::API::Internal.get_geeklist(params[:id].to_s)
        @converter = GeeklistWS::Frontend::ListConverter.new data, params[:button], params[:bgguser], settings.url

        haml :listview
      end

      get "/results" do
        puts "Get"
        data = GeeklistWS::API::Internal.get_resultlist(settings.current_id, settings.results[settings.current_id])
        @converter = GeeklistWS::Frontend::ResultsConverter.new data, settings.url

        haml :resultsview
      end

      post "/results" do
        puts "Method: POST, ID: #{params[:id]}"
        data = GeeklistWS::API::Internal.get_resultlist(params[:id], settings.results[params[:id].to_i])
        @converter = GeeklistWS::Frontend::ResultsConverter.new data, settings.url

        haml :resultsview
      end

      get "/stats*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_stats(185291)


        haml :jsonview
      end

      get "/json_results*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_resultlist(185291, settings.results[185291])

        json @data.to_json
      end

      get "/json_lists*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_wantlist(185291, settings.lists[185291])


        json @data.to_json
      end

      get "/results*" do
        puts "Get"
        data = GeeklistWS::API::Internal.get_resultlist(185291, settings.results[185291])
        @converter = GeeklistWS::Frontend::ResultsConverter.new data, settings.url

        haml :resultsview
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

      error do
        "Application error. Probably BGG timeout. Please try again later."
      end
	  end
  end
end



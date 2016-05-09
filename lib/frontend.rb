require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/jsonp'
require 'sinatra/config_file'
require 'haml'

# This is a rack app.
module GeeklistWS
  module Frontend	
	  class Web < Sinatra::Base
      register Sinatra::ConfigFile
      helpers Sinatra::JSON
      helpers Sinatra::Jsonp

      root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      config_file File.join( [root, 'config.yml'] )

      get "/" do 
        haml :index
      end

      get "/list" do
        puts "Method: GET, User: #{params[:bgguser]} Button: #{params[:button]}"
        start = Time.now
        data = GeeklistWS::API::Internal.get_geeklist(params[:id].to_s, settings.url, settings.use_cache)
        data_time = Time.now
        halt(502, "Application error. Probably BGG timeout. Please try again later. Error message: #{data.message}") if data.is_a?(OpenURI::HTTPError)
        data[:id] = params[:id].to_s
        @converter = GeeklistWS::Frontend::ListConverter.new data, params[:button], params[:bgguser], settings.url
        converter_time = Time.now
        puts "Whole time: #{converter_time - start}[ms], Data: #{data_time - start}[ms], Converter: #{converter_time - start}[ms]"

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
          data = GeeklistWS::API::Internal.get_checklist(params["list"], settings.current_id, settings.url)
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
        puts "Method: GET, User: #{params[:bgguser]}, ID: #{params[:id]}"
        start = Time.now
        nottradedlist = GeeklistWS::API::Internal.get_nottradedlist(params[:id], settings.results[params[:id].to_i])
        nottradedlist_time = Time.now
        wantlist = GeeklistWS::API::Internal.get_wantlist(params[:id], settings.lists[params[:id].to_i], nottradedlist[:games])
        wantlist_time = Time.now
        @converter = GeeklistWS::Frontend::NotTradedConverter.new nottradedlist, wantlist, settings.url, params[:name]
        converter_time = Time.now
        puts "Whole time: #{converter_time - start}[ms], Nottraded: #{nottradedlist_time - start}[ms], Wantlist: #{wantlist_time - start}[ms], Converter: #{converter_time - start}[ms]"
        haml :nottradedview
      end

      get "/stats*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_stats(settings.current_id)


        haml :jsonview
      end

      get "/json_results*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_resultlist(settings.last_id, settings.results[settings.last_id])

        jsonp(@data)
      end

      get "/json_lists*" do
        puts "Get"
        @data = GeeklistWS::API::Internal.get_wantlist(settings.last_id, settings.lists[settings.last_id], nil)


        jsonp(@data)
      end

      get "/results*" do
        puts "Get"
        data = GeeklistWS::API::Internal.get_resultlist(settings.last_id, settings.results[settings.last_id])
        @converter = GeeklistWS::Frontend::ResultsConverter.new data, settings.url

        haml :resultsview
      end

      get "/partial_list" do
        puts "Method: GET, ID: #{params[:id]}"
        start = Time.now
        data = GeeklistWS::API::Internal.get_partial_geeklist(params[:id].to_s, settings.url)
        data_time = Time.now
        puts "Whole time: #{data_time - start}[ms]"
        data
      end

      error do
        "Application error. Probably BGG timeout. Please try again later."
      end
	  end
  end
end



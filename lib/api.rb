require 'grape'

module GeeklistWS
  module API
    class Api < Grape::API    

      namespace :geeklist do
        format :json

        get "/:id", requirements: { id: /[0-9]*/ } do
        	GeeklistWS::API::Internal.get_geeklist(params[:id])
        end
      end
    end  

    class Internal
      def self.get_geeklist(id, url, use_cache)
        mongo_client = create_client
        start_time = Time.now
        puts "Start reading geeklist"
        geeklist = GeeklistWS::API::Readers.read_geeklist(mongo_client, id, use_cache)
        geeklist_time = Time.now
        puts "Geeklist loaded, Elapsed: #{geeklist_time - start_time}[s]"
        games_finder = GeeklistWS::API::GamesFinder.new mongo_client, geeklist, url
        games_finder_time = Time.now
        puts "Finder initialized, Elapsed: #{games_finder_time - geeklist_time}[s]"
        games_finder.find_games
      end

      def self.get_partial_geeklist(id, url)
        mongo_client = create_client
        start_time = Time.now
        geeklist = GeeklistWS::API::Readers.read_geeklist(mongo_client, id)
        puts "Geeklist loaded: #{geeklist[:games].count}"
        games_finder = GeeklistWS::API::GamesFinder.new mongo_client, geeklist, url

        games_finder.refresh_games
      end

      def self.get_checklist(list, id, url)
        mongo_client = create_client
        start_time = Time.now
        puts "Api - id: #{id}"
        geeklist = get_geeklist(id, url)
        puts "Geeklist loaded"
        list_checker = GeeklistWS::API::ListChecker.new list.split(/\r\n/), geeklist
        response = list_checker.check
        puts "\nName: #{geeklist[:title]}, Elapsed: #{Time.now - start_time}s"
        response
      end

      def self.get_resultlist(id, url)
        mongo_client = create_client
        puts "Start reading geeklist"
        geeklist = GeeklistWS::API::Readers.read_geeklist(mongo_client, id)
        puts "Geeklist loaded"
        games_finder = GeeklistWS::API::GamesFinder.new mongo_client, geeklist, url
        
        resultlist = GeeklistWS::API::Readers.read_results mongo_client, id, url, true
        resultlist[:games] = games_finder.find_some_games resultlist[:games]
        resultlist
      end

      def self.get_nottradedlist(id, url)
        mongo_client = create_client
        puts "Start reading geeklist"
        geeklist = GeeklistWS::API::Readers.read_geeklist(mongo_client, id)
        puts "Geeklist loaded"
        games_finder = GeeklistWS::API::GamesFinder.new mongo_client, geeklist, url
        
        resultlist = GeeklistWS::API::Readers.read_results mongo_client, id, url, false
        games = games_finder.find_some_games resultlist[:games]
        resultlist[:games] = games unless games.nil?
        resultlist
      end

      def self.get_wantlist(id, url, games)
        mongo_client = create_client
        resultlist = GeeklistWS::API::Readers.read_wantlist(mongo_client, id, url, games)
        { :id => id, :wantlist => resultlist }
      end

      def self.get_stats(id)
        mongo_client = create_client
        resultlist = GeeklistWS::API::Stats.create_stats id
        resultlist
      end

      def self.create_client
        Mongo::Logger.logger.level = Logger::WARN
        MongoConnector.new
      end
    end

    class MongoConnector
        def initialize
            @connect = Mongo::Client.new("mongodb://geeklist_client:geeklist@ds063779.mongolab.com:63779/heroku_app29514506", :database => 'heroku_app29514506')
        end

    	def games_collection
            @connect["games"]
    	end

        def children_collection
            @connect["children"]
        end

        def posters_collection
            @connect["posters"]
        end

        def list_collection
            @connect["list_cache"]
        end

        def results_collection
            @connect["results"]
        end

        def wantlist_collection
            @connect["wantlists"]
        end

        def bggusers_collection
            @connect["bggusers"]
        end

    end
  end
end

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
      def self.get_geeklist(id)
        start_time = Time.now
        puts "Start reading geeklist"
        geeklist = GeeklistWS::API::Readers.read_geeklist(id)
        puts "Geeklist loaded"
        games_finder = GeeklistWS::API::GamesFinder.new geeklist
        response = games_finder.find_games
        response[:id] = id
        puts "\nName: #{geeklist[:title]}, Elapsed: #{Time.now - start_time}s"
        response
      end

      def self.get_partial_geeklist(id)
        start_time = Time.now
        geeklist = GeeklistWS::API::Readers.read_geeklist(id)
        puts "Geeklist loaded: #{geeklist[:games].count}"
        games_finder = GeeklistWS::API::GamesFinder.new geeklist

        counter = 0

        geeklist[:games].each do |game|
            games_finder.find_game(game)
            counter = counter + 1
            time = Time.now - start_time
            break if time > 27
        end
        "\nName: #{geeklist[:title]}, Elapsed: #{Time.now - start_time}s, Counter: #{counter}/#{geeklist[:games].count}"
      end

      def self.get_checklist(list, id)
        start_time = Time.now
        puts "Api - id: #{id}"
        geeklist = get_geeklist(id)
        puts "Geeklist loaded"
        list_checker = GeeklistWS::API::ListChecker.new list.split(/\r\n/), geeklist
        response = list_checker.check
        puts "\nName: #{geeklist[:title]}, Elapsed: #{Time.now - start_time}s"
        response
      end

      def self.get_resultlist(id, url)
        puts "Start reading geeklist"
        geeklist = GeeklistWS::API::Readers.read_geeklist(id)
        puts "Geeklist loaded"
        games_finder = GeeklistWS::API::GamesFinder.new geeklist
        
        resultlist = GeeklistWS::API::Readers.read_results id, url, true
        resultlist[:games] = games_finder.find_some_games resultlist[:games]
        resultlist
      end

      def self.get_nottradedlist(id, url)
        puts "Start reading geeklist"
        geeklist = GeeklistWS::API::Readers.read_geeklist(id)
        puts "Geeklist loaded"
        games_finder = GeeklistWS::API::GamesFinder.new geeklist
        
        resultlist = GeeklistWS::API::Readers.read_results id, url, false
        resultlist[:games] = games_finder.find_some_games resultlist[:games]
        resultlist
      end

      def self.get_wantlist(id, url, games)
        resultlist = GeeklistWS::API::Readers.read_wantlist id, url, games
        resultlist
      end

      def self.get_stats(id)
        resultlist = GeeklistWS::API::Stats.create_stats id
        resultlist
      end
    end

    class MongoConnector
    	def connect
#    		Mongo::Connection.new("ds063779.mongolab.com", "63779").db("heroku_app29514506")
            Mongo::Connection.from_uri("mongodb://geeklist_client:geeklist@ds063779.mongolab.com:63779/heroku_app29514506").db('heroku_app29514506')
 #           Mongo::Connection.from_uri("mongodb://localhost").db('geeklistws')
    	end
    	
    	def games_collection
            connect["games"]
    	end

        def children_collection
            connect["children"]
        end

        def posters_collection
            connect["posters"]
        end

        def list_collection
            connect["list_cache"]
        end

        def results_collection
            connect["results"]
        end

        def wantlist_collection
            connect["wantlists"]
        end

        def bggusers_collection
            connect["bggusers"]
        end

    end
  end
end

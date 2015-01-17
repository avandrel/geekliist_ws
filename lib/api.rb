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

      def self.get_resultlist(id)
        resultlist = GeeklistWS::API::Readers.read_results id
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
    end
  end
end

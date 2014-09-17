require 'grape'

module GeeklistWS
  module API
    class Api < Grape::API    

      namespace :geeklist do
        format :json

        get "/:id", requirements: { id: /[0-9]*/ } do
        	GeeklistWS::API::Internal.get(params[:id])
        end
      end
    end  

    class Internal
      def self.get(id)
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
    end

    class MongoConnector
    	def connect
#    		Mongo::Connection.new("ds063779.mongolab.com", "63779").db("heroku_app29514506")
            Mongo::Connection.from_uri("mongodb://geeklist_client:geeklist@ds063779.mongolab.com:63779/heroku_app29514506").db('heroku_app29514506')
 #           Mongo::Connection.from_uri("mongodb://localhost").db('geeklistws')
    	end
    	
    	def games_collection
    		#connect.authenticate("geeklist_client", "geeklist")
            connect["games"]
    	end

        def posters_collection
            connect["posters"]
        end

        def list_collection
            connect["list_cache"]
        end
    end
  end
end

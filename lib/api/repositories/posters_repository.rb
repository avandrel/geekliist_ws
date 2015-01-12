# encoding UTF-8

module GeeklistWS
  module API
    class PostersRepository
    	def initialize
    		connector = MongoConnector.new 
    		@posters_collection = connector.posters_collection
            @all_collection = {}
            connector.posters_collection.find().each do |poster|
                poster.delete("_id")
                symbolize_keys(poster)
                @all_collection[poster[:name]] = poster
            end
            @all_collection
    	end

    	def poster_in_repo?(name)
    		#@games_collection.find_one({:id => "#{id}"}, {:fields => [:id]}) != nil
            @all_collection.has_key?(name)
    	end

    	def add_poster(poster, avatar)  		
    		@posters_collection.insert({ :name => poster, :avatar => avatar })
    	end

    	def get_poster(name)
    		#merged_game = @games_collection.find_one({:id => "#{game[:id]}"})
            #merged_game.delete("_id")
            #symbolize_keys(merged_game)
            @all_collection[name].clone
    	end

        def symbolize_keys(poster)
            poster.keys.each do |key|
                poster[(key.to_sym rescue key) || key] = poster.delete(key)
            end
        end
    end
  end
end
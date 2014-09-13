module GeeklistWS
  module API
    class Repository
    	def initialize
    		connector = MongoConnector.new 
    		@games_collection = connector.games_collection
            @all_collection = {}
            connector.games_collection.find().each do |game|
                game.delete("_id")
                symbolize_keys(game)
                @all_collection[game[:id]] = game
            end
            @all_collection
    	end

    	def game_in_repo?(id)
    		#@games_collection.find_one({:id => "#{id}"}, {:fields => [:id]}) != nil
            @all_collection.has_key?(id)
    	end

    	def add_game(game)  		
    		game.delete(:poster) unless game[:poster] == nil
            game.delete(:number) unless game[:number] == nil
    		@games_collection.insert(game)
            symbolize_keys(game)
            game
    	end

    	def get_game(id)
    		#merged_game = @games_collection.find_one({:id => "#{game[:id]}"})
            #merged_game.delete("_id")
            #symbolize_keys(merged_game)
            @all_collection[id].clone
    	end

        def symbolize_keys(game)
            game.keys.each do |key|
                game[(key.to_sym rescue key) || key] = game.delete(key)
            end
        end
    end
  end
end
module GeeklistWS
  module API
    class Repository
    	def initialize
    		connector = MongoConnector.new 
    		@games_collection = connector.games_collection
    	end

    	def game_in_repo?(id, list_id)
    		@games_collection.find_one({:id => "#{id}", :list_id => "#{list_id}"}) != nil
    	end

    	def add_game(game,id)  		
    		game.delete(:poster) unless game[:poster] == nil
            game[:list_id] = id
    		@games_collection.insert(game)
            symbolize_keys(game)
            game
    	end

    	def get_game(game)
            poster = game[:poster]
            imageid = game[:imageid]
    		merged_game = @games_collection.find_one({:id => "#{game[:id]}"})
            merged_game.delete("_id")
            symbolize_keys(merged_game)
            merged_game[:poster] = poster
            merged_game[:imageid] = imageid
            merged_game
    	end

        def symbolize_keys(game)
            game.keys.each do |key|
                game[(key.to_sym rescue key) || key] = game.delete(key)
            end
        end
    end
  end
end
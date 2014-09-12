module GeeklistWS
  module API
    class Repository
    	def initialize
    		connector = MongoConnector.new 
    		@games_collection = connector.games_collection
    	end

    	def game_in_repo?(id)
    		@games_collection.find_one({:id => "#{id}"}) != nil
    	end

    	def add_game(game)  		
    		game.delete(:poster) unless game[:poster] == nil
    		@games_collection.insert(game)
    	end

    	def get_game(game)
            poster = game[:poster]
            imageid = game[:imageid]
    		merged_game = @games_collection.find_one({:id => "#{game[:id]}"})
            merged_game.delete("_id")
            merged_game["poster"] = poster
            merged_game["imageid"] = imageid
            merged_game
    	end
    end
  end
end
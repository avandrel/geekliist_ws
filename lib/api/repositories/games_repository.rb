# encoding UTF-8

module GeeklistWS
  module API
    class GamesRepository
    	def initialize
    		connector = MongoConnector.new 
    		@games_collection = connector.games_collection
    	end

    	def game_in_repo?(id)
    		@games_collection.find({:itemid => "#{id}"}).count() == 1
    	end

    	def add_game(game, geeklist_id)  		
    		game.delete(:poster) unless game[:poster] == nil
            game.delete(:number) unless game[:number] == nil
            game[:created] = (DateTime.now + rand(3)).to_time.utc
            game[:geeklist_id] = geeklist_id
            begin
    		  @games_collection.insert_one(game)
            rescue => ex
              puts ex.message
              return game.clone
            end
            symbolize_keys(game)
            game.clone
    	end

    	def get_game(id)
            game = @games_collection.find({:itemid => "#{id}"}).first()
            game.delete("_id")
            symbolize_keys(game)
            game
    	end

        def get_games(keys)
            result = {}
            @games_collection.find({:itemid => { "$in" => keys } }).each do |game|
                game.delete("_id")
                symbolize_keys(game)
                result[game[:itemid]] = game
            end
            result
        end

        def symbolize_keys(game)
            game.keys.each do |key|
                game[(key.to_sym rescue key) || key] = game.delete(key)
            end
        end
    end
  end
end
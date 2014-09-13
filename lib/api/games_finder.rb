module GeeklistWS
  module API
    class GamesFinder
    	def initialize(geeklist)
    		@geeklist = geeklist
    	end

    	def find_games
    		@repository = Repository.new
    		response = { :title => @geeklist[:title], :games => [] }
    		puts "Reading #{@geeklist[:games].count}"
            database_count = 0
            bgg_count = 0
    		@geeklist[:games].each do |game|
    			print_and_flush(".")
    			if @repository.game_in_repo?(game[:id])
    				#puts "Reading from repo #{game[:id]}"
                    database_count = database_count + 1
                    readed_game = @repository.get_game(game[:id])
                    readed_game[:number] = game[:number]
                    readed_game[:poster] = game[:poster]
                    readed_game[:imageid] = game[:imageid]
    				response[:games] << readed_game
    			else
    				#puts "Reading from BGG #{game[:id]}"
                    bgg_count = bgg_count + 1
    				readed_game = Readers.read_game(game)
    				added_game = @repository.add_game(readed_game)
    				added_game.delete(:_id) if added_game.has_key?(:_id)
                    added_game[:poster] = game[:poster]
    				response[:games] << added_game
    			end
    		end
            puts "\nFinished. Cached: #{database_count}, Online: #{bgg_count}"
    		response
    	end

      def print_and_flush(str)
    		print str
    		$stdout.flush
  	  end
    end
  end
end
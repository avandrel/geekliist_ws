module GeeklistWS
  module API
    class GamesFinder
    	def initialize(geeklist)
    		@geeklist = geeklist
    	end

    	def find_games
    		@repository = Repository.new
    		games = []
    		puts "Reading"
    		@geeklist[:games].each do |game|
    			print_and_flush(".")
    			if @repository.game_in_repo?(game[:id])
    				#puts "Reading from repo #{game[:id]}"
    				games << @repository.get_game(game)
    			else
    				#puts "Reading from BGG #{game[:id]}"
    				readed_game = Readers.read_game(game)
    				@repository.add_game(readed_game)
    				readed_game.delete(:_id) if readed_game.has_key?(:_id)
    				games << readed_game
    			end
    		end
    		games
    	end

      def print_and_flush(str)
    		print str
    		$stdout.flush
  	  end
    end
  end
end
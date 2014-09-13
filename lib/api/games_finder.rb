module GeeklistWS
  module API
    class GamesFinder
    	def initialize(geeklist)
    		@geeklist = geeklist
    	end

    	def find_games
    		@repository = Repository.new
    		response = { :title => @geeklist[:title], :games => [] }
    		puts "Reading"
    		@geeklist[:games].each do |game|
    			print_and_flush(".")
    			if @repository.game_in_repo?(game[:id], @geeklist[:id])
    				#puts "Reading from repo #{game[:id]}"
    				response[:games] << @repository.get_game(game)
    			else
    				#puts "Reading from BGG #{game[:id]}"
    				readed_game = Readers.read_game(game)
    				added_game = @repository.add_game(readed_game, @geeklist[:id])
    				added_game.delete(:_id) if added_game.has_key?(:_id)
                    added_game[:poster] = game[:poster]
    				response[:games] << added_game
    			end
    		end
    		response
    	end

      def print_and_flush(str)
    		print str
    		$stdout.flush
  	  end
    end
  end
end
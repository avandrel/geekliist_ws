module GeeklistWS
  module Frontend
    class Converter
    	def initialize(response)
    		@games = response[:games]
            @title = response[:title]
    	end

        def title
            @title
        end

    	def headers
    		["Id","Title", "Poster", "Average Rating", "Overall Rank"]
    	end

    	def games
    		prapared_games = []
            puts @games
    		@games.each do |game|
    			prapared_games << {
    				:number => game[:number],
    				:title => create_title(game[:id], game[:title], game[:imageid]),
    				:poster => create_poster(game[:poster]),
    				:average => create_number(game[:average]),
    				:boardgame => create_number(game[:boardgame])
    			}
    		end
    		prapared_games
    	end

    	def create_title(id, title, imageid)
    		"<a href=\"http://www.boardgamegeek.com/boardgame/#{id}\">#{create_image(imageid)} #{title}</a>"
    	end

    	def create_image(id)
    		"<img src=\"http://cf.geekdo-images.com/images/pic#{id}_t.jpg\" style=\"width:75px; height:75px;\"/>"
    	end

    	def create_poster(poster)
    		"<a href=\"http://www.boardgamegeek.com/user/#{poster}\">#{poster}</a>"
    	end

    	def create_number(number)
    		if number.to_i > 0 
    			return number
    		else
    			return "---"
    		end
    	end
    end
  end
end
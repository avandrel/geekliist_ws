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
    		@games.each do |game|
    			prapared_games << {
    				:number => game[:number],
    				#:title => create_title(game[:id], game[:title], game[:imageid]),
                    #:title => game[:title],
                    #:url => "http://www.boardgamegeek.com/boardgame/#{game[:id]}",
                    #:image => "http://cf.geekdo-images.com/images/pic#{game[:id]}_t.jpg",
    				:poster => create_poster(game[:poster]),
    				:average => create_number(game[:average]),
    				:boardgame => create_number(game[:boardgame]),
                    :desc => create_desc(game)
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

        def create_desc(game)
            description = { :ranks => {}}

            description[:url] = "http://www.boardgamegeek.com/boardgame/#{game[:id]}"
            description[:image] = "http://cf.geekdo-images.com/images/pic#{game[:imageid]}_t.jpg"
            description[:title] = game[:title]

            game.each do |key,value|
                    case key
                    when :abstracts
                        description[:ranks]["Abstract Game Rank"] = value unless value == 0
                    when :childrensgames
                        description[:ranks]["Children's Game Rank"] = value unless value == 0
                    when :cgs
                        description[:ranks]["Customizable Rank"] = value unless value == 0
                    when :familygames
                        description[:ranks]["Family Game Rank"] = value unless value == 0
                    when :partygames
                        description[:ranks]["Party Game Rank"] = value unless value == 0
                    when :strategygames
                        description[:ranks]["Strategy Game Rank"] = value unless value == 0
                    when :thematic
                        description[:ranks]["Thematic Game Rank"] = value unless value == 0
                    when :wargames
                        description[:ranks]["War Game Rank"] = value unless value == 0
                    end
            end
            description
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
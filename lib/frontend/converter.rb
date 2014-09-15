module GeeklistWS
  module Frontend
    class Converter
    	def initialize(response)
    		@games = response[:games]
            @title = response[:title]
            @posters = response[:posters]
            @id = response[:id]
    	end

        def id
            @id
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
    				:number => { :number => game[:number], :itemid => game[:itemid] },
    				#:title => create_title(game[:id], game[:title], game[:imageid]),
                    #:title => game[:title],
                    #:url => "http://www.boardgamegeek.com/boardgame/#{game[:id]}",
                    #:image => "http://cf.geekdo-images.com/images/pic#{game[:id]}_t.jpg",
    				:poster => { :name => game[:poster], :avatar => @posters[game[:poster]] },
    				:average => create_number(game[:average]),
    				:boardgame => create_number(game[:boardgame]),
                    :desc => create_desc(game),
                    :actual => check_actual(game[:body])
    			}
    		end
    		prapared_games
    	end

        def check_actual(body)
            !body.downcase.include?("nieaktualne")
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
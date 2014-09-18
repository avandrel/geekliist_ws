module GeeklistWS
  module Frontend
    class CheckListConverter
    	def initialize(response)
            @subdomains = GeeklistWS::Frontend::Subdomains.create_subdomains
            @id = response[:id]
            @exchanges = sort_games(response[:exchanges])
    	end

        def id
            @id
        end

        def subdomains
            @subdomains
        end

        def exchanges
            @exchanges
        end

    	def headers
    		["Id","Title", "Poster", "Average Rating", "Overall Rank"]
    	end

        def sort_games(exchanges)
            exchanges.each do |exchange|
                exchange[:priorities].each do |prio|
                    prio.sort_by! { |hsh| hsh[:title] }
                end
            end
            exchanges
        end

    	def games(priorities)
    		prapared_games = []
    		priorities.each do |game|
                prepared_game = {
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
                prapared_games << prepared_game if check_category(prepared_game[:desc])
    		end
    		prapared_games
    	end

        def check_actual(body)
            !body.downcase.include?("nieaktualne")
        end

        def create_desc(game)
            description = { :ranks => {}}
            description[:url] = "http://www.boardgamegeek.com/geeklist/#{@id}/item/#{game[:itemid]}#item#{game[:itemid]}"
            description[:image] = "http://cf.geekdo-images.com/images/pic#{game[:imageid]}_t.jpg"
            description[:title] = game[:title]
            description[:number] = game[:number]
            
            game.each do |key,value|
                if @subdomains.has_key?(key)
                    description[:ranks][@subdomains[key][:rank_name]] = value unless value == 0
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
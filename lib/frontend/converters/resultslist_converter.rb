# encoding UTF-8

module GeeklistWS
  module Frontend
    class ResultsConverter
    	def initialize(response)
    		@id = response[:id]
            @games = response[:games]
			@exchanges = create_exchanges(response[:items])
    	end

		def id
            @id
        end

        def exchanges
            @exchanges
        end

    	def headers
    		["Game", "Sends"]
    	end

        def create_exchanges items
        	result = []
            while true
                current_item = items.find {|item| !item[:receives].nil? && !item[:sends].nil? }
                break if current_item.nil?
                while true
                    current_item[:item][:desc] = {}
                    current_item[:item][:desc][:url] = "http://www.boardgamegeek.com/geeklist/#{@id}/item/#{@games[current_item[:item][:game_id]][:itemid]}#item#{@games[current_item[:item][:game_id]][:itemid]}"
                    current_item[:item][:desc][:image] = "http://cf.geekdo-images.com/images/pic#{@games[current_item[:item][:game_id]][:imageid]}_t.jpg"
                    current_item[:item][:desc][:title] = @games[current_item[:item][:game_id]][:title]
                    current_item[:item][:desc][:number] = current_item[:item][:game_id]

                    current_item[:receives][:desc] = {}
                    current_item[:receives][:desc][:url] = "http://www.boardgamegeek.com/geeklist/#{@id}/item/#{@games[current_item[:receives][:game_id]][:itemid]}#item#{@games[current_item[:receives][:game_id]][:itemid]}"
                    current_item[:receives][:desc][:image] = "http://cf.geekdo-images.com/images/pic#{@games[current_item[:receives][:game_id]][:imageid]}_t.jpg"
                    current_item[:receives][:desc][:title] = @games[current_item[:receives][:game_id]][:title]
                    current_item[:receives][:desc][:number] = current_item[:receives][:game_id]

                    current_item[:sends][:desc] = {}
                    current_item[:sends][:desc][:url] = "http://www.boardgamegeek.com/geeklist/#{@id}/item/#{@games[current_item[:sends][:game_id]][:itemid]}#item#{@games[current_item[:sends][:game_id]][:itemid]}"
                    current_item[:sends][:desc][:image] = "http://cf.geekdo-images.com/images/pic#{@games[current_item[:sends][:game_id]][:imageid]}_t.jpg"
                    current_item[:sends][:desc][:title] = @games[current_item[:sends][:game_id]][:title]
                    current_item[:sends][:desc][:number] = current_item[:sends][:game_id]
                    result << current_item

                    items.delete(current_item)

                    current_item = items.find {|item| item[:item][:game_id] == current_item[:sends][:game_id] }
                    break if current_item.nil?
                end
            end

	       	result
        end
    end
  end
end
# encoding UTF-8

module GeeklistWS
  module Frontend
    class NotTradedConverter
    	def initialize(results, wantlist, url, bgguser)
    		@id = results[:id]
            @games = results[:games]
            @wants = convert_wants(wantlist, results[:nottraded])
			@results = create_lefts(results[:nottraded], bgguser)
            @url = url
    	end

		def id
            @id
        end

        def lefts
            @results[:nottraded]
        end

        def wants
            @wants
        end

    	def headers
    		["Got", "For"]
    	end

        def create_lefts nottraded, bgguser
        	result = { :nottraded => [] }
            nottraded.each do |current_item|
                current_item[:item][:desc] = {}
                current_item[:item][:desc][:url] = "http://www.boardgamegeek.com/geeklist/#{@id}/item/#{@games[current_item[:item][:game_id]][:itemid]}#item#{@games[current_item[:item][:game_id]][:itemid]}"
                current_item[:item][:desc][:image] = "http://cf.geekdo-images.com/images/pic#{@games[current_item[:item][:game_id]][:imageid]}_t.jpg"
                current_item[:item][:desc][:title] = @games[current_item[:item][:game_id]][:title]
                current_item[:item][:desc][:number] = current_item[:item][:game_id]

                if (@wants.has_key?(current_item[:item][:desc][:number]) && bgguser.nil?) || 
                    (@wants.has_key?(current_item[:item][:desc][:number]) && current_item[:item][:user_id] == bgguser.upcase)
                    result[:nottraded] << current_item 
                end
            end

	       	result
        end

        def convert_wants wants, nottraded
            result = {}
            nottraded_collection = create_nottraded(nottraded)
            wants.each do |want|
                result[want[:from].to_s] = find_in_want(want, wants, nottraded_collection)
            end
            result
        end

        def find_in_want want, wants, nottraded
            found = []
            wants.each do |want_from_list| 
                want_from_list[:to].each do |to_element|
                    if to_element.include?(want[:from].to_s) && nottraded.include?(want_from_list[:from].to_s)
                        want_from_list[:desc] = {}
                        want_from_list[:desc][:url] = "http://www.boardgamegeek.com/geeklist/#{@id}/item/#{@games[want_from_list[:from].to_s][:itemid]}#item#{@games[want_from_list[:from].to_s][:itemid]}"
                        want_from_list[:desc][:image] = "http://cf.geekdo-images.com/images/pic#{@games[want_from_list[:from].to_s][:imageid]}_t.jpg"
                        want_from_list[:desc][:title] = @games[want_from_list[:from].to_s][:title]
                        want_from_list[:desc][:number] = want_from_list[:from].to_s
                        found << want_from_list
                    end
                end
            end
            found
        end

        def create_nottraded(nottraded)
            result = []
            nottraded.each do |item|
                result << item[:item][:game_id]
            end
            result
        end
    end
  end
end
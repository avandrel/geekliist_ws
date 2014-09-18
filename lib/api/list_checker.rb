module GeeklistWS
  module API
    class ListChecker
		def initialize(list, geeklist)
			@list = list
			@geeklist = geeklist
		end

		def check
			response = { :exchanges => [] }
			@list.each do |element|
				array_element = element.scan(/[(](.*)[)] ([0-9]*) : (.*)/)
				array_prio = array_element[0][2].include?(";") ? array_element[0][2].split(';').map! {|x| x.split(" ")} : [array_element[0][2].split(" ")]
				hash_element = { :poster => array_element[0][0], :priorities => {}}
				response[:exchanges] << fill_games(hash_element, array_prio, array_element[0][1])
			end
			response[:id] = @geeklist[:id]
			response
		end		

		def fill_games(hash_element, array_prio, id)
			array_prio.map! { |priority| priority.map! { |game_id| 
				get_by_id(game_id)
				}}
			hash_element[:from] = get_by_id(id)
			hash_element[:priorities] = array_prio
			hash_element
		end

		def get_by_id(game_id)
			id = @geeklist[:games].find_index { |item| item[:number] == game_id.to_i }
			@geeklist[:games][id]
		end

		def find_id(game_id)
			id = @geeklist[:games].find_index { |item| item[:number] == game_id.to_i }
			@geeklist[:games][id][:id]
		end
    end
  end
end
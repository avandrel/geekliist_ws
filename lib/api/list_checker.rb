#!/bin/env ruby
# encoding: utf-8

module GeeklistWS
  module API
    class ListChecker
		def initialize(list, geeklist)
			@list = list
			@geeklist = geeklist
			@errors = { :wrong_line => [], :missing_alias => [], :missing_game => []}
		end

		def check
			response = { :exchanges => [] }
			exchanges = []
			aliases = []
			@list.each do |element|
				is_added = false
				element_array = element.scan(/[(](.*)[)] ([0-9]*) ?:\s?(.*)/)
				unless element_array.empty? 
					exchange_hash = { :poster => element_array[0][0], :from => element_array[0][1], :to => element_array[0][2]} 
					exchanges << exchange_hash
					is_added = true
				end

				alias_array = element.scan(/[(].*[)] (%[^ ]*) ?:\s?(.*)/)
				unless alias_array.empty?
					alias_hash = {:id => alias_array[0][0], :elements => alias_array[0][1]} 
					aliases << alias_hash
					is_added = true
				end

				unless is_added
					@errors[:wrong_line] << element unless element.empty?
				end
			end
			puts "List readed"
			@alias_collection = prepare_aliases(aliases)
			puts "Aliases prepared"
			@exchange_collection = prepare_exchanges(exchanges)
			puts "Exchanges prepared"
			response[:exchanges] << fill_games()
			response[:id] = @geeklist[:id]
			response[:errors] = @errors
			response[:original_list] = @list.join("\r")
			response
		end		

		def prepare_exchanges(exchanges)
			exchange_collection = []
			while exchanges.count > 0
				exchanges.delete_if { |exchange|
					exchange_collection << {:poster => exchange[:poster], :from => prepare(exchange[:from]), :to => prepare(exchange[:to])} if (!exchange[:from].include?("%") && !exchange[:to].include?("%"))
				}
				exchanges.select { |ex| ex[:from].include?("%") }.each do |ex|
					ex[:from].scan(/(%[0-9a-zA-ZĄąĘęÓóĄąŚśŁłŻżŹźĆćŃń_]*)/).each do |a|
						ex[:from][a[0]] = @alias_collection[a[0]]
					end
				end
				exchanges_to_delete = []
				exchanges.select { |ex| ex[:to].include?("%") }.each do |ex|
					ex[:to].scan(/(%[0-9a-zA-ZĄąĘęÓóĄąŚśŁłŻżŹźĆćŃń_]+)/).each do |a|
						if @alias_collection.has_key?(a[0])
							ex[:to][a[0]] = @alias_collection[a[0]]
						else
							puts @alias_collection.inspect
							exchanges_to_delete << ex
							@errors[:missing_alias] << a[0]
						end
					end
				end

				unless exchanges_to_delete.empty?
					exchanges_to_delete.each do |ex|
						exchanges.delete(ex)
					end
				end
			end
			exchange_collection
		end

		def prepare(to)
			to.include?(";") ? to.split(';').map! {|x| x.split(" ")} : [to.split(" ")]
		end

		def prepare_aliases(aliases)
			alias_collection = {}
			while aliases.count > 0
				aliases.delete_if {|a| alias_collection[a[:id]] = a[:elements] if !a[:elements].include?("%")}
				alias_collection.each do |key, value|
					aliases.select { |al| al[:elements].include?(key) }.each do |selected|
						selected[:elements][key] = value
					end
				end
			end
			alias_collection
		end

		def fill_games()
			@exchange_collection.each do |exchange|
				exchange[:to].map! { |to| to.map! { |game_id| get_by_id(game_id) } }
				exchange[:from].map! { |from| from.map! { |game_id| get_by_id(game_id) } }
			end	
		end

		def get_by_id(game_id)
			id = @geeklist[:games].find_index { |item| item[:number] == game_id.to_i }
			if !id.nil?
				game = @geeklist[:games][id]
				aliases = []
				@alias_collection.each do |key, value|
					if value.split(" ").include?(game_id)
						aliases << key
					end
				end
				game[:aliases] = aliases
				return game
			else
				@errors[:missing_game] << game_id
			end
			nil
		end

		def find_id(game_id)
			id = @geeklist[:games].find_index { |item| item[:number] == game_id.to_i }
			@geeklist[:games][id][:id]
		end
    end
  end
end
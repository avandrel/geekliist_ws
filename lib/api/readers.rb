#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'open-uri'

module GeeklistWS
  module API
	class Readers
	  	def self.read_geeklist(id)
	  		list_repository = ListRepository.new
	  		if list_repository.list_in_repo?(id)
	  			puts "List from cache"
	  			list = list_repository.get_list(id)
	  		else
	  			puts "List from BGG => http://www.boardgamegeek.com/xmlapi/geeklist/#{id}?comments=1"
	  			list = open("http://www.boardgamegeek.com/xmlapi/geeklist/#{id}?comments=1").read
	  			list_repository.add_list(id, list)
	  		end
	  		doc = Nokogiri::HTML(list, nil, "UTF-8")
	  		geeklist = {:games => {}}
	  		geeklist[:title] = doc.at_xpath("//title").content
	  		geeklist[:id] = doc.at_xpath("//geeklist").attribute('id').value
	  		doc.xpath("//item").each do |item|
	  			parsed_item = Parsers.parse_item(item, geeklist[:games].length + 1)
	  			geeklist[:games][parsed_item[:itemid]] = parsed_item
	  		end
	  		geeklist
	  	end

	  	def self.read_game(game)
	  		begin
	  			sleep(0.1)
	  			doc = Nokogiri::HTML(open("http://www.boardgamegeek.com/xmlapi/boardgame/#{game[:id]}?stats=1"))
	  		rescue => ex
	  			return ex
	  		end
	  		ratings = Parsers.parse_rating(doc.xpath("//boardgames/boardgame/statistics/ratings"))
	  		game.merge!(ratings)
	  		boardgame = Parsers.parse_boardgame(doc.xpath("//boardgames/boardgame"))
	  		game.merge!(boardgame)
	  		#poll_numplayers = Parsers.parse_poll_numplayers(doc.xpath("//boardgames/boardgame/poll"))
	  		#game.merge(boardgame)
	  	end

	  	def self.read_child(id)
	  		begin
	  			sleep(0.1)
	  			doc = Nokogiri::HTML(open("http://www.boardgamegeek.com/xmlapi/boardgame/#{id}?stats=1"))
	  		rescue => ex
	  			puts "#{ex.message}"
	  			return ex
	  		end
	  		child ||= {}
	  		child[:id] = id
	  		child[:title] = doc.xpath('//boardgames/boardgame/name[@primary]')[0].text
            child[:thumb_url] = doc.xpath("//boardgames/boardgame/thumbnail").text[2..-1]
            child
	  	end

	  	def self.read_poster(name)
	  		begin
	  			sleep(0.1)
	  			doc = Nokogiri::HTML(open(URI.encode("http://www.boardgamegeek.com/xmlapi2/user?name=#{name}")))
	  		rescue => ex
	  			puts "#{ex.message}"
	  			return ex
	  		end
	  		doc.at_xpath("//avatarlink").attribute('value').value
	  	end

	  	def self.read_posters_collection(name)
	  		begin
	  			sleep(0.1)
	  			doc = Nokogiri::HTML(open(URI.encode("http://www.boardgamegeek.com/xmlapi/collection/#{name}")))
	  		rescue => ex
	  			puts "#{ex.message}"
	  			return ex
	  		end
	  		if doc.xpath("//message").empty?
	  			collection ||= {}
	  			doc.xpath("//item").each do |item|
	  				parsed_item = Parsers.parse_collection_item(item)
	  				collection[parsed_item[:id]] = parsed_item
	  			end
	  		end
	  		collection
	  	end
	  		
	  	def self.read_results(id, url, gettraded)
	  		results_repository = ResultsRepository.new
	  		if results_repository.result_in_repo?(id)
	  			result = results_repository.get_result(id)
	  			result
	  		else
		  		file = open(url)
		  		trades = { :traded => [], :nottraded => [] }
		  		games = []
		  		file.readlines.each do |line|
					scaned_line = line.scan(/[(](.+)[)]\s(\d+)\s+receives\s[(](.+)[)]\s+(\d+)\s+and sends to\s[(](.+)[)]\s+(\d+)/)
					if !scaned_line.empty? 
						games << scaned_line[0][1] unless games.include?(scaned_line[0][1])
						if gettraded
							trades[:traded] << { :item => { :user_id => scaned_line[0][0], :game_id => scaned_line[0][1] }, 
											:receives => { :user_id => scaned_line[0][2], :game_id => scaned_line[0][3] },
											:sends => { :user_id => scaned_line[0][4], :game_id => scaned_line[0][5] }
										}
						end	
					end
					scaned_line = line.scan(/[(](.+)[)]\s(\d+)\s+does not trade/)
					if !scaned_line.empty?
						trades[:nottraded] << { :item => { :user_id => scaned_line[0][0], :game_id => scaned_line[0][1] } }
						games << scaned_line[0][1] unless games.include?(scaned_line[0][1])		
					end
				end
				{ :id => id, :items => trades[:traded], :nottraded => trades[:nottraded], :games => games}
			end
	  	end

	  	def self.read_wantlist(id, url, games)
	  		puts "Reading wantlist"
			wantlist_repository = WantlistRepository.new
	  		#if wantlist_repository.wantlist_in_repo?(id)
	  			#result = wantlist_repository.get_wantlist(id)
	  			#puts result.inspect
	  			#unless games.nil?
					#result[:wantlist].delete_if {|list| 
						#!games.include?(list[:from].to_s) }
				#end
	  			#result
	  		#else
		  		file = open(url)
		  		wants = []
				aliases = []
		  		file.readlines.each do |line|
		  			is_added = false
					element_array = line.scan(/^[(](.*)[)] ([0-9]*)\s?: (.*)/)
		  			unless element_array.empty? 
						exchange_hash = { :poster => element_array[0][0], :from => element_array[0][1], :to => element_array[0][2]} 
						wants << exchange_hash
						is_added = true
					end

					alias_array = line.scan(/^[(](.*)[)] (%.*)\s?: (.*)/)
					unless alias_array.empty?
						alias_hash = { :poster => alias_array[0][0].strip, :id => alias_array[0][1].strip, :elements => alias_array[0][2].strip} 
						aliases << alias_hash
						is_added = true
					end
		  		end
		  		puts "List readed"
				@alias_collection = prepare_aliases(aliases)
				#puts aliases.inspect
				#puts @alias_collection.inspect
				@wantlist_collection = prepare_wantlist(wants)
			#end

	  	end

	  	def self.prepare_wantlist(wants)
			wants_collection = []
			while wants.count > 0
				wants.delete_if { |wants|
					wants_collection << {:poster => wants[:poster], :from => wants[:from], :to => prepare(wants[:to])} if (!wants[:from].include?("%") && !wants[:to].include?("%"))
				}
				wants.select { |ex| ex[:from].include?("%") }.each do |ex|
					ex[:from].scan(/(%[0-9a-zA-ZĄąĘęÓóĄąŚśŁłŻżŹźĆćŃńÉéÀàÄäÜü_-]*)/).each do |a|
						ex[:from][a[0]] = @alias_collection[ex[:poster]][a[0]]
					end
				end
				wants_to_delete = []
				wants.select { |ex| ex[:to].include?("%") }.each do |ex|
					ex[:to].scan(/(%[0-9a-zA-ZĄąĘęÓóĄąŚśŁłŻżŹźĆćŃńÉéÀàÄäÜü_-]*)/).each do |a|
						if @alias_collection[ex[:poster]].has_key?(a[0])
							ex[:to][a[0]] = @alias_collection[ex[:poster]][a[0]]
						else
							wants_to_delete << ex
							puts "Missing alias for #{ex[:poster]}: #{a[0]}"
						end
					end
				end

				unless wants_to_delete.empty?
					wants_to_delete.each do |ex|
						wants.delete(ex)
					end
				end
			end
			wants_collection
		end

		def self.prepare(to)
			to.include?(";") ? to.split(';').map! {|x| x.split(" ")} : [to.split(" ")]
		end

		def self.prepare_aliases(aliases)
			alias_collection = {}
			while aliases.count > 0
				aliases.delete_if {|a| add_elem_to_hash(a, alias_collection) if !a[:elements].include?("%")}
				aliases.each do |alias_in_aliases|
					if alias_in_aliases[:elements].include?("%")
						found_aliases = alias_in_aliases[:elements].scan(/(%[0-9a-zA-ZĄąĘęÓóĄąŚśŁłŻżŹźĆćŃń_]*)/)
						i = 0
						while i < found_aliases.count
							if alias_collection[alias_in_aliases[:poster]].has_key?(found_aliases[i][0])
								alias_in_aliases[:elements].sub!(found_aliases[i][0], alias_collection[alias_in_aliases[:poster]][found_aliases[i][0]])
							end
							i += 1
						end
					end
				end
			end
			alias_collection
		end

		def self.add_elem_to_hash(elem, alias_collection)
			if alias_collection[elem[:poster]].nil?
				alias_collection[elem[:poster]] = {}
			end
			alias_collection[elem[:poster]][elem[:id]] = elem[:elements]
		end

		def self.print_and_flush(str)
    		print str
    		$stdout.flush
  	  	end
	end
  end
end
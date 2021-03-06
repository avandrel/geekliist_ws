# encoding UTF-8

require 'nokogiri'

module GeeklistWS
  module API
    class Parsers
    	def self.parse_item(item, number)
    		game = {}
    		game[:id] = item.attribute('objectid').value
    		game[:title] = item.attribute('objectname').value
    		game[:poster] = item.attribute('username').value
            game[:imageid] = item.attribute('imageid').value
            game[:itemid] = item.attribute('id').value
            game[:thumbs] = item.attribute('thumbs').value
    		game[:number] = number
            game[:body] = item.children[0].text unless item.children[0].nil?
            game[:children] = []
            item.children.each do |child|
                if  child.name == "comment"
                    game_child = {}
                    matchdata = child.children[0].text.match(/\[\D*thing=(\d*)\D*\]/)
                    unless  matchdata.nil?
                        game_child[:id] = matchdata[1]
                        game_child[:body] = matchdata[0]
                        game_child[:poster] = game[:poster]
                        game[:children] << game_child
                    end
                end
            end
  		game
    	end

    	def self.parse_rating(rating)
    		hash_rating = {}
    		hash_rating[:average] = rating.at_xpath("//average").content unless rating.at_xpath("//average").nil?
            unless rating.at_xpath("//numweights").nil?
                numweights = rating.at_xpath("//numweights").content.to_i 
                hash_rating[:averageweight] = rating.at_xpath("//averageweight").content unless numweights <= 10
            end
    		rating.xpath("//ranks/rank").each do |rank|
    			hash_rating[rank.attribute('name').value.to_sym] = rank.attribute('value').value.to_i
    		end
    		hash_rating
    	end

        def self.parse_boardgame(boardgame)
            hash_boardgame = {}
            hash_boardgame[:minplayers] = boardgame.at_xpath("//minplayers").content unless boardgame.at_xpath("//minplayers").nil?
            unless boardgame.at_xpath("//maxplayers").nil?
                maxplayers = boardgame.at_xpath("//maxplayers").content
                hash_boardgame[:maxplayers] = maxplayers unless hash_boardgame[:minplayers] == maxplayers
            end
            hash_boardgame
        end

        def self.parse_poll_numplayers(polls)
            hash_poll = {}
            polls.children.each do |child|
                if child.name = "suggested_numplayers"
                    puts parse_results(child.at_xpath("//results"))
                end
            end
            hash_poll
        end

        def self.parse_results(results)
            results.children
        end

        def self.parse_collection_item(item)
            collection_item = {}
            collection_item[:id] = item.attribute('objectid').value
            item.children.each do |child|
                if child.name == "status"
                    collection_item[:own] = child.attribute('own').value
                    collection_item[:prevowned] = child.attribute('prevowned').value
                    collection_item[:fortrade] = child.attribute('fortrade').value
                    collection_item[:want] = child.attribute('want').value
                    collection_item[:wanttoplay] = child.attribute('wanttoplay').value
                    collection_item[:wanttobuy] = child.attribute('wanttobuy').value
                    collection_item[:wishlist] = child.attribute('wishlist').value
                    collection_item[:preordered] = child.attribute('preordered').value
                end
            end
            collection_item
        end
    end
  end
end
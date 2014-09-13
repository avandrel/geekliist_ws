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
    		game[:number] = number
  		game
    	end

    	def self.parse_rating(rating)
    		hash_rating = {}
    		hash_rating[:average] = rating.at_xpath("//average").content
    		rating.xpath("//ranks/rank").each do |rank|
    			hash_rating[rank.attribute('name').value.to_sym] = rank.attribute('value').value.to_i
    		end
    		hash_rating
    	end
    end
  end
end
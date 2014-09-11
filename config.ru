require 'grape'
require 'nokogiri'
require 'open-uri'
require 'mongo'

Dir[File.dirname(__FILE__) + '/*.rb'].each {|f| require f}

run GeeklistWS::API
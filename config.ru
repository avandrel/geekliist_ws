require 'mongo'

Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|f| require f}

run Rack::Cascade.new [GeeklistWS::API::Api, GeeklistWS::Frontend::Web]
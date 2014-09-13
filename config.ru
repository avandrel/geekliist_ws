require 'mongo'
require 'newrelic_rpm'

Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|f| require f}

NewRelic::Agent.manual_start
run Rack::Cascade.new [GeeklistWS::API::Api, GeeklistWS::Frontend::Web]
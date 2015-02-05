require 'mongo'
require 'newrelic_rpm'

Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|f| require f}

NewRelic::Agent.manual_start
use Rack::Deflater
use Rack::Static, 
  :urls => ["/public/img", "/public/js", "/public/css"]
run Rack::Cascade.new [GeeklistWS::API::Api, GeeklistWS::Frontend::Web]
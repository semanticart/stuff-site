require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :views => File.dirname(__FILE__) + "/views"
)
 
require 'stuff.rb'
run Sinatra.application

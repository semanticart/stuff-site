require 'rubygems'
require 'sinatra'
require 'redcloth'
require 'coderay'

layout "layout.erb"

configure do
  require 'useful_tidbits'
end

get '/' do
  erb(:index)
end

get '/:thingie' do
  @thingie = THINGIES.find {|t| t.permalink == params[:thingie] }
  @thingie ? erb(:show) : "This is a very ugly 404 page."
end
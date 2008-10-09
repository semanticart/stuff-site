require 'rubygems'
require 'sinatra'
require 'redcloth'
require 'coderay'

layout "layout.erb"

configure do
  require 'useful_tidbits'
  
  thingie_paths = Dir.glob(File.join(File.dirname(__FILE__), 'thingies', '*.textile'))
  thingies = thingie_paths.map {|path| Thingie.new(path) }.sort_by {|l| l.created_at }

  thingies_grouped_by_topic = thingies.inject({}) do |hash, thingie|
    hash[thingie.topic] ||= []
    hash[thingie.topic] << thingie
    hash
  end

  ALL_THINGIES = thingies
  GROUPED_THINGIES = thingies_grouped_by_topic
end

get '/' do
  erb(:index)
end

get '/tidbits/rss' do
  headers['Content-Type'] =  'text/xml;charset=utf-8'
  erb :rss, :layout => false
end

get '/:thingie' do
  @thingie = ALL_THINGIES.find {|t| t.permalink == params[:thingie] }
  @thingie ? erb(:show) : "This is a very ugly 404 page."
end
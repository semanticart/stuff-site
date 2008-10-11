require 'rubygems'
require 'sinatra'
require 'redcloth'
require 'coderay'

layout "layout.erb"

configure do
  require 'useful_tidbits'
  
  thingie_paths = Dir.glob(File.join(File.dirname(__FILE__), 'thingies', '*.textile'))
  ALL_THINGIES = thingie_paths.map {|path| Thingie.new(path) }.sort_by {|l| l.created_at }.reverse
end

helpers do
  def page_title
    title = []
    title << 'stuff'
    
    if @thingie
      title << @thingie.topic
      title << @thingie.title
    end
    
    title.join(' - ')
  end
end

get '/' do
  erb(:index)
end

get '/tidbits/rss' do
  headers['Content-Type'] =  'text/xml;charset=utf-8'
  erb :rss, :layout => false
end

get '/topic/:name' do
  @thingies = ALL_THINGIES.find_all {|t| t.topic == params[:name] }
  @thingies.empty? ? "This is a very ugly 404 page." : erb(:topic)
end

get '/:thingie' do
  @thingie = ALL_THINGIES.find {|t| t.permalink == params[:thingie] }
  @thingie ? erb(:show) : "This is a very ugly 404 page."
end
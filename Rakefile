desc "Rsyncs the stuff to the remote serverz hosting the websitez."
task :upload_stuff do
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

  # FIXME: I don't know how rsync works. I could probably do this in one operation.
  system "rsync -avH thingies/ #{CONFIG['remote_thingies']}"
  system "rsync -avH public/images/ #{CONFIG['remote_images']}"
end

desc "Creates a static copy of your site by iterating your thingies."
task :make_static do
  static_dir = File.join(File.dirname(__FILE__), 'static')
  Dir.mkdir(static_dir) unless File.directory?(static_dir)

  require 'sinatra'
  Sinatra::Application.default_options.merge!(
    :run => false,
    :env => :production,
    :views => File.dirname(__FILE__) + "/views"
  )

  require 'stuff'

  @request = Rack::MockRequest.new(Sinatra.application)
  
  # the index
  File.open(File.join(static_dir, 'index.html'), 'w'){|f| f.print @request.request('get', '/').body}

  # the rss
  Dir.mkdir(File.join(static_dir, 'tidbits')) unless File.directory?(File.join(static_dir, 'tidbits'))
  File.open(File.join(static_dir, 'tidbits', 'rss'), 'w'){|f| f.print @request.request('get', '/tidbits/rss').body}
  
  # the thingies
  ALL_THINGIES.each do |thingie|
    Dir.mkdir(File.join(static_dir, thingie.permalink)) unless File.directory?(File.join(static_dir, thingie.permalink))
    File.open(File.join(static_dir, thingie.permalink, 'index.html'), 'w'){|f| f.print @request.request('get', "/#{thingie.permalink}").body}    
  end
  
  # the topics
  Dir.mkdir(File.join(static_dir, 'topic')) unless File.directory?(File.join(static_dir, 'topic'))
  ALL_THINGIES.map{|thing| thing.topic}.uniq.each do |topic|
    Dir.mkdir(File.join(static_dir, 'topic', topic)) unless File.directory?(File.join(static_dir, 'topic', topic))
    File.open(File.join(static_dir, 'topic', topic, 'index.html'), 'w'){|f| f.print @request.request('get', "/topic/#{topic}").body}
  end
end
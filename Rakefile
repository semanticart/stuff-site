desc "Rsyncs the stuff to the remote serverz hosting the websitez."
task :upload_stuff do
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

  # FIXME: I don't know how rsync works. I could probably do this in one operation.
  system "rsync -avH thingies/ #{CONFIG['remote_thingies']}"
  system "rsync -avH public/images/ #{CONFIG['remote_images']}"
end

desc "Creates a static copy of your site by iterating your thingies."
task :make_static do
  def dump_request_to_file url, file
    Dir.mkdir(File.dirname(file)) unless File.directory?(File.dirname(file))
    File.open(file, 'w'){|f| f.print @request.request('get', url).body}
  end

  static_dir = File.join(File.dirname(__FILE__), 'static')

  require 'sinatra'
  Sinatra::Application.default_options.merge!(
    :run => false,
    :env => :production,
    :views => File.dirname(__FILE__) + "/views"
  )

  require 'stuff'

  @request = Rack::MockRequest.new(Sinatra.application)
  
  # the index
  dump_request_to_file('/', File.join(static_dir, 'index.html'))

  # the rss
  dump_request_to_file('/tidbits/rss', File.join(static_dir, 'tidbits', 'rss'))
  
  # the thingies
  ALL_THINGIES.each do |thingie|
    dump_request_to_file("/#{thingie.permalink}", File.join(static_dir, thingie.permalink, 'index.html'))
  end
  
  # the topics
  Dir.mkdir(File.join(static_dir, 'topic')) unless File.directory?(File.join(static_dir, 'topic'))
  ALL_THINGIES.map{|thing| thing.topic}.uniq.each do |topic|
    dump_request_to_file("/topic/#{topic}", File.join(static_dir, 'topic', topic, 'index.html'))
  end
end
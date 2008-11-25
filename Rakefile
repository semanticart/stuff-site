CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

desc "Rsyncs the stuff to the remote serverz hosting the websitez."
task :upload_stuff do
  # FIXME: I don't know how rsync works. I could probably do this in one operation.
  puts "rsync -avH thingies/ #{CONFIG['remote_thingies']}"
  puts "rsync -avH public/images/ #{CONFIG['remote_images']}"
end
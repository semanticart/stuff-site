desc "Rsyncs the stuff to the remote serverz hosting the websitez."
task :upload_stuff do
  # FIXME: I don't know how rsync works. I could probably do this in one operation.
  system "rsync -avH thingies/ lilleaas.net:sites/stuff/thingies/"
  system "rsync -avH public/images/ lilleaas.net:sites/stuff/public/images/"
end
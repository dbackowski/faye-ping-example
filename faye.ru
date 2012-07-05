require 'faye'
load 'lib/faye_ping.rb'

bayeux = Faye::RackAdapter.new(mount: '/faye', timeout: 25)
bayeux.add_extension(FayePing.new)
bayeux.listen(9292)       
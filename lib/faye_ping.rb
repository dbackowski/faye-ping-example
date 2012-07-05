require "pty"

class FayePing
  MONITORED_CHANNELS = [ '/messages/ping_input' ]

  def incoming(message, callback)
    return callback.call(message) unless MONITORED_CHANNELS.include? message['channel']

    Thread.new do
      begin
        PTY.spawn( "ping #{message['data']['ip']} -c 4" ) do |r, w, pid|
          begin
            r.each do |line| 
              faye_client.publish('/messages/ping_output', { output: line })
            end
         rescue Errno::EIO
         end
        end
      rescue PTY::ChildExited
        puts "The child process exited!"
      end
    end

    callback.call(message)
  end

  def faye_client
    @faye_client ||= Faye::Client.new('http://localhost:9292/faye')
  end
end
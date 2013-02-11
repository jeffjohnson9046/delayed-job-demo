##########################################################################################
## FAYE RACKUP APPLICATION
## This is a script that will start up a Faye publish/subscribe server on port 9292.
##
## To run properly, take the following steps:
## 1.  Install the Faye gem:  sudo gem install faye
## 2.  Install the thin gem (if you haven't already): sudo gem install thin
## 3.  Add the faye gem to your Rails app's Gemfile:  gem 'faye'
## 4.  Add the thin gem to your Rails app's Gemfile:  gem 'thin'
## 5.  Create a [interesting file name].ru file in the root of your Rails app.  NOT in the "app" folder, in the ROOT
##     (i.e. one level above the "app" folder, e.g. where the Gemfile is.)
## 7.  In the app/views/layouts/application.js (or whatever page should be listening for messages from Faye), use the
##     following javascript to establish a client:
##
##        $(function() {
##          // Create a new Faye client after the DOM is loaded.
##          // To test this client, use the following on the command line:
##          //  curl http://localhost:9292/faye -d 'message={ "channel":"/messages/new", "data":"hola" }'.
##          var fayeClient = new Faye.Client('http://localhost:9292/faye');
##          fayeClient.subscribe("/messages/new", function(data) {
##            alert(data);
##          });
##        });
##
## 8.  To test the client above, refresh the Rails app (or start it if it isn't running) and use the following command
##     on the command line:
##
##      curl http://localhost:9292/faye -d 'message={ "channel":"/messages/new", "data":"hola" }'.
##
##     You *should* see an alert box that says "hola".
##
## To run the Faye server from the command line, use the following:
##    rackup faye.ru -s thin -E production
##
## For additional information, see the following links:
##  http://faye.jcoglan.com/ruby.html
##  http://railscasts.com/episodes/260-messaging-with-faye
##########################################################################################
require 'faye'
require 'logger'

Faye::WebSocket.load_adapter('thin')
logger = Logger.new("/Users/jjohnson3/dev/ruby/rails/delayed-job-demo/log/faye.ru.log")
logger.level = Logger::DEBUG

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message['ext']['auth_token'] != FAYE_TOKEN
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.listen(9292)

faye_server.bind(:handshake) do |client_id|
  logger.info("[FAYE::Handshake] - client_id = #{ client_id }")
end

faye_server.bind(:subscribe) do |client_id, channel|
  logger.info("[FAYE::Subscribe] - client_id = #{client_id}, channel = #{channel}")
end

faye_server.bind(:unsubscribe) do |client_id, channel|
  logger.info("[FAYE::Unsubscribe] - client_id = #{client_id}, channel = #{channel}")
end

faye_server.bind(:publish) do |client_id, channel, data|
  logger.info("[FAYE::Publish] - client_id = #{client_id}, channel = #{channel}, data = #{data}")
end

faye_server.bind(:disconnect) do |client_id|
  logger.info("[FAYE::Disconnect] - client_id = #{client_id}")
end

run faye_server
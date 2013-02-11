module ApplicationHelper
  def log_worker_msg(job, id, msg, level = Logger::INFO)
    log_message = format_msg(job, id, msg)
    Delayed::Worker.logger.add(level, "#{Time.now.strftime('%FT%T%z')}: #{ log_message }")
    broadcast_message("/messages/new", log_message)
  end

def broadcast_message(channel, msg)
  begin
    Delayed::Worker.logger.debug("[DEBUG] Attempting to broadcast a log message...")

    message = { :channel => channel, :data => msg, :ext => { :auth_token => FAYE_TOKEN } }
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  rescue => e
    Delayed::Worker.logger.error("[DEBUG] [ERROR] Failed to broadcast message.  Error: #{ e.to_s }")
  ensure
    Delayed::Worker.logger.debug("[DEBUG] Attempt complete.")
  end
end

  private

    def format_msg(job, id, text)
      "[#{ job.nil? ? "<not provided>" : job.name } #{ id }, host:#{ Socket.gethostname } pid:#{ Process.pid }] #{ text }"
    end
end

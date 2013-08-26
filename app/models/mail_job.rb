class MailJob < Struct.new(:id)
  include ApplicationHelper

  def enqueue(job)
    log_worker_msg(job, id,  "[ENQUEUE] mail_job has been put into the queue")
  end

  def perform
    log_worker_msg(nil, id,  "[PERFORM] mail_job is performing the 'deliver' task...")
    Mailing.deliver(id)
  end

  def before(job)
    log_worker_msg(job, id, "[START] mail_job is starting!")
  end

  def after(job)
    log_worker_msg(job, id, "[FINISH] mail_job has finished.")
  end

  def success(job)
    log_worker_msg(job, id, "[SUCCESS] mail_job was successful")
  end

  def error(job, exception)
    log_worker_msg(job, id, "[ERROR] mail_job encountered an error:  #{ exception.message }")
    #Airbrake.notify(exception)
  end

  def failure
    log_worker_msg(nil, id, "[FAIL] mail_job failed.")
  end
end
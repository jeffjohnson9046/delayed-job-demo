class MailingsController < ApplicationController
  include ApplicationHelper
  respond_to :js, :html

  def deliver
    #Mailing.delay(:queue => "test").deliver(params[:id])
    Delayed::Job.enqueue MailJob.new(params[:id])

    redirect_to(mailings_path, :notice => "You bet your sweet ass we're spamming the HELL outta our subscribers!")
  end


  def index
    @mailings = Mailing.all()
                       #.paginate(:per_page => 10)
  end

  def show
    @mailing = Mailing.find_by_id(params[:id])
  end


  def new
    @mailing = Mailing.new
  end

  def create
    @mailing = Mailing.new(params[:mailing])

    if @mailing.save
      redirect_to(mailings_path, :notice => "Mailing <b>'#{ @mailing.subject }'</b> has been created successfully.")
    else
      render(:new, :error => @mailing.errors)
    end
  end


  def edit
    @mailing = Mailing.find_by_id(params[:id])
  end

  def update
    @mailing = Mailing.find_by_id(params[:id])

    if @mailing.update_attributes(params[:mailing])
      redirect_to(mailings_path, :notice => "Mailing <b>'#{ @mailing.subject }'</b> has been updated successfully.")
    else
      render(:edit, :error => @mailing.errors)
    end
  end


  def destroy
    @mailing = Mailing.find_by_id(params[:id])

    if @mailing.destroy
      redirect_to(mailings_path, :notice => "Mailing <b>'#{ @mailing.subject }'</b> has been deleted successfully.")
    end
  end
end

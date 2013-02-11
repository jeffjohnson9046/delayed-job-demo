class Mailing < ActiveRecord::Base
  attr_accessible :body, :delivered_at, :subject

  validates :subject, :presence => true,
                      :length => { :minimum => 5, :maximum => 50 }

  validates :body, :presence => true,
                   :length => { :minimum => 10 }

  def self.deliver(id)
    find(id).deliver
  end

  def deliver
    sleep 10
    update_attribute(:delivered_at, Time.zone.now)
  end
end

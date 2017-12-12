class Notification < ActiveRecord::Base
  validates :title, :content, presence: true
  
  after_create :send_notification
  def send_notification
    NotificationSendJob.perform_later(self.id)
  end
  
end

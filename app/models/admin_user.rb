class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         # :recoverable,
         :rememberable, :trackable, :validatable
  
  belongs_to :merchant
  belongs_to :wx_user, class_name: 'User', foreign_key: 'wx_user_id'
  
  def merchant_blocked?
    !merchant.opened
  end
  
  def wx_qrcode_url
    qrcode_ticket = generate_qrcode_ticket
    "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{qrcode_ticket}"
  end
  
  def unbind!
    self.wx_user_id = nil
    self.save!
  end
  
  private
  def generate_qrcode_ticket
    Wechat::Base.fetch_qrcode_ticket("bind:#{self.email}", false)
  end
  
end

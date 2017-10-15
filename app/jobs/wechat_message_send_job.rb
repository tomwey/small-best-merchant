class WechatMessageSendJob < ActiveJob::Base
  queue_as :messages

  def perform(to, tpl, url = '', data = {})
    user = User.find_by(id: to)
    if user && user.wechat_profile
      Wechat::Message.send(user.wechat_profile.openid, tpl, url, data)
    end
  end
  
end

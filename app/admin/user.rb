ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
# menu parent: 'user'
menu parent: 'users', priority: 1, label: '用户管理'

permit_params :mobile, :nickname, :avatar, :balance, :earn, :verified, :bio, :wx_id, :wx_avatar, :total_prize_count

filter :uid, as: :select, collection: User.includes(:wechat_profile).order('id desc').map { |u| ["#{u.uid}:#{u.wechat_profile.try(:nickname)}", u.uid] }
filter :wechat_profile_nickname, as: :string, label: '昵称'

# scope :all, default: true
# scope :followed
# scope :unfollowed

index do
  selectable_column
  column('ID', :uid)
  column :avatar, sortable: false do |u|
    image_tag u.real_avatar_url, size: '32x32'
  end
  # column :mobile, sortable: false
  column :nickname, sortable: false do |u|
    u.format_nickname
  end
  column :balance
  column :earn
  # column :bio, sortable: false
  # column :verified, sortable: false
  column('关注时间') do |o| 
    o.wechat_profile.try(:subscribe_time).blank? ? '' : Time.at(o.wechat_profile.try(:subscribe_time).to_i).strftime('%Y年%m月%d日 %H:%M:%S')
  end
  column('取关时间') do |o|
    o.wechat_profile.try(:unsubscribe_time).blank? ? '' : o.wechat_profile.try(:unsubscribe_time).strftime('%Y年%m月%d日 %H:%M:%S')
  end
  column :created_at
  actions
  
end

form html: { multipart: true } do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    # f.input :mobile
    f.input :nickname
    f.input :avatar, as: :file, hint: '图片格式为：jpg,jpeg,png,gif'
    f.input :balance
    f.input :earn
    f.input :total_prize_count
    # f.input :bio
    # f.input :verified, as: :boolean
  end
  # f.inputs '微信认证信息' do
  #   f.input :wx_id
  #   f.input :wx_avatar
  # end
  actions
  
end

show do
  attributes_table do
    row :avatar do |u|
      image_tag u.real_avatar_url, size: '60x60'
    end
    row :uid
    row :mobile
    row :nickname do |u|
      u.format_nickname
    end
    row :balance
    row :earn
    row :private_token
    row :created_at
  end
  
  panel "微信资料" do
    if user.wechat_profile
      table_for user.wechat_profile do
        column :openid
        column :nickname
        column('性别') { |o| o.sex == 0 ? '男' : '女' }
        column :language
        column :city
        column :province
        column('关注时间') { |o| o.subscribe_time.blank? ? '' : Time.at(o.subscribe_time.to_i).strftime('%Y年%m月%d日 %H:%M:%S') }
        column('取关时间') { |o| o.unsubscribe_time.blank? ? '' : o.unsubscribe_time.strftime('%Y年%m月%d日 %H:%M:%S') }
        # column :unionid
        # column :access_token
        # column :refresh_token
        # column :created_at
      end
    else
      '无数据显示'
    end
  end
  
  # panel "汇总数据" do
#     table class: 'stat-table' do
#       tr do
#         th '总会话'
#         th '红包浏览次数'
#         th '抢红包次数'
#         th '抢红包金额'
#         th '分享红包次数'
#         th '分享红包收益'
#         th '提现次数'
#         th '提现金额'
#         th '充值次数'
#         th '充值金额'
#       end
#       tr do
#         # 总会话
#         @session_count ||= UserSession.where(user_id: user.id).count
#
#         # 红包浏览次数
#         @user_hb_view_count ||= RedbagViewLog.where(user_id: user.id).count
#
#         # 抢红包次数
#         @user_hb_earn_count ||= RedbagEarnLog.where(user_id: user.id).count
#
#         # 抢红包金额
#         @user_hb_earn_money ||= RedbagEarnLog.where(user_id: user.id).sum(:money).to_f
#
#         # 分享红包次数
#         @user_share_hb_count ||= RedbagShareLog.where(user_id: user.id).count
#
#         # 分享红包金额
#         @user_share_hb_earn_money ||= RedbagShareEarnLog.where(user_id: user.id).sum(:money).to_f
#
#         # 提现次数
#         @user_withdraw_count ||= Withdraw.where(user_id: user.id).count
#
#         # 提现金额
#         @user_withdraw_money ||= Withdraw.where(user_id: user.id).sum(:money).to_f
#
#         # 充值次数
#         @user_charge_count ||= Charge.where(user_id: user.id).where.not(payed_at: nil).count
#
#         # 充值金额
#         @user_charge_money ||= Charge.where(user_id: user.id).where.not(payed_at: nil).sum(:money).to_f
#
#         td @session_count
#         td @user_hb_view_count
#         td @user_hb_earn_count
#         td @user_hb_earn_money
#         td @user_share_hb_count
#         td @user_share_hb_earn_money
#         td @user_withdraw_count
#         td @user_withdraw_money
#         td @user_charge_count
#         td @user_charge_money
#       end # end tr
#
#     end # end total data
#
#     table class: 'stat-table' do
#       tr do
#         th '今日会话'
#         th '今日红包浏览次数'
#         th '今日抢红包次数'
#         th '今日抢红包金额'
#         th '今日分享红包次数'
#         th '今日分享红包收益'
#       end
#       tr do
#         # 总会话
#         @today_session_count ||= UserSession.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
#
#         # 红包浏览次数
#         @today_user_hb_view_count ||= RedbagViewLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
#
#         # 抢红包次数
#         @today_user_hb_earn_count ||= RedbagEarnLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
#
#         # 抢红包金额
#         @today_user_hb_earn_money ||= RedbagEarnLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:money).to_f
#
#         # 分享红包次数
#         @today_user_share_hb_count ||= RedbagShareLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
#
#         # 分享红包金额
#         @today_user_share_hb_earn_money ||= RedbagShareEarnLog.where(user_id: user.id).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:money).to_f
#
#         td @today_session_count
#         td @today_user_hb_view_count
#         td @today_user_hb_earn_count
#         td @today_user_hb_earn_money
#         td @today_user_share_hb_count
#         td @today_user_share_hb_earn_money
#       end # end tr
#
#     end # end today data
#   end # end panel
  # panel "会话地图" do
  #   @sessions = UserSession.where(user_id: user.id).where.not(begin_loc: nil)
  #   render 'user_map', sessions: @sessions
  # end
  
end


end

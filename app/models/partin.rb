class Partin < ActiveRecord::Base
  belongs_to :ruleable, polymorphic: true
  belongs_to :winnable, polymorphic: true
  belongs_to :info_item, foreign_key: 'item_id'
  belongs_to :merchant
  
  has_many :partin_view_logs
  has_many :partin_take_logs
  has_many :partin_share_logs
  # 用于发送微信现金红包
  has_one :partin_share_config, dependent: :destroy
  accepts_nested_attributes_for :partin_share_config, allow_destroy: true, 
    reject_if: proc { |o| o[:title].blank? }
  
  scope :opened,   -> { where(opened: true) }
  scope :can_take, -> { where(can_take: true) }
  scope :onlined,  -> { where('online_at is null or online_at < ?', Time.zone.now) }
  scope :no_location_limit, -> { where(range: nil) }
  scope :join_merchant, -> { joins(:merchant).select('partins.*') }
  scope :sorted,   -> { join_merchant.select('(merchants.score + partins.sort) as sort_order').order('sort_order desc') }
  
  validates :win_type, presence: true
  
  validate :require_share_config
  def require_share_config
    if self.need_share && self.partin_share_config.blank?
      errors.add(:base, '分享配置不能为空')
      return false
    end
  end
  
  validate :require_win_type
  def require_win_type
    if winnable.blank?
      errors.add(:base, '必须要指定一个参与奖励')
      return false
    end
  end
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  before_save :parse_location
  def parse_location
    if location_str.blank?
      return true
    end
    
    if (!location_str_changed?) and location.present?
      return true
    end
    
    loc = ParseLocation.start(location_str)
    if loc.blank?
      errors.add(:base, '位置不正确或者解析出错')
      return false
    end
    
    self.location = loc
  end
  
  before_save :remove_blank_value_for_array
  def remove_blank_value_for_array
    self.areas = self.areas.compact.reject(&:blank?)
  end
  
  after_save :remove_share_config_if_needed
  def remove_share_config_if_needed
    if !need_share
      partin_share_config.destroy if partin_share_config
    end
  end
  
  def area_names
    Area.where(id: self.areas).map { |a| "以#{a.address}为中心#{a.range}米范围内" }.join('<br>')
  end
  
  def open!
    share_money = 0
    if partin_share_config && partin_share_config.winnable && partin_share_config.winnable_type == 'Redpack'
      left_money = partin_share_config.winnable.left_money
      share_money = left_money if left_money > 0
    end
    
    money = 0
    if self.winnable_type == 'Redpack'
      left_money = self.winnable.left_money
      money = left_money if left_money > 0
    end
    
    if (share_money + money) > self.merchant.balance
      return false
    end
    
    if share_money > 0
      # 写交易记录
      PayLog.create!(money: -share_money, merchant: merchant, payable: self, title: "广告上架，分享奖励红包[#{partin_share_config.winnable.uniq_id}]扣除")
    end
    
    if money > 0
      # 写交易记录
      PayLog.create!(money: -money, merchant: merchant, payable: self, title: "广告上架，红包[#{self.winnable.uniq_id}]扣除")
    end
    
    self.opened = true
    self.save!
    
    if self.winnable_type == 'Redpack'
      self.winnable.in_use!(true)
    end
    
    # 如果需要通知用户，那么发出通知
    # if need_notify
    send_notify_to_merchant_and_users
    # end
    
    return true
  end
  
  def close!
    share_money = 0
    if partin_share_config && partin_share_config.winnable && partin_share_config.winnable_type == 'Redpack'
      share_money = partin_share_config.winnable.left_money
    end
    
    money = 0
    if self.winnable_type == 'Redpack'
      money = self.winnable.left_money
    end
    
    if share_money > 0
      # 写交易记录
      PayLog.create!(money: share_money, merchant: merchant, payable: self, title: "广告下架，分享奖励红包[#{partin_share_config.winnable.uniq_id}]返还")
    end
    
    if money > 0
      # 写交易记录
      PayLog.create!(money: money, merchant: merchant, payable: self, title: "广告下架，红包[#{self.winnable.uniq_id}]返还")
    end
    
    self.opened = false
    self.save!
    
    if self.winnable_type == 'Redpack'
      self.winnable.in_use!(false)
    end
    
    return true
  end
  
  def send_notify_to_merchant_and_users
    payload = {
      first: {
        value: "有新的广告奖励上线了，红包金额：#{winnable.try(:total_money)/ 100.0}元\n",
        color: "#FF3030",
      },
      keyword1: {
        value: "#{self.merchant.name}",
        color: "#173177",
      },
      keyword2: {
        value: "#{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}",
        color: "#173177",
      },
      remark: {
        value: "   ",
        color: "#173177",
      }
    }.to_json
    
    # 通知管理员
    if SiteConfig.wx_message_admin_receipts
      user_ids = User.where(uid: SiteConfig.wx_message_admin_receipts.split(',')).pluck(:id).to_a
    else
      user_ids = []
    end
    
    # 通知用户
    if need_notify
      # u_ids = User.joins(:wechat_profile, :user_merchants).where(user_merchants: { merchant_id: self.merchant_id })
      # .where('wechat_profiles.subscribe_time is not null and wechat_profiles.unsubscribe_time is null').pluck(:id)
      #
      # if u_ids.any?
      #   user_ids += u_ids
      # end
      # 新的推送功能
      # noti = Notification.where(merchant_id: merchant.id).where(_type: 2, link: self.uniq_id).first
      # if noti.blank?
      #   noti = Notification.create(merchant_id: merchant.id,
      #                              title: '红包来了',
      #                              content: "收到了一个来自#{merchant.name}红包",
      #                              is_prod: true,
      #                              to_users: merchant.users.verified.pluck(:id),
      #                              _type: 2,
      #                              link: self.uniq_id
      #                              )
      # end
    end
    
    # user_ids << ownerable.id
    # 通知商家
    ids = AdminUser.where(merchant_id: self.merchant_id).pluck(:wx_user_id)
    
    if ids.any?
      user_ids = user_ids + ids
    end
    
    # http://b.hb.small-best.com/wx/share/partin?id=#{self.uniq_id}
    Message.create!(message_template_id: 10, content: payload, link: "", to_users: user_ids)
  end
  
  def self.items_for(merchant_id)
    InfoItem.where(merchant_id: merchant_id).order('id desc').map { |o| [o.title, o.id] }
  end
  
  def self.rule_types_for(merchant_id)
    arr = Question.where(merchant_id: merchant_id).order('id desc')
    [['-- 选择参与规则 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
  end
  
  def self.win_types_for(merchant_id, partin)
    # ids1 = Partin.where(winnable_type: 'Redpack').pluck(:winnable_id)
    # ids2 =
    arr  = Redpack.where(merchant_id: merchant_id).partin.not_in_use.order('id desc')
    if partin.winnable
      arr << partin.winnable
      arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
    else
      [['-- 选择参与奖励 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
    end
  end
  
  def rule_type=(val)
    if val.present?
      name,id = val.split('-')
      klass = Object.const_get name
      self.ruleable = klass.find_by(id: id)
    else
      self.ruleable = nil
    end
  end
  
  def rule_type
    "#{self.ruleable_type}-#{self.ruleable_id}"
  end
    
  def win_type=(val)
    if val.present?
      name,id = val.split('-')
      klass = Object.const_get name
      self.winnable = klass.find_by(id: id)
    else
      self.winnable = nil
    end
  end
  
  def win_type
    "#{self.winnable_type}-#{self.winnable_id}"
  end
  
end

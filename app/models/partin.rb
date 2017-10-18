class Partin < ActiveRecord::Base
  belongs_to :ruleable, polymorphic: true
  belongs_to :winnable, polymorphic: true
  belongs_to :info_item, foreign_key: 'item_id'
  belongs_to :merchant
  
  validates :winnable_id, :winnable_type, :win_type, presence: true
  
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
  
  def open!
    if self.winnable_type == 'Redpack'
      hb = self.winnable
      money = hb.total_money - hb.sent_money
      if money > 0
        if money < self.merchant.balance
          
          # 写交易记录
          PayLog.create!(money: -money, merchant: merchant, payable: self, title: '红包广告上架')
          
          self.opened = true
          self.save!
          
          return true
        else
          return false
        end
      else
        self.opened = true
        self.save!
        return true
      end
    else
      self.opened = true
      self.save!
      return true
    end
  end
  
  def close!
    if self.winnable_type == 'Redpack'
      hb = self.winnable
      money = hb.total_money - hb.sent_money
      if money > 0
        # 写交易记录
        PayLog.create!(money: money, merchant: merchant, payable: self, title: '红包广告下架')
      end
      self.opened = false
      self.save!
      return true
    else
      self.opened = false
      self.save!
      return true
    end
  end
  
  def self.items_for(merchant_id)
    InfoItem.where(merchant_id: merchant_id).order('id desc').map { |o| [o.title, o.id] }
  end
  
  def self.rule_types_for(merchant_id)
    arr = Question.where(merchant_id: merchant_id).order('id desc')
    [['-- 选择参与规则 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
  end
  
  def self.win_types_for(merchant_id)
    arr = Redpack.where(merchant_id: merchant_id).order('id desc')
    [['-- 选择参与奖励 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
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

class Redpack < ActiveRecord::Base
  belongs_to :merchant
  
  # 用于发送微信现金红包
  has_one :redpack_send_config, dependent: :destroy
  accepts_nested_attributes_for :redpack_send_config, allow_destroy: true, reject_if: :all_blank
  
  validates :money, :total_count, presence: true
  
  validate :check_min_value_if_is_cash
  def check_min_value_if_is_cash
    if self.is_cash
      puts self.min_value
      if self.min_value.blank? or self.min_value < 100
        errors.add(:base, '现金红包最小值不能低于1元')
        return false
      end
    end
  end
  
  validate :require_send_config
  def require_send_config
    if self.is_cash && self.redpack_send_config.blank?
      errors.add(:base, '微信现金红包配置不能为空')
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
  
  after_save :remove_send_config_if_needed
  def remove_send_config_if_needed
    if !is_cash
      redpack_send_config.destroy if redpack_send_config
    end
  end
  
  def format_type_name
    "红包[#{self.uniq_id}](#{self.total_money / 100.0}元)"
  end
  
  def self.wx_send_scenes
    [['商品促销[1-499]','PRODUCT_1'],
     ['抽奖[1-200]','PRODUCT_2'],
     ['虚拟物品兑奖[1-200]','PRODUCT_3'],
     ['企业内部福利[1-499]','PRODUCT_4'],
     ['渠道分润[1-200]','PRODUCT_5'],
     ['保险回馈','PRODUCT_6'],
     ['彩票派奖','PRODUCT_7'],
     ['税务刮奖','PRODUCT_8'],
    ]
  end
  
  def money=(val)
    if val.present?
      if self._type == 0
        self.total_money = val.to_f * 100
      else
        self.total_money = val.to_f * 100 * self.total_count
      end
    end
  end
  
  def money
    return nil if self.total_money.blank?
    if self._type == 0
      self.total_money / 100.0
    else
      tmp = self.total_money / 100.0
      tmp / self.total_count
    end
  end
  
  def min_money=(val)
    if val.present? && self._type == 0 && val.to_f >= 0.01
      if val.to_f < 0.01
        errors.add(:base, '不能低于0.01元')
        return
      end
      
      self.min_value = val.to_f * 100
    end
  end
  
  def min_money
    if self._type == 0
      if self.min_value.blank?
        return nil
      else
        return self.min_value / 100.0
      end
    else
      return nil
    end
  end
  
  def random_money
    if self._type != 0
      return self.total_money / self.total_count
    end
    
    return _calc_random_money
  end
  
  private
  def _calc_random_money
    remain_size = self.total_count - self.sent_count
    remain_money = (self.total_money - self.sent_money)
    
    if remain_size == 0
      return 0
    end
    
    if remain_size == 1
      return remain_money
    end
    
    tmp_remain_money = remain_money.to_f / 100.00
    
    min = self.min_value || 5
    
    tmp_min = min.to_f / 100.00
    
    max = tmp_remain_money.to_f / remain_size * 2
    money = SecureRandom.random_number * max
    money = money < tmp_min ? tmp_min : money
    
    money = (money * 100).floor
    money
  end
  
end

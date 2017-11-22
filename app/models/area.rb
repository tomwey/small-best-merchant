class Area < ActiveRecord::Base
  validates :address, :range, presence: true
  belongs_to :merchant
  
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
    if address.blank?
      return true
    end
    
    if (!address_changed?) and location.present?
      return true
    end
    
    loc = ParseLocation.start(address)
    if loc.blank?
      errors.add(:base, '位置不正确或者解析出错')
      return false
    end
    
    self.location = loc
  end
  
  def partins_count
    0
  end
  
  def cards_count
    0
  end
  
end

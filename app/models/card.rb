class Card < ActiveRecord::Base
  belongs_to :ownerable, polymorphic: true
  
  validates :title, :image, :body, presence: true
  
  mount_uploader :image, CoverImageUploader
  
  # TYPES = [['固定金额', 1], ['固定折扣', 2], ['随机金额', 3], ['随机折扣', 4]]
  
  scope :opened, -> { where(opened: true) }
  scope :can_send, -> { where('quantity is null or quantity > sent_count') }
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..8])
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  before_save :remove_blank_value_for_array
  def remove_blank_value_for_array
    self.areas = self.areas.compact.reject(&:blank?)
  end
  
  def area_names
    Area.where(id: self.areas).map { |a| "以#{a.address}为中心#{a.range}米范围内" }.join('<br>')
  end
  
  # 给用户发优卡
  def send_to_user(user)
    return nil if user.blank? or !has_card?
    
    return nil if not user.subscribed?
    
    exp = nil
    if limit_duration.present?
      if limit_duration =~ /^[1-9]\d*$/
        exp = Time.zone.now + limit_duration.to_i.days
      elsif limit_duration =~ /^\d{4}-\d{2}-\d{2}/
        exp = limit_duration
      end
    end
    
    return UserCard.create!(user_id: user.id, card_id: self.id, get_time: Time.zone.now, expired_at: exp)
  end
  
  def send_award_to!(user)
    send_to_user(user)
  end
  
  def _price=(val)
    self.price = val.to_i * 100
  end
  
  def _price
    '%.2f' % self.price
  end
  
  def has_left?
    has_card?
  end
  
  def has_card?
    quantity.blank? or quantity > sent_count
  end
  
  def add_sent_count
    self.class.increment_counter(:sent_count, self.id)
  end
  
  def add_view_count
    self.class.increment_counter(:view_count, self.id)
  end
  
  def add_share_count
    self.class.increment_counter(:share_count, self.id)
  end
  
  def add_use_count
    self.class.increment_counter(:use_count, self.id)
  end
  
  def type_name
    '啥玩的卡'
  end
  
  # 卡送出的状况
  def sent_status_info
    "#{quantity || '不限'} / #{sent_count}"
  end
  
  def owner_name
    ownerable.try(:format_nickname) || ownerable.try(:email)
  end
  
  def uid=(val)
    self.ownerable = User.find_by(uid: val) || Admin.find_by(email: val)
  end
  
  def uid
    if ownerable_type == 'User'
      ownerable.try(:uid)
    elsif ownerable_type == 'Admin'
      ownerable.try(:email)
    else
      nil
    end
  end
  
end

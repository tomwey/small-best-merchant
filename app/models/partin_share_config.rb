class PartinShareConfig < ActiveRecord::Base
  belongs_to :winnable, polymorphic: true
  belongs_to :partin
  
  validates :title, presence: true
  validates :icon, presence: true, on: :create
  
  mount_uploader :icon, AvatarUploader
  
  # def self.win_types_for(merchant_id)
  #   ids = PartinShareConfig.where(winnable_type: 'Redpack').where.not(winnable: self.winnable).pluck(:winnable_id)
  #   arr = Redpack.where(merchant_id: merchant_id).where.not(id: ids).order('id desc')
  #   [['-- 选择参与奖励 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
  # end
  
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
  
  def self.win_types_for(merchant_id, config)
    arr  = Redpack.where(merchant_id: merchant_id, in_use: false).order('id desc')
    if config.winnable
      arr << config.winnable
      arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
    else
      [['-- 选择参与奖励 --', nil]] + arr.map { |o| [o.format_type_name, "#{o.class}-#{o.id}"] }
    end
  end
  
end

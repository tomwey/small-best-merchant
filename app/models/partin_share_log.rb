class PartinShareLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :partin
  
  after_create :add_share_count
  def add_share_count
    partin.add_share_count if partin
  end
end

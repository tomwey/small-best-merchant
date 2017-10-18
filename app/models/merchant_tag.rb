class MerchantTag < ActiveRecord::Base
  belongs_to :merchant
  
  has_many :user_tags, foreign_key: 'tag_id'
  has_many :users, through: :user_tags
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..9]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
end

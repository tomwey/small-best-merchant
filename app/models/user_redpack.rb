class UserRedpack < ActiveRecord::Base
  belongs_to :user
  belongs_to :redpack
  
  after_create :change_user_state
  def change_user_state
    if (redpack && money && money > 0)   
      
      if redpack.is_cash
        # 现金红包
        UserRedpack.transaction do
          # 新增用户的收益
          user.earn += money / 100.0
          user.save!
    
          # 生成交易明细
          TradeLog.create!(user_id: user.id, 
                           tradeable: self, 
                           money: money / 100.0, 
                           title: "收到现金红包，来自#{redpack.merchant.try(:name)}" )
    
          # 更新红包统计
          redpack.change_sent_stats!(money)
          
          # 生成现金红包发送记录
          RedpackSendLog.create!(money: money, user: user, redpack: redpack)
          
        end
      else
        # 非现金红包
        UserRedpack.transaction do
          # 新增用户的收益
          user.add_earn!(money / 100.0)
    
          # 生成交易明细
          TradeLog.create!(user_id: user.id, 
                           tradeable: self, 
                           money: money / 100.0, 
                           title: "红包#{redpack.merchant.blank? ? '' : '来自' + redpack.merchant.name }" )
    
          # 更新红包统计
          redpack.change_sent_stats!(money)
        end
        
      end
      
    end
  end
  
  def format_name
    "#{(money || 0) / 100.0}元"
  end
  
end

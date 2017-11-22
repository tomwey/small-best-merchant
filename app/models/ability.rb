class Ability
  include CanCan::Ability
  
  def initialize(user)
    can :manage, ActiveAdmin::Page, name: "Dashboard"#, namespace_name: :admin
    
    can :manage, [InfoItem,Redpack,Question,Partin, Area], 
      merchant_id: user.merchant_id
      
    can :manage, [Card], ownerable_id: user.merchant_id, ownerable_type: 'Merchant' 
    
    can :create, :all
    can :read, [AdminUser, PayLog, Recharge, MerchantTag], merchant_id: user.merchant_id
    can [:update, :unbind], AdminUser do |admin|
      admin.id == user.id
    end
    
    cannot :create, [AdminUser, PartinViewLog, PartinTakeLog, PartinShareLog,User,MerchantTag]
    
    can :read, User, merchants: { id: user.merchant_id }
    can :read, [PartinViewLog, PartinTakeLog, PartinShareLog], partin: { merchant_id: user.merchant_id }
    
    can :read, UserCard, card: { ownerable_id: user.merchant_id, ownerable_type: 'Merchant' }
    cannot :create, UserCard
    
    cannot :update, Redpack, merchant_id: user.merchant_id, in_use: true
    cannot :destroy, :all
    
    if user.merchant_blocked?
      cannot :manage, [InfoItem,Redpack,Question,Partin, PayLog, Recharge, User, Area]
    end
    
    # if user.super_admin?
    #   can :manage, :all
    # elsif user.admin?
    #   can :manage, :all
    #   cannot :manage, SiteConfig
    #   cannot :manage, Admin, email: Setting.admin_emails
    #   cannot :destroy, :all
    # elsif user.site_editor?
    #   can :manage, :all
    #   cannot :manage, SiteConfig
    #   cannot :manage, Admin
    #   cannot :destroy, :all
    # elsif user.marketer?
    #   cannot :manage, :all
    #   can :read, :all
    #   cannot :read, SiteConfig
    #   cannot :read, Admin
    # elsif user.limited_user?
    #   cannot :manage, :all
    #   can :manage, ActiveAdmin::Page, name: "Dashboard"
    #   can :read, User
    #   can :read, UserSession
    #   can :read, WechatLocation
    #   can :read, UserChannel
    #   can :read, UserChannelLog
    #   can :read, Page
    #   can :read, Report
    #   can :read, Feedback
    #   # cannot :read, SiteConfig
    #   # cannot :read, Admin
    # end
  end
  
end
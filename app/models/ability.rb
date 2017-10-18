class Ability
  include CanCan::Ability
  
  def initialize(user)
    can :manage, ActiveAdmin::Page, name: "Dashboard"#, namespace_name: :admin
    
    can :manage, [InfoItem,Redpack,Question,Partin], 
      merchant_id: user.merchant_id
    
    can :create, :all
    can :read, [AdminUser, PayLog, Recharge, MerchantTag], merchant_id: user.merchant_id
    can :update, AdminUser do |admin|
      admin.id == user.id
    end
    
    cannot :create, AdminUser
    
    can :read, User, merchants: { id: user.merchant_id }
    
    cannot :create, [User,MerchantTag]
    
    if user.merchant_blocked?
      cannot :manage, [InfoItem,Redpack,Question,Partin, PayLog, Recharge, User]
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
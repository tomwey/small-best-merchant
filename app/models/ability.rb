class Ability
  include CanCan::Ability
  
  def initialize(user)
    can :manage, ActiveAdmin::Page, name: "Dashboard"#, namespace_name: :admin
    # puts user
    can :manage, AdminUser, merchant_id: user.merchant_id
    can :manage, InfoItem, merchant_id: user.merchant_id
    can :manage, Redpack, merchant_id: user.merchant_id
    can :manage, Question, merchant_id: user.merchant_id
    
    can :create, :all
    cannot :create, AdminUser
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
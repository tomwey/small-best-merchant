ActiveAdmin.register AdminUser do
  menu parent: 'system', label: '账号管理', priority: 1
  
  permit_params :email, :password, :password_confirmation
  
  config.filters = false
  
  actions :all, except: [:show]
  
  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column "微信用户", sortable: false do |o|
      o.wx_user_id.blank? ? image_tag(o.wx_qrcode_url, size: '120x120') :
      raw("<div class=\"table_actions\">#{o.wx_user.try(:format_nickname)}<br><a href=\"#{unbind_admin_admin_user_path(o)}\">解除绑定</a></div>")
    end
    column :created_at
    actions
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  # filter :created_at
  
  member_action :unbind, method: :put do
    resource.unbind!
    redirect_to collection_path, notice: '解绑成功'
  end

  form do |f|
    f.inputs '修改密码' do
      # f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end

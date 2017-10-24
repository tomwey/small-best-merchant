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
      o.wx_user_id.blank? ? image_tag(o.wx_qrcode_url, size: '60x60') : raw("#{o.wx_user.format_nickname}<br><a href=\"#{unbind_admin_admin_user_path(o)}\" class=\"btn\">解除绑定</a>")
    end
    column :created_at
    actions
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  # filter :created_at

  form do |f|
    f.inputs '修改密码' do
      # f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end

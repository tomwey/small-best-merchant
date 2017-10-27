ActiveAdmin.register MerchantTag do
  menu parent: 'users', priority: 2, label: '标签列表'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name

config.filters = false
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column('ID', :uniq_id)
  column '标签名', :name, sortable: false
  column '用户数' do |model, opts|
    model.users.count
  end
  column 'at' do |o|
    o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
  end
  # actions
  
end

end

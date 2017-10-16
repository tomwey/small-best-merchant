ActiveAdmin.register InfoItem do
  
  menu parent: 'publish', label: '内容管理', priority: 1
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :image, :body

index do
  selectable_column
  column :uniq_id, sortable: false
  column :title, sortable: false
  column :image, sortable: false do |o|
    o.image.blank? ? '' : image_tag(o.image.url(:small))
  end
  column 'at', :created_at
  
  actions
end

before_create do |o|
  o.merchant = current_admin_user.merchant
end

show do
  div do
    raw("<div class=\"info-item-body\">#{info_item.body}</div>")
  end
end

form html: { multipart: true } do |f|
  f.semantic_errors
  
  f.inputs '基本信息' do
    f.input :title, placeholder: '输入标题'
    f.input :image, hint: '图片格式为：jpg,jpeg,gif,png'
    f.input :body, as: :text, input_html: { class: 'redactor' }, 
      placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
  end
  actions
end

end

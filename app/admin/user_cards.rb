ActiveAdmin.register UserCard do
  
  menu parent: 'card_logs', priority: 1, label: '优惠券发出记录'
  
  index do
    selectable_column
    column('ID', :uniq_id)
    column '卡图片', :image, sortable: false do |o|
      image_tag o.image.url(:small)
    end
    column '卡名称', :title, sortable: false
    column '有效期', :expired_at
    column '查看数', :view_count
    column '分享数', :share_count
    column '使用数', :use_count
    column('at', :created_at)
  
    actions
  
  end

end

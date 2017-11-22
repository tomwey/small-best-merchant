ActiveAdmin.register Card do

  menu parent: 'publish', priority: 6, label: '优惠券管理'

permit_params :title, :image, :body, :opened, :quantity, :limit_use_times, :limit_duration, :_price, { areas: [] }


index do
  selectable_column
  column('ID', :uniq_id)
  column :image, sortable: false do |o|
    image_tag o.image.url(:small)
  end
  column :title, sortable: false
  # column '卡类型', sortable: false do |o|
  #   o.type_name
  # end
  # column :discounts
  column :sent_count
  column '浏览数', :view_count
  column :share_count
  column :use_count
  column '投放区域', sortable: false do |o|
    raw("#{o.area_names}")
  end
  column('at', :created_at)
  
  actions
  
end

before_create do |o|
  o.ownerable = current_admin_user.merchant
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    # if f.object.new_record? || !f.object.opened
    #   f.input :uid, as: :select, label: '所有者ID',
    #     collection: User.includes(:wechat_profile)
    #       .where(verified: true).order('id desc')
    #       .map { |u| ["[#{u.uid}] #{u.format_nickname}", u.uid] }, prompt: '-- 选择所有者 --',
    #     required: true, input_html: { style: 'width: 50%;' }
    # end
    f.input :title
    f.input :image, hint: '尺寸为588x369，格式为：jpg,png,jpeg,gif'
    f.input :body, as: :text, input_html: { class: 'redactor' }, rows: 6, cols: 10, placeholder: '网页内容，支持图文混排', 
      hint: '网页内容，支持图文混排'
    f.input :quantity, label: '发卡总数'
    f.input :_price, as: :number, label: '购买价格', placeholder: '单位为元', hint: '用户购买该优惠券的钱会转入您的商家账号余额'
    # f.input :_type, as: :select, collection: Card::TYPES, prompt: '-- 选择类别 --', input_html: { style: 'width: 50%;' }
    # f.input :discounts, placeholder: '可能的值为：10, 0.8, 0.6-0.8, 100-400',
    # hint: '此字段的值会根据类型的不同来变化。如果是固定金额，那么值为一个固定的优惠金额，单位为元；
      # 如果是固定折扣，那么值为一个小于1的折扣值；如果为随机金额，那么值为一个表示范围的值，单位为元，例如：100-500；
      # 如果是一个随机折扣，那么值为一个小于1的范围折扣。'
    
    f.input :opened, label: '是否启用'
  end
  
  f.inputs '限制使用信息' do
    f.input :areas, as: :check_boxes, label: '投放区域', collection: Area.all.map { |a| ["以#{a.address}为中心#{a.range}米内的用户可以参与", a.id] }
    f.input :limit_use_times, placeholder: '5', hint: '每个用户对该张卡的使用次数限制'
    f.input :limit_duration, placeholder: '30或2017-11-23', hint: '
      卡的有效期，如果输入的是一个整数值，那么表示有效期为，该用户领取日期加上这个数值天数；
      如果输入的是一个日期字符串，那么就是一个对所有用户都一样的具体的有效日期'
  end
  actions
end


end

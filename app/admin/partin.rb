ActiveAdmin.register Partin do
  menu parent: 'publish', priority: 8, label: '广告'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :item_id, :rule_type, :win_type, :rule_answer_tip, :sort, :need_notify,
  :location_str, :range, :online_at, :opened,:need_share,
  partin_share_config_attributes: [:id, :icon, :title, :win_type, :_destroy]

index do
  selectable_column
  column('ID', :uniq_id)
  column '广告标题', sortable: false do |o|
    o.item_id.blank? ? '' : link_to(o.info_item.title, [:admin, o.info_item])
  end
  column '参与奖励', sortable: false do |o|
    o.winnable_id.blank? ? '' : link_to(o.winnable.format_type_name, [:admin, o.winnable])
  end
  column '参与规则', sortable: false do |o|
    o.ruleable_id.blank? ? '' : link_to(o.ruleable.format_type_name, [:admin, o.ruleable])
  end
  column :rule_answer_tip, sortable: false
  column :need_notify, sortable: false do |o|
    o.need_notify ? '需要' : '不需要'
  end

  column('at', :created_at)

  actions defaults: false do |o|
    item "查看", [:admin, o]
      
    if not o.opened
    #   item "下架", close_cpanel_redbag_path(o), method: :put
    # else
      item "上架", open_admin_partin_path(o), method: :put, data: { confirm: '您确定吗？' }
    else
      item "下架", close_admin_partin_path(o), method: :put, data: { confirm: '您确定吗？' }
    end
    item "编辑", edit_admin_partin_path(o)
    
    # end
    # item "删除", cpanel_redbag_path(o), method: :delete, data: { confirm: '你确定吗？' }
  end

end

# 上架
# batch_action :open do |ids|
#   batch_action_collection.find(ids).each do |e|
#     e.open!
#   end
#   redirect_to collection_path, alert: "已上架"
# end
member_action :open, method: :put do
  flag = resource.open! # ? '已上架' : '余额不足,上架失败'
  if flag
    redirect_to collection_path, notice: '上架成功'
  else
    redirect_to collection_path, alert: '上架失败，余额不足'
  end
end

# 下架
# batch_action :close do |ids|
#   batch_action_collection.find(ids).each do |e|
#     e.close!
#   end
#   redirect_to collection_path, alert: "已下架"
# end
member_action :close, method: :put do
  resource.close!
  redirect_to collection_path, notice: '已下架'
end

before_create do |o|
  o.merchant = current_admin_user.merchant
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :item_id, as: :select, label: '广告内容', collection: Partin.items_for(current_admin_user.merchant_id),prompt: '-- 选择参与内容 --'
    f.input :rule_type, as: :select, label: '参与规则', collection: Partin.rule_types_for(current_admin_user.merchant_id), prompt: '-- 选择参与规则 --'
    f.input :win_type,  as: :select, label: '参与奖励', collection: Partin.win_types_for(current_admin_user.merchant_id, f.object), prompt: '-- 选择参与奖励 --'
    f.input :rule_answer_tip, placeholder: '题目的答案在广告内容中找，注意只有一次回答机会。'
    f.input :need_notify
    f.input :need_share, as: :boolean, label: '是否支持微信分享', input_html: { onchange: 'Partin.toggleShareConfig(this)' }
    # f.input :opened
    f.input :sort
  end
  
  f.inputs "微信分享配置", 
    data: { need_share: "#{(f.object.new_record? || f.object.need_share == true) ? '1' : '0'}" }, 
    id: 'partin-share-configs', 
    for: [:partin_share_config, (f.object.partin_share_config || PartinShareConfig.new)] do |s|
    s.input :icon, label: '分享图标', hint: '格式为png,jpg,jped,gif,尺寸为正方形；如果不设置默认会用商家的logo'
    s.input :icon_cache, as: :hidden
    s.input :title, label: '分享标题'
    s.input :win_type,  as: :select, label: '分享者奖励', collection: PartinShareConfig.win_types_for(current_admin_user.merchant_id, s.object), prompt: '-- 选择参与奖励 --'
  end
  
  f.inputs '范围信息' do
    f.input :location_str, label: '参与地址', placeholder: '输入详细的参与地址，例如：成都市西大街1号'
    f.input :range, placeholder: '单位为米'
    f.input :online_at, as: :string, placeholder: '2017-09-01 12:30'
  end
  
  actions
end

end

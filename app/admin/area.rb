ActiveAdmin.register Area do
# menu parent: 'publish', priority: 2, label: '投放区域'
menu parent: 'publish', priority: 2, label: '投放区域'

permit_params :address, :range

index do
  selectable_column
  column('ID', :uniq_id)
  column :address, sortable: false
  column '限制区域(单位米)', :range
  column :location, sortable: false
  column '已投放的红包数', sortable: true do |o|
    o.partins_count
  end
  column '已投放的优惠券数', sortable: true do |o|
    o.cards_count
  end
  actions
end

before_create do |o|
  o.merchant = current_admin_user.merchant
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :address, placeholder: '输入详细的街道地址，例如：四川省成都市金牛区韦家碾一路24号；或者城市+小区或写字楼名称，例如：成都市绿地世纪城'
    f.input :range, placeholder: '单位为米', hint: '以上面的地址为中心，该字段的值为半径的区域'
  end
  actions
end

end

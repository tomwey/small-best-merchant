ActiveAdmin.register PayLog do
  menu parent: 'pays', label: '交易明细', priority: 2
  
  actions :index
  
  filter :uniq_id
  filter :title
  filter :created_at
  
  index do
    # selectable_column
    column('流水号', :uniq_id)
    column '描述', :title, sortable: false
    column '金额' do |model, opts|
      "#{model.money / 100.0}元"
    end
    
    column 'at' do |o|
      o.created_at.strftime('%Y年%m月%d日 %H:%M:%S')
    end
    actions
  
  end

end

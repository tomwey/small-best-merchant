ActiveAdmin.register Question do
  
  menu parent: 'publish', priority: 3, label: '题目规则'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :question, :answer, :answers_str, :memo

filter :id, label: 'ID'
filter :question, label: '问题'
filter :answer, label: '答案'
# filter :answers
filter :created_at, label: '创建时间'
filter :updated_at, label: '更新时间'


before_create do |o|
  o.merchant = current_admin_user.merchant
end

form do |f|
  f.semantic_errors
  
  f.inputs do
    f.input :question
    f.input :answer, placeholder: '输入正确答案'
    f.input :answers_str, label: '答案选项',
        placeholder: '可以为空，如果为空用于口令红包；答案选项用英文逗号分隔；例如：A、很不错,B、还可以'
    f.input :memo
  end
  
  actions
end


end

ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: "概况"

  content title: "概况" do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end
    
    div class: "blank_slate_container" do
      render "admin/dashboard/profile", owner: current_admin_user.merchant
    end
    
    columns do
      column do
        panel "数据汇总" do
          
          table class: 'stat-table' do
            tr do
              th '总用户数'
              th '还剩广告个数'
              th '还剩广告金额'
              th '累计发广告个数'
              th '累计发广告金额'
              th '累计被抢金额'
              th '累计浏览次数'
              th '累计参与次数'
              th '累计转发次数'
            end
            tr do
              @total_user ||= current_admin_user.merchant.users.count
              @left_count ||= Partin.where(merchant_id: current_admin_user.merchant_id).opened.can_take.count
              @left_money ||= Redpack.where(merchant_id: current_admin_user.merchant_id).map { |o| o.left_money }.sum / 100.0
              # Partin.where(merchant_id: current_admin_user.merchant_id).opened.map { |o| o.winnable.try(:left_money) }.sum / 100.0
              
              @total_sent_count ||= Partin.where(merchant_id: current_admin_user.merchant_id).opened.count
              @total_sent_money ||= Redpack.where(merchant_id: current_admin_user.merchant_id).map { |o| o.total_money }.sum / 100.0
              # Partin.where(merchant_id: current_admin_user.merchant_id).opened.map { |o| o.winnable.try(:total_money) }.sum / 100.0
              
              @total_taked_money ||= PartinTakeLog.joins(:partin).where(partins: { merchant_id: current_admin_user.merchant_id }).map { |o| (o.resultable.try(:money) || 0) }.sum / 100.0
              
              @total_view_count ||= PartinViewLog.joins(:partin).where(partins: { merchant_id: current_admin_user.merchant_id }).count
              @total_take_count ||= PartinTakeLog.joins(:partin).where(partins: { merchant_id: current_admin_user.merchant_id }).count
              @total_share_count ||= PartinShareLog.joins(:partin).where(partins: { merchant_id: current_admin_user.merchant_id }).count
              td @total_user
              td @left_count
              td 849.3#@left_money
              td @total_sent_count
              td @total_sent_money
              td 1350.7#@total_taked_money
              td 5456#@total_view_count
              td 2517#@total_take_count
              td 2729#@total_share_count
              		
            end
          end # end table
          
          table class: 'stat-table' do
            tr do
              th '今日用户数'
              th '今日发广告个数'
              th '今日发广告金额'
              th '今日被抢金额'
              th '今日浏览次数'
              th '今日参与次数'
              th '今日转发次数'
            end
            
            tr do
              
              @today_user ||= User.joins(:user_merchants).where(user_merchants: { merchant_id: current_admin_user.merchant_id, 
                created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day }).count
              #current_admin_user.merchant.users.count
              
              @today_sent_count ||= Partin.where(merchant_id: current_admin_user.merchant_id)
                .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                .opened.count
              @today_sent_money ||= Partin.where(merchant_id: current_admin_user.merchant_id)
                .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                .opened.can_take.map { |o| o.winnable.try(:total_money) }.sum / 100.0
              
              @today_taked_money ||= PartinTakeLog.joins(:partin)
                .where(partins: { merchant_id: current_admin_user.merchant_id })
                .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                .map { |o| (o.resultable.try(:money) || 0) }.sum / 100.0
              
              @today_view_count ||= PartinViewLog.joins(:partin)
                .where(partins: { merchant_id: current_admin_user.merchant_id })
                .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                .count
              @today_take_count ||= PartinTakeLog.joins(:partin)
                .where(partins: { merchant_id: current_admin_user.merchant_id })
                .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                .count
              @today_share_count ||= PartinShareLog.joins(:partin)
                .where(partins: { merchant_id: current_admin_user.merchant_id })
                .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
              td @today_user
              td @today_sent_count
              td @today_sent_money
              td @today_taked_money
              td @today_view_count
              td @today_take_count
              td @today_share_count
            end
            
          end # end
          
        end
      end
    end
    
    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end

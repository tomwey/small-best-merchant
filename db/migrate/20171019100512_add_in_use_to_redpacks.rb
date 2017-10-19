class AddInUseToRedpacks < ActiveRecord::Migration
  def change
    add_column :redpacks, :in_use, :boolean, default: false
  end
end

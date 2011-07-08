class AddArchivedFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :archived_flag, :boolean, :default => false
  end

  def self.down
    remove_column :users, :archived_flag
  end
end

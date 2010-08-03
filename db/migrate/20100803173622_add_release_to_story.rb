class AddReleaseToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :release, :boolean
  end

  def self.down
    remove_column :stories, :release
  end
end

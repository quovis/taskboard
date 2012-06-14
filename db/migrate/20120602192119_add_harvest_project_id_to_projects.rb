class AddHarvestProjectIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :harvest_project_id, :integer
  end

  def self.down
    remove_column :projects, :harvest_project_id
  end
end

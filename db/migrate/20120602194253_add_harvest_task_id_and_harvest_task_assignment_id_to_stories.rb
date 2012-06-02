class AddHarvestTaskIdAndHarvestTaskAssignmentIdToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :harvest_task_id, :integer
  end

  def self.down
    remove_column :stories, :harvest_task_id
  end
end

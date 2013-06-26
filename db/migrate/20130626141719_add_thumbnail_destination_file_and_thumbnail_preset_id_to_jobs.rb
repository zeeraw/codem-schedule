class AddThumbnailDestinationFileAndThumbnailPresetIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :thumbnail_destination_file, :string
    add_column :jobs, :thumbnail_preset_id, :integer
  end
end

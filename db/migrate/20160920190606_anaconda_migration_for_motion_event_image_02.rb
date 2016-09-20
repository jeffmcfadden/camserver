class AnacondaMigrationForMotionEventImage02 < ActiveRecord::Migration
  def change
    add_column :motion_events, :image_02_filename, :string
    add_column :motion_events, :image_02_file_path, :text
    add_column :motion_events, :image_02_size, :integer
    add_column :motion_events, :image_02_original_filename, :text
    add_column :motion_events, :image_02_stored_privately, :boolean
    add_column :motion_events, :image_02_type, :string
  end
end

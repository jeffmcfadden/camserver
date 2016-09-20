class CreateMotionEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :motion_events do |t|
      t.references :camera, foreign_key: true
      t.datetime :event_occured_at
      t.boolean :favorite, default: false

      t.timestamps
    end
  end
end

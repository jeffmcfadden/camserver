class FixSpellingOccurred < ActiveRecord::Migration[5.0]
  def change
    remove_column :motion_events, :event_occured_at
    add_column :motion_events, :occurred_at, :datetime

  end
end

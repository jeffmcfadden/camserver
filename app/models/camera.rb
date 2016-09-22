class Camera < ApplicationRecord
  has_many :motion_events

  enum camera_type: [ :foscam_8910, :foscam_9821 ]
  
end

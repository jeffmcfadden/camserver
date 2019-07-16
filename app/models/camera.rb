class Camera < ApplicationRecord
  has_many :motion_events

  enum camera_type: [ :foscam_8910, :foscam_9821, :amcrest_ipm721, :foscam_9821_ftp ]  

  def sidekiq_worker_running?
    scheduled = Sidekiq::ScheduledSet.new.select {|j| j.klass == 'CloneCameraCardWorker' && j.args == [self.id] }.first.present?
    running   = Sidekiq::Queue.new("low").select{ |j| j.klass == 'CloneCameraCardWorker' && j.args == [self.id] }.first.present?
    
    scheduled || running
  end

end
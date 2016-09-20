class CloneCameraCardWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'cardclone'
  
  def perform(camera_id)
    # do something
  end
end
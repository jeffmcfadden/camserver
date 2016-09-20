class ProcessEventWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'events'
  
  def perform(camera_id)
    # do something
  end
end
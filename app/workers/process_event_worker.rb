class ProcessEventWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'
  
  def perform(camera_id)
    # do something
  end
end
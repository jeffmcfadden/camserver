class ProcessEventWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'
  
  def perform(motion_event_id)
    
    @motion_event = MotionEvent.find(motion_event_id)
    @motion_event.process_event_directory!
    
  end
end
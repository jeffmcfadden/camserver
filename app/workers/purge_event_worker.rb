class PurgeEventWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'purge'
  
  def perform(motion_event_id)
    MotionEvent.not_favorites.where( "occurred_at < ?", 25.days.ago ).where( id: motion_event_id ).first&.destroy
  end  
end
class PurgeOldEventsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'purge'
  
  def perform
    begin
      
      MotionEvent.not_favorites.where( "occurred_at < ?", 25.days.ago ).find_each do |me|
        PurgeEventWorker.perform_async( me.id )
      end
      
    rescue StandardError => e
      Rails.logger.error "Error destroying old events. #{e}"
    end
    
    PurgeOldEventsWorker.perform_in( 24.hours )
  end  
end
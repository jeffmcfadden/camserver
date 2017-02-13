class PurgeOldEventsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'
  
  def perform
    begin
      
      MotionEvent.not_favorites.where( "occurred_at < ?", 65.days.ago ).find_each do |me|
        me.destroy
      end
      
    rescue StandardError => e
      Rails.logger.error "Error destroying old events. #{e}"
    end
    
    PurgeOldEventsWorker.perform_in( 24.hours )
  end  
end
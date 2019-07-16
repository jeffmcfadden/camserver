class MigrateMotionEventToActiveStorageWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'purge'
  
  def perform(id)

    MotionEvent.find(id).migrate_to_active_storage

  end  
end
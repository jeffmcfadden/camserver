require 'date'

class MotionEventsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index
    @motion_events = MotionEvent.all
    
    if params[:camera_id].present?
      @motion_events = @motion_events.where( camera_id: params[:camera_id] )
    end
    
    if params[:hour].present?
      @start_range = DateTime.strptime( params[:hour].to_s,'%s')
      @end_range   = @start_range + 1.hour
      @motion_events = @motion_events.where( occurred_at: @start_range..@end_range )
    end
    
    @motion_events = @motion_events.order( occurred_at: :desc ).page( params[:page] ).per( params[:per] )
  end
  
  def favorites
    @motion_events = MotionEvent.favorites
    
    if params[:camera_id].present?
      @motion_events = @motion_events.where( camera_id: params[:camera_id] )
    end
    
    @motion_events = @motion_events.order( occurred_at: :desc ).page( params[:page] ).per( params[:per] )
  end
  
  def show
    @motion_event = MotionEvent.find(params[:id])
  end
  
  def destroy
    @motion_event = MotionEvent.find(params[:id])
    
    @motion_event.destroy
    
    redirect_to motion_events_path
  end
  
  def favorite
    @motion_event = MotionEvent.find(params[:id])
    @motion_event.update_attributes( favorite: true )
    
    redirect_to @motion_event
  end
  
  def unfavorite
    @motion_event = MotionEvent.find(params[:id])
    @motion_event.update_attributes( favorite: false )
    
    redirect_to @motion_event
  end
    
  def calendar
    @camera_event_timeline = []
    MotionEvent.order(:camera_id).includes(:camera).where("occurred_at > ?", 30.hours.ago).each do |me|
      @camera_event_timeline << [me.camera.name, me.occurred_at, me.occurred_at + 30.seconds]
    end
  end
  
  def selected_from_timeline
    @start_range = Time.parse( params[:occurred_at] ) - 20.minutes
    @end_range   = Time.parse( params[:occurred_at] ) + 20.minutes
    @camera = Camera.find_by( name: params[:camera] )
    
    @motion_events = @camera.motion_events
    @motion_events = @motion_events.where( occurred_at: @start_range..@end_range )
    @motion_events = @motion_events.order( occurred_at: :desc ).page( params[:page] ).per( params[:per] )
  end
  
  def enqueue_purge_old_events_worker
    PurgeOldEventsWorker.perform_async
    flash[:notice] = "Worker enqueued"
    redirect_to motion_events_path
  end
  
end

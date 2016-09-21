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
  
  def show
    
    @motion_event = MotionEvent.find(params[:id])
  end
    
  
end

class MotionEventsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index
    @motion_events = MotionEvent.order( event_occurred_at: :desc ).page( params[:page] ).per( params[:per] )
  end
  
end

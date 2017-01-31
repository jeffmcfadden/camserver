Camera.all.each do |c|
  100.times do
    o = Time.now - rand( 1440 ).minutes
    c.motion_events.create( { occurred_at: o } )
  end
end
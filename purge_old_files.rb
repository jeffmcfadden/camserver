#!/usr/local/bin/ruby
cameras = [
  {name: "camera_1",  id: "FI9821P_00626E618AAB", type: "reolink" },
  {name: "camera_2",  id: "FI9821P_00626E6194D8", type: "" },
  {name: "camera_3",  id: "FI9821P_00626E618D22", type: "" },
  {name: "camera_4",  id: "FI9821P_C4D6553F81FD", type: "reolink" },
  {name: "camera_5",  id: "FI9821P_C4D6553F79EC", type: "" },
  {name: "camera_6",  id: "FI9821W_00626E55C679", type: "reolink" },
  {name: "camera_7",  id: "FI9821W_00626E534AFA", type: "reolink" },
  {name: "camera_8",  id: "AMC0177J_NX0N71"     , type: "" },
  {name: "camera_9",  id: "FI9821P_00626E61951F", type: "" },
  {name: "camera_10", id: "FI9821P_00626E618D22", type: "" },
  {name: "camera_11", id: "nil",                  type: "" },
  {name: "camera_13", id: "nil",                  type: "" },
  {name: "camera_15", id: "nil",                  type: "" },
 ]

cameras.each do |camera|
  
  (5..120).each do |d|
    date = (Time.now - (d*86400)).strftime("%Y%m%d")
    
    cmd = "rm -rf /camserver_working/#{camera[:name]}/card_clone/#{camera[:id]}/record/#{date}*"
    puts cmd
    `#{cmd}`

    
    date = (Time.now - (d*86400)).strftime("%Y-%m-%d")
    cmd = "rm -rf /camserver_working/#{camera[:name]}/events/#{date}*"
    puts cmd
    `#{cmd}`

    cmd = "rm -rf /camserver_working/#{camera[:name]}/card_clone/#{camera[:id]}/#{date}*"
    puts cmd
    `#{cmd}`
   

    # /camera_3/card_clone/ 
    cmd = "rm -rf /camserver_working/#{camera[:name]}/card_clone/#{date}*"
    puts cmd
    `#{cmd}`
  end
  
  if camera[:type] == "reolink"
    (5..120).each do |d|
      date = (Time.now - (d*86400)).strftime("%Y/%m/%d")
      
      cmd = "rm -rf /camserver_working/#{camera[:name]}/card_clone/#{date}"
      puts cmd
      `#{cmd}`      
    end
  end
end
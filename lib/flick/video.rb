class Video

  attr_accessor :action, :platform, :driver, :image_count, :seconds, :extended, :udid
  
  def initialize options
    Flick::Checker.action options[:action]
    Flick::Checker.platform options[:platform]
    self.action = options[:action]
    self.platform = options[:platform]
    case self.platform
    when "ios"
      self.driver = Flick::Ios.new options
    when "android"
      self.driver = Flick::Android.new options
    end
    self.image_count = options[:count]
    self.seconds = options[:seconds].to_f
    self.extended = options[:extend].to_b
    self.udid = self.driver.udid
  end
       
  def android
    platform == "android"
  end
  
  def ios
    platform == "ios"
  end
  
  def run
    self.send(action)
  end
            
  def start
    driver.clear_files
    puts "\nStarting Recoder!!!"
    if driver.recordable?
      if extended
        puts "In extended mode."
        Flick::Checker.system_dependency "mp4box"
        loop_record
      else
        start_record
      end
    else
      Flick::Checker.system_dependency "ffmpeg"
      start_screenshot_record
    end
  end
  
  def stop
    puts "\nStopping Recorder!!!"
    if driver.recordable?
      stop_record
    else
      stop_screenshot_recording
    end
    sleep 1
    driver.clear_files
  end
  
  private 
  
  def start_record
    Flick::System.kill_process "video", udid
    $0 = "flick-video-#{udid}"
    SimpleDaemon.daemonize! "/tmp/#{udid}-pidfile"
    command = -> do
       driver.screenrecord "#{udid}-single"
     end
    command.call
  end
  
  def is_recording?
    !(`pgrep -f #{udid}-`).empty?
  end
  
  def loop_record
    Flick::System.kill_process "video", udid
    $0 = "flick-video-#{udid}"
    SimpleDaemon.daemonize! "/tmp/#{udid}-pidfile"
    command = -> do
      count = "%03d" % 1
      loop do
        unless is_recording?
          driver.screenrecord "#{udid}-#{count}"
          count.next!
        end
      end
    end
    command.call
  end
    
  def stop_record
    Flick::System.kill_process "video", udid
    sleep 5 #wait for video process to finish
    driver.merge_videos
  end
  
  def start_screenshot_record
    Flick::System.kill_process "screenshot", udid
    puts "Process will stop after #{image_count} screenshots.\n"
    $0 = "flick-screenshot-#{udid}"
    SimpleDaemon.daemonize! "/tmp/#{udid}-pidfile"
    command = -> do
      count = "%03d" % 1
      loop do
        if count.to_i < image_count
          driver.screenshot "#{udid}-#{count}"
          count.next!; sleep seconds
        else
          puts "\nStop count exceeded. Saving to #{driver.outdir}/#{driver.name}.mp4".red 
          stop_screenshot_recording
          break
        end
      end
    end
    command.call
  end
  
  def stop_screenshot_recording 
    Flick::System.kill_process "screenshot", udid
    `rm /tmp/#{udid}-pidfile >> /dev/null 2>&1`
    driver.pull_files if android
    convert_screenshots_to_video
  end
  
  def convert_screenshots_to_video
    %x(find #{driver.flick_dir} -type f -size 0 | xargs rm '#{udid}*.png' -f >> /dev/null 2>&1) #rm 0 byte files.
    puts "Saving to #{driver.outdir}/#{driver.name}.mp4"
    %x(yes y | nohup ffmpeg -framerate 1 -pattern_type glob -i '#{driver.flick_dir}/#{udid}*.png' -c:v libx264 -pix_fmt yuv420p #{driver.outdir}/#{driver.name}.mp4 >> /dev/null 2>&1)
  end
end
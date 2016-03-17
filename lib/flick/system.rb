module Flick
  module System
    def self.setup_system_dir dir_name
      %x(mkdir #{dir_name} >> /dev/null 2>&1)
    end
    
    def self.clean_system_dir dir_name, udid
      %x(rm #{dir_name}/#{udid}* >> /dev/null 2>&1)
    end
    
    def self.process_running? type, udid
      `pgrep -f #{type}-#{udid}`.to_i > 0
    end
            
    def self.kill_process type, udid
      if self.process_running? type, udid
        pid = `pgrep -f flick-#{type}-#{udid}`.to_i
        `kill #{pid}` unless pid.zero?
      end
      if type == "video"
        pid = `pgrep -f #{udid}-`.to_i
        `kill #{pid}` unless pid.zero?
      end
    end
    
    def self.video_length file
      (`ffmpeg -i #{file} 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//`).strip
    end
  end
end
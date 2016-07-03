module Flick
  module System

    def self.setup_system_dir dir_name
      FileUtils.mkdir_p dir_name
    end

    def self.clean_system_dir dir_name, udid
      FileUtils.rm_rf(Dir.glob("#{dir_name}/#{udid}*"))
    end

    def self.process_running? type, udid
      pid = ProcTable.ps.find { |x| x.cmdline.include? "#{type}-#{udid}" }.pid rescue nil
      unless pid.nil?
        true
      else
        false
      end
    end

    def self.kill_process type, udid
      pid = ProcTable.ps.find { |x| x.cmdline.include? "#{type}-#{udid}" }.pid rescue nil
      Process.kill 'SIGKILL', pid unless pid.nil?

      if type == "video"
        pid = ProcTable.ps.find { |x| x.cmdline.include? "#{udid}-" }.pid rescue nil
        Process.kill 'SIGKILL', pid unless pid.nil?
      end

      if type == "log" && OS.mac?
        pid = ProcTable.ps.find { |x| x.cmdline.include? "idevicesyslog" }.pid rescue nil
        Process.kill 'SIGKILL', pid unless pid.nil?
      end
    end

    def self.video_length file
      (`ffmpeg -i #{file} 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//`).strip
    end
  end
end
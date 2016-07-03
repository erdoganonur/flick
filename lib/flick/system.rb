module Flick
  module System

    def self.setup_system_dir dir_name
      Dir.mkdir dir_name unless File.exists? dir_name
    end

    def self.clean_system_dir dir_name, udid
      Dir.glob("#{dir_name}/#{udid}*").each do |file|
        File.delete file
      end
    end

    def self.find_pid type, udid
      ProcTable.ps.find { |x| x.cmdline.include? "#{type}-#{udid}" }.pid rescue nil
    end

    def self.kill pid
      Process.kill 'SIGKILL', pid unless pid.nil?
    end

    def self.process_running? type, udid
      pid = self.find_pid type, udid
      unless pid.nil?
        true
      else
        false
      end
    end

    def self.kill_process type, udid
      pid = self.find_pid type, udid
      self.kill pid

      if type == "video"
        pid = ProcTable.ps.find { |x| x.cmdline.include? "#{udid}-" }.pid rescue nil
        self.kill pid
      end

      if type == "log" && OS.mac?
        pid = ProcTable.ps.find { |x| x.cmdline.include? "idevicesyslog" }.pid rescue nil
        self.kill pid
      end
    end

    def self.video_length file
      (`ffmpeg -i #{file} 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//`).strip
    end
  end
end
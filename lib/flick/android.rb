module Flick
  class Android
    attr_accessor :flick_dir, :dir_name, :udid, :name, :outdir, :unique, :limit, :specs
    
    def initialize options
      Flick::Checker.system_dependency "adb"
      self.flick_dir = "#{Dir.home}/.flick"
      self.dir_name = "sdcard/flick"
      self.udid = options.fetch(:udid, get_device_udid(options))
      self.name = options.fetch(:name, self.udid)
      self.outdir = options.fetch(:outdir, Dir.pwd)
      self.unique = options.fetch(:unique, true).to_b
      self.limit = options.fetch(:limit, 180)
      self.specs = options.fetch(:specs, false)
      create_flick_dirs
    end
    
    def create_flick_dirs
      Flick::System.setup_system_dir flick_dir
      %x(adb -s #{udid} shell 'mkdir #{dir_name}' >> /dev/null 2>&1)
    end
    
    def clear_files
      %x(adb -s #{udid} shell rm '#{dir_name}/*' >> /dev/null 2>&1)
      Flick::System.clean_system_dir flick_dir, udid
    end
    
    def devices
      (`adb devices`).scan(/\n(.*)\t/).flatten
    end
    
    def devices_connected?
      !devices.empty?
    end
    
    def check_for_devices
      unless devices_connected?
        puts "\nNo Devices Connected or Authorized!!!\nMake sure at least one device (emulator/simulator) is started!\n".red
        abort
      end
    end
    
    def get_device_udid opts_hash
      devices_connected?
      return unless opts_hash[:udid].nil?
      if devices.size == 1
        devices[0]
      else
        puts "\nMultiple android devices '#{devices}' found.\nSpecify a single UDID. e.g. -u #{devices.sample}\n".red
        abort unless specs
      end
    end
    
    def info
      specs = { os: "ro.build.version.release", manufacturer: "ro.product.manufacturer", model: "ro.product.model", sdk: "ro.build.version.sdk" }
      hash = { udid: udid }
      specs.each do |key, spec|
        value = `adb -s #{udid} shell getprop "#{spec}"`.strip
        hash.merge!({key=> "#{value}"})
      end
      hash
    end

    def os_version
      `adb -s #{udid} shell getprop "ro.build.version.release"`.strip.to_f
    end
        
    def screenshot name
      %x(adb -s #{udid} shell screencap #{dir_name}/#{name}.png)
    end
    
    def log name
      %x(adb -s #{udid} logcat -v long > #{outdir}/#{name}.log)
    end
    
    def recordable?
      (`adb -s #{udid} shell 'ls /system/bin/screenrecord'`).strip == "/system/bin/screenrecord"
    end
    
    def screenrecord name
      %x(adb -s #{udid} shell screenrecord --time-limit #{limit} --size 720x1280 #{dir_name}/#{name}.mp4)
    end
    
    def pull_file file, dir
      %x(adb -s #{udid} pull #{file} #{dir} >> /dev/null 2>&1)
    end
        
    def unique_files
      if os_version < 6.0
        command = "md5"
      else
        command = "md5sum"
      end
      files = `adb -s #{udid} shell "#{command} #{dir_name}/#{udid}*"`
      hash = files.split("\r\n").map { |file| { md5: file.match(/(.*) /)[1].strip, file: file.match(/ (.*)/)[1].strip } }
      hash.uniq! { |e| e[:md5] }
      hash.map { |file| file[:file] }
    end
    
    def pull_files
      if unique
        files = unique_files
      else
        files = (`adb -s #{udid} shell "ls #{dir_name}/#{udid}*"`).split("\r\n")
      end
      return if files.empty?
      Parallel.map(files, in_threads: 10) { |file| pull_file file, flick_dir }
    end
        
    def screenshots_exist?
      (`adb -s #{udid} shell "ls #{dir_name}/#{udid}-*.png | wc -l"`).to_i > 0
    end
  end
end
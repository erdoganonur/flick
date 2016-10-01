module Flick
  class Android
    attr_accessor :udid, :flick_dir, :dir_name, :name, :outdir, :unique, :limit, :specs

    def initialize options
      Flick::Checker.system_dependency "adb"
      if options[:udid].nil?
        self.udid = get_device_udid
      else
        self.udid = options[:udid]
      end
      self.flick_dir = "#{Dir.home}/.flick/#{udid}"
      self.dir_name = "sdcard/flick"
      self.name = remove_bad_characters(options.fetch(:name, self.udid))
      self.outdir = options.fetch(:outdir, Dir.pwd)
      self.unique = options.fetch(:unique, true).to_b
      self.limit = options.fetch(:limit, 180)
      self.specs = options.fetch(:specs, false)
      create_flick_dirs
    end

    def remove_bad_characters string
      string.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')
    end

    def create_flick_dirs
      Flick::System.setup_system_dir "#{Dir.home}/.flick"
      Flick::System.setup_system_dir flick_dir
      %x(adb -s #{udid} shell 'mkdir #{dir_name}')
    end

    def clear_files
      Flick::System.clean_system_dir flick_dir
      %x(adb -s #{udid} shell rm '#{dir_name}/*')
    end

    def devices
      (`adb devices`).scan(/\n(.*)\t/).flatten
    end

    def devices_connected?
      devices.any?
    end

    def check_for_devices
      unless devices_connected?
        puts "\nNo Devices Connected or Authorized!!!\nMake sure at least one device (emulator/simulator) is connected!\n".red
        abort
      end
    end

    def get_device_udid
      check_for_devices
      if devices.size == 1
        devices.first
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

    def install app_path
      %x(adb -s #{udid} install -r #{app_path})
    end

    def uninstall package
      if app_installed? package
        %x(adb -s #{udid} shell pm uninstall #{package})
      else
        puts packages
        puts "\n#{package} was not found on device #{udid}! Please choose one from above. e.g. #{packages.sample}\n".red
      end
    end

    def app_version app_path
      manifest(app_path).find {|x| x.name == "versionName" }["value"]
    end

    def package_name app_path
      manifest(app_path).find {|x| x.name == "package" }["value"]
    end

    def manifest app_path
      data = ApkXml.new app_path
      data.parse_xml("AndroidManifest.xml", false, true)
      data.xml_elements[0].attributes
    end

    def app_installed? package
      packages.include? "package:#{package}"
    end

    def packages
      %x(adb -s #{udid} shell pm list packages).split
    end

    def os_version
      %x(adb -s #{udid} shell getprop "ro.build.version.release").strip.to_f
    end

    def screenshot name
      %x(adb -s #{udid} shell screencap #{dir_name}/#{name}.png)
    end

    def log name
      %x(adb -s #{udid} logcat -v long > #{outdir}/#{name}.log)
    end

    def recordable?
      if info[:manufacturer] == "Genymotion"
        return false
      else
        %x(adb -s #{udid} shell "ls /system/bin/screenrecord").strip == "/system/bin/screenrecord"
      end
    end

    def screenrecord name
      %x(adb -s #{udid} shell screenrecord --time-limit #{limit} --size 720x1280 #{dir_name}/#{name}.mp4)
    end

    def pull_file file, dir
      %x(adb -s #{udid} pull #{file} #{dir})
    end

    def unique_files type
      if os_version < 6.0
        command = "md5"
      else
        command = "md5sum"
      end
      files = %x(adb -s #{udid} shell "#{command} #{dir_name}/#{type}*")
      hash = files.split("\r\n").map { |file| { md5: file.match(/(.*) /)[1].strip, file: file.match(/ (.*)/)[1].strip } }
      hash.uniq! { |e| e[:md5] }
      hash.map { |file| file[:file] }
    end
    
    def pull_files type
      if unique
        files = unique_files type
      else
        files = %x(adb -s #{udid} shell "ls #{dir_name}/#{type}*").split("\r\n")
      end
      return if files.empty?
      Parallel.map(files, in_threads: 10) do |file| 
        pull_file file, flick_dir
        Flick::System.wait_for_file 10, "#{flick_dir}/#{file.split("/").last}"
      end
    end
  end
end
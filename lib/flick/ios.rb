module Flick
  class Ios
    attr_accessor :flick_dir, :udid, :name, :outdir, :todir, :specs

    def initialize options
      Flick::Checker.system_dependency "idevice_id"
      self.flick_dir = "#{Dir.home}/.flick"
      self.udid = options.fetch(:udid, get_device_udid(options))
      self.name = options.fetch(:name, self.udid)
      self.todir = options.fetch(:todir, self.flick_dir)
      self.outdir = options.fetch(:outdir, Dir.pwd)
      self.specs = options.fetch(:specs, false)
      create_flick_dirs
    end

    def create_flick_dirs
      Flick::System.setup_system_dir flick_dir
    end

    def devices
      (`idevice_id -l`).split.uniq.map { |d| d }
    end

    def devices_connected?
      devices.any?
    end

    def check_for_devices
      unless devices_connected?
        puts "\nNo iPhone or iPad Devices Connected!!!\nMake sure at least one REAL device is connected!\n".red
        abort
      end
    end

    def get_device_udid opts_hash
      check_for_devices
      return unless opts_hash[:udid].nil?
      if devices.size == 1
        devices[0]
      else
        puts "\nMultiple iOS devices '#{devices}' found.\nSpecify a single UDID. e.g. -u #{devices.sample}\n".red
        abort unless specs
      end
    end

    def info
      specs = { os: "ProductVersion", name: "DeviceName", arc: "CPUArchitecture", type: "DeviceClass", sdk: "ProductType" }
      hash = { udid: udid }
      specs.each do |key, spec|
        value = (`ideviceinfo -u #{udid} | grep #{spec} | awk '{$1=""; print $0}'`).strip
        hash.merge!({key=> "#{value}"})
      end
      hash
    end

    def recordable?
      false
    end

    def clear_files
      Flick::System.clean_system_dir flick_dir, udid
    end

    def screenshot name
      Flick::Checker.system_dependency "idevicescreenshot"
      %x(idevicescreenshot -u #{udid} #{todir}/#{name}.png)
    end

    def log name
      Flick::Checker.system_dependency "idevicesyslog"
      %x(idevicesyslog -u #{udid} > #{outdir}/#{name}.log)
    end
  end
end
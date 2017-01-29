class Vitals

  attr_accessor :platform, :driver, :name

  def initialize options
    Flick::Checker.platform options[:platform]
    self.platform = options[:platform]
    case @platform
    when "ios"
      options[:todir] = options[:outdir]
      self.driver = Flick::Ios.new options
    when "android"
      self.driver = Flick::Android.new options
    end
    self.name = options[:name]
  end
    
  def vitals
    if platform == "ios"
      puts "\nAndroid only for now. If you know of a tool to get this info for iOS please let me know or add a PR :)\n".yellow; abort
    end
    if name.nil?
      puts "Specify a Package Name. e.g. -n com.viber".red; abort
    else
      driver.get_vitals name
    end
  end
end
class Manager

  attr_accessor :action, :platform, :driver, :udid, :file, :name

  def initialize options
    Flick::Checker.manager options[:action]
    Flick::Checker.platform options[:platform]
    self.action = options[:action]
    self.platform = options[:platform]
    case platform
    when "ios"
      self.driver = Flick::Ios.new options
    when "android"
      self.driver = Flick::Android.new options
    end
    self.udid = self.driver.udid
    self.file = options[:file]
    self.name = options[:name]
  end

  def run
    self.send(action)
  end

  def install
    if file.nil?
      puts "Specify a file path. e.g. -f #{Dir.home}/myApp/amazing-app.apk or .app".red; abort
    else
      Flick::Checker.file_exists? file
      driver.install file
    end
  end

  def uninstall
    if name.nil?
      puts "Specify a Package Name or Bundle ID. e.g. -n ".red; abort
    else
      driver.uninstall name
    end
  end
end
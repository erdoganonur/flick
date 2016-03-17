class Info
  
  attr_accessor :platform, :driver
  
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
  end
    
  def info
    ap driver.info
  end
end
class Screenshot

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
    setup
  end

  def android
    platform == "android"
  end

  def screenshot
    puts "Saving to #{driver.outdir}/#{driver.name}.png"
    driver.screenshot driver.name
    driver.pull_file "#{driver.dir_name}/#{driver.name}.png", driver.outdir if android
  end

  private

  def setup
    driver.clear_files
  end
end
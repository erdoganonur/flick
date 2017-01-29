class Info

  attr_accessor :platform, :driver, :save

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
    self.save = options[:save].to_b
  end
  
  def info
    ap driver.info
    if save
      puts "Saving to #{driver.outdir}/info-#{driver.name}.log"
      save_device_data driver.info
    end
  end
  
  private

  def save_device_data info
    info.each do |k,v|
      open("#{driver.outdir}/info-#{driver.name}.log", 'w') do |file|
        file << "#{k}: #{v}\n"
      end
    end
  end
end
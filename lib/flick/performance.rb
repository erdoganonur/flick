class Performance

  attr_accessor :action, :platform, :driver, :udid, :app

  def initialize options
    Flick::Checker.action options[:action]
    Flick::Checker.platform options[:platform]
    self.action = options[:action]
    self.platform = options[:platform]
    case platform
    when "ios"
      options[:todir] = options[:outdir]
      self.driver = Flick::Ios.new options
    when "android"
      self.driver = Flick::Android.new options
    end
    self.udid = self.driver.udid
    self.app = options[:name]
  end

  def run
    self.send(action)
  end

  def start
    #puts "Saving to #{driver.outdir}/#{driver.name}.log"
    capture_app_performance
  end

  def stop
    Flick::System.kill_process "perf", udid
  end

  def capture_app_performance app
    stop
    $0 = "flick-perf-#{udid}"
    SimpleDaemon.daemonize! "/tmp/#{udid}-pidfile"
    command = -> do
      loop do
        puts "Memory: #{driver.memory(app)}"
        puts "CPU: #{driver.cpu(app)}"
        sleep 5
      end
    end
   command.call
  end
end


 # = "com.microsoft.today"
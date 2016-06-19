class Performance

  attr_accessor :action, :platform, :driver, :udid, :app, :example, :graphite

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
    self.example = options[:example]
    self.graphite = GraphiteAPI.new( graphite: options[:graphite] )
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

  def capture_app_performance
    stop
    $0 = "flick-perf-#{udid}"
    SimpleDaemon.daemonize! "/tmp/#{udid}-pidfile"
    command = -> do
      loop do
        #puts "#{platform} #{test} Memory: #{driver.memory(app)}"
        graphite.metrics({"#{app.gsub(".","_")}.#{example}.memUsage" => driver.memory(app)}, Time.at(Time.now.to_i))
        #puts "#{platform} #{test} CPU: #{driver.cpu(app)}"
        graphite.metrics({"#{app.gsub(".","_")}.#{example}.cpuUsage"  => driver.cpu(app)}, Time.at(Time.now.to_i))
        sleep 5
      end
    end
   command.call
  end
end
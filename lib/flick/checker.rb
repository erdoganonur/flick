module Flick
  module Checker
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        }
      end
      return nil
    end

    def self.system_dependency dep
      program = which dep
      if program.empty?
        puts "\n#{dep} was not found. Please ensure you have installed #{dep} and it's in your $PATH\n".red
        abort
      end
    end

    def self.platform platform
      platforms = ["android","ios"]
      unless platforms.include? platform
        puts "\nPlease specify a valid platform #{platforms}. e.g. flick <job> -a start -p #{platforms.sample}\n".red
        abort
      end
    end

    def self.action action
      actions = ["start","stop"]
      unless actions.include? action
        puts "\nPlease specify a valid action #{actions}. e.g. flick <job> -a #{actions.sample} -p ios\n".red
        abort
      end
    end

    def self.format format
      formats = ["mp4","gif"]
      unless formats.include? format
        puts "\nPlease specify a valid format #{formats}. e.g. flick <job> -a stop -p ios -f #{formats.sample}\n".red
        abort
      end
    end
  end
end
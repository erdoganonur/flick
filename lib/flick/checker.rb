module Flick
  module Checker
    def self.system_dependency dep
      program = `which #{dep}`
      if program.empty?
        puts "\n#{dep} was not found. Please ensure you have installed #{dep} and it's in your $PATH\n".red
        abort
      end
    end
    
    def self.platform platform
      platforms = ["android","ios"]
      unless platforms.include? platform
        puts "\nPlease specify a valid platform #{platforms}. e.g. flick <job> -p #{platforms.sample}\n".red
        abort
      end
    end
  end
end
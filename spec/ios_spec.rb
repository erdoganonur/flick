require 'spec_helper'

describe "Flick iOS Validations" do
  
  before :all do
    @options = {platform: "ios", flick_dir: "#{Dir.home}/.flick", outdir: Dir.pwd}
    Flick::Ios.new(@options).check_for_devices
    `rm *.png *.mp4 >> /dev/null 2>&1`
  end

  after :each do
    `rm *.png *.mp4 >> /dev/null 2>&1`
  end
  
  it 'capture a screenshot on device' do
    @options.merge!({name: "ios-screenshot"})
    flick = Screenshot.new(@options)
    file = "#{@options[:name]}.png"
    flick.screenshot
    expect(File.file? file).to eq true
  end
  
  it 'capture a video on device' do
    @options.merge!({ count: 500, seconds: 0.5, name: "ios-video", todir: "#{Dir.home}/.flick"})
    flick = Video.new(@options)
    file = "#{@options[:name]}.mp4"
    flick.start; sleep 3
    flick.stop
    start = Time.now
    until File.file? file
      sleep 1; break if Time.now - start > 30
    end
    expect(File.file? file).to eq true
  end
  
  it 'screenshot count exceeded on device' do
    @options.merge!({ count: 10, seconds: 0.5, name: "ios-video", todir: "#{Dir.home}/.flick"})
    flick = Video.new(@options)
    file = "#{@options[:name]}.mp4"
    flick.start
    start = Time.now
    until File.file? file
      sleep 1; break if Time.now - start > 30
    end
    expect(File.file? file).to eq true
  end
end
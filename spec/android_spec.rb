require 'spec_helper'

describe "Flick Android Validations" do
  
  before :all do
    androids = ["TA64300B9C", "emulator-5554"] #set one real device and one emulator
    @options = {platform: "android", flick_dir: "#{Dir.home}/.flick", dir_name: "sdcard/flick", outdir: Dir.pwd, specs: true}
    Flick::Android.new(@options).check_for_devices
    abort unless (Flick::Android.new(@options).devices - androids).empty?
    `rm *.png *.mp4 >> /dev/null 2>&1`
  end

  after :each do
    `rm *.png *.mp4 >> /dev/null 2>&1`
  end
  
  it 'capture a screenshot on device' do
    @options.merge!({udid: "TA64300B9C", name: "android-device-screenshot"})
    flick = Screenshot.new(@options)
    file = "#{@options[:name]}.png"
    flick.screenshot
    expect(File.file? file).to eq true
  end
  
  it 'capture a screenshot on emulator' do
    @options.merge!({udid: "emulator-5554", name: "android-emulator-screenshot"})
    flick = Screenshot.new(@options)
    file = "#{@options[:name]}.png"
    flick.screenshot
    expect(File.file? file).to eq true
  end

  it 'capture a video on device' do
    @options.merge!({udid: "TA64300B9C", name: "android-device-video"})
    flick = Video.new(@options)
    file = "#{@options[:name]}.mp4"
    flick.start; sleep 3 #need to wait for video to start
    flick.stop
    expect(File.file? file).to eq true
  end
  
  it 'capture extended video on device' do
    #must have something activily running on the screen. mp4box will limit video to uniqueness otherwise.
    @options.merge!({udid: "TA64300B9C", name: "android-device-video-extended", extend: true, limit: 5})
    flick = Video.new(@options)
    file = "#{@options[:name]}.mp4"
    flick.start; sleep 10 #Wait for SDK limit to exceed.
    flick.stop
    expect(File.file? file).to eq true
    runtime = Flick::System.video_length(file)
    expect(DateTime.parse(runtime).sec).to be > 5
  end
  
  it 'capture a video on emulator' do
    @options.merge!({ count: 500, seconds: 0.5, udid: "emulator-5554", name: "android-emulator-video"})
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
  
  it 'screenshot count exceeded on emulator' do
    @options.merge!({ count: 10, seconds: 0.5, udid: "emulator-5554", name: "android-emulator-video-exceeded"})
    flick = Video.new(@options)
    file = "#{@options[:name]}.mp4"
    flick.start
    start = Time.now
    until File.file? file
      sleep 1; break if Time.now - start > 30
    end
    expect(File.file? file).to eq true
  end
  
  xit 'pull all files' do
    @options.merge!({ count: 10, seconds: 0.5, udid: "emulator-5554", name: "android-emulator-video-all-files", unique: false})
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
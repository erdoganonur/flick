# FLICK
A CLI to capture screenshots and video for Android (Devices & Emulators) and iOS (**Real** Devices).

<img src="https://www.dropbox.com/s/o49et3fhncu3l4v/animacii_09.gif?raw=1">

Features
--------

* Easily capture screenshots for Android and iOS.
* Video record real android devices. (OS > 4.4)
	* Extend recording past the 180 seconds SDK limit.
* Flick auto detects whether a device is recordable.
	* Falls back to screenshot recording if video record is not available.
* Video record android emulators and **real** iOS devices.
	* Takes a screenshot every 0.5 seconds (default), then combines the screenshots into a single mp4.
	* iOS example [here](https://www.dropbox.com/s/4pjhhmnsx9gj5pi/ios-flick-example.mp4?dl=0)
	* Android Emulator example [here](https://www.dropbox.com/s/gwunrvgzxkny13z/android-flick-example.mp4?dl=0)
* Flick auto selects the device when only one device is connected, per platform.

Reason
------
I wanted an easy way to video record my automation tests for mobile, and the video quality didn't need to be perfect. Unfortunately, you cannot video record on android emulators, but you can take screenshots! You also cannot video record iOS without using QuickTime, or doing what [this](https://github.com/appium/screen_recording) did, but it's not maintained anymore.

So I created Flick to work for my needs, and hopefully it will for others. It's also a CLI and language-agnostic, it can be used with any framework where you can make a system call. See examples [here](https://github.com/isonic1/appium-mobile-grid/blob/flick/ios/spec/spec_helper.rb#L14) and [here](https://github.com/isonic1/appium-mobile-grid/blob/flick/android/spec/spec_helper.rb#L22). I suppose there are use cases for this outside of test automation. I'd love to hear them if so.

If you're looking for high-quality video, then this wouldn't be the tool for you. Take a look at this great tool [androidtool-mac](https://github.com/mortenjust/androidtool-mac) instead.

Prerequisites 
-------------
#### System Tools
* Install ffmpeg. [OSX](https://trac.ffmpeg.org/wiki/CompilationGuide/MacOSX)
	* ```$ brew install ffmpeg```
* Install mp4box. [OSX](http://hunterford.me/compiling-mp4box-on-mac-os-x/)
	* ```$ brew install mp4box```

#### Android
* Install [SDK Tools](http://developer.android.com/sdk/installing/index.html?pkg=tools).
* SDK tools are added to your $PATH. [OSX](http://stackoverflow.com/questions/5526470/trying-to-add-adb-to-path-variable-osx) 
* Enable [USB Debugging](https://www.kingoapp.com/root-tutorials/how-to-enable-usb-debugging-mode-on-android.htm) on your device(s).
* Emulator or Devices have approximately 1GB of [sdcard space](http://developer.android.com/tools/help/mksdcard.html).

#### iOS
* Install [Xcode](https://developer.apple.com/xcode/download/).
* Install Xcode [Command Line Tools](http://railsapps.github.io/xcode-command-line-tools.html).
* Enable [Developer Mode](http://apple.stackexchange.com/questions/159196/enable-developer-inside-the-settings-app-on-ios) on iPhone or iPad devices.
* Install [libimobiledevice](http://www.libimobiledevice.org/).
	* ```$ brew install libimobiledevice```

Installation
------------

    $ gem install flick


Usage:
------

    $ flick --help

      DESCRIPTION:
      A CLI to capture screenshots and video for Android (Devices & Emulators) and iOS (Devices).

	  COMMANDS:
        
	    help       Display global or [command] help documentation           
	    screenshot Take a screenshot                
	    start      Start video recording            
	    stop       Stop video recording    

      GLOBAL OPTIONS:
	    
		-h, --help 
	        Display help documentation
        
	    -v, --version 
	        Display version information
        
	    -t, --trace 
	        Display backtrace when an error occurs 

```
    
    $ flick start --help
  
    SYNOPSYS:
	  flick start [options]
	  
	DESCRIPTION:
	  Start video recording
	
	EXAMPLES:    
      flick start -p ios
	  flick start -p android -u emulator-5554
	  flick start -p android -u TA64300B9C -e true

     OPTIONS:
	  	-p, --platform PLATFORM 
	        Set platform: android or ios
    
	    -u, --udid UDID 
	        Set device UDID.
    
	    -s, --seconds SECONDS 
	        Set the seconds per screenshot. Default: 0.5
    
	    -c, --count COUNT 
	        Set maximum number of screenshots. Default: 500
    
	    -e, --extend EXTEND 
	        Extend android video recording past 180 seconds for REAL devices. Default: false
```

    $ flick stop --help
  
    SYNOPSYS:
	  flick stop [options]
	  
	DESCRIPTION:
	  Stop video recording
	
	EXAMPLES:    
      flick stop -p android -n my_video
	  flick stop -p android -u emulator-5554 -o $HOME -q false

     OPTIONS:
	    -p, --platform PLATFORM 
	        Set platform: android or ios
        
	    -u, --udid UDID 
	        Set device UDID
        
	    -n, --name NAME 
	        Set name of output file, Default: UDID
        
	    -q, --unique UNIQUE 
	        Pull only unique screenshots. Significantly speeds up the pulling process. Default: true
        
	    -o, --outdir OUTDIR 
	        Set output directory. Default is /Users/justin/repos/flick
```

    $ flick screenshot --help
  
    SYNOPSYS:
	  flick screenshot [options]
	  
	DESCRIPTION:
	  Take a screenshot
	
	EXAMPLES:    
      flick screenshot -p ios
	  flick screenshot -p android -n my_screenshot -o ~/screenshots

     OPTIONS:
	    -p, --platform PLATFORM 
	        Set platform: android or ios
        
	    -u, --udid UDID 
	        Set device UDID.
        
	    -n, --name NAME 
	        Set name of output file. Default: UDID
        
	    -o, --outdir OUTDIR 
	        Set output directory. Default is /Users/justin/repos/flick
```
Demo
----
<img src="https://www.dropbox.com/s/7dcuvezwcajvb42/flick.gif?raw=1">

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/isonic1/flick. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## TODO
* Add converting to .gif format as an option.
* Capture logcat data.
* capture iOS console data.
* Setup Flick android for cross platform os's (windows & linux)
* Add screenshot capture for iOS Simulators.
* Multithread the screenshot and pull process.
* catpure video from iOS similar to [this](https://github.com/mortenjust/androidtool-mac/blob/9347cd9aeca9e7370e323d12f862bc5d8beacc25/AndroidTool/IOSDeviceHelper.swift#L56)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


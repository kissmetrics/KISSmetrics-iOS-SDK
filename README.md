KISSmetrics-iOS-SDK
===================

For implementation details please see: https://support.kissmetrics.io/reference#ios-v2


CocoaPods:
----------
Add ``pod 'KISSmetrics-iOS-SDK'`` to your Podfile.


Adding Manually:
--------

* Add the `Framework/KISSmetricsSDK.xcodeproj`  to your existing project.
* In your app's Target go to `Build Phases` and under `Dependencies` add the `KISSmetricsSDK`


Inclusion:
----------
Import the API class in your AppDelegate and in any classes where you'll be tracking from:

Swift
```swift
import KISSmetrics_iOS_SDK
```

Objective-C
```objective-c
@import KISSmetrics_iOS_SDK;
```

Initialization:
---------------

At the top of the application delegate's ``didFinishLaunchingWithOptions`` method, add:

Swift
```swift
KISSmetricsAPI.sharedAPI(withKey: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
```

Objective-C
```objective-c
[KISSmetricsAPI sharedAPIWithKey:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"];
```

Usage:
------

After initializing the API and configuring events as described above, record an event with:

Swift
```swift
KISSmetricsAPI.shared().record("/app_launched")
```
Objective-C
```objective-c
[[KISSmetricsAPI sharedAPI] record:@"/app_launched"];
```


To record an event with properties:

Swift
```swift
KISSmetricsAPI.shared().record("/content_view", withProperties: ["Content Name": "Rogue One"])
```
Objective-C
```objective-c
[[KISSmetricsAPI sharedAPI] record:@"/content_view" withProperties: @{ @"Content Name": @"Rogue One"}];
```

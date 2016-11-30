KISSmetrics-iOS-SDK
===================


This workspace contains the source files that build the SDK as a framework (``KISSmetricsSDK.framework``) and the required public interface (``KISSmetricsAPI.h``). The source files included here are not intended to be used directly in your app.


For implementation details please see: http://support.kissmetrics.com/apis/ios-v2


Framework project setup:
------------------------
Setting up a framework project requires several steps and may change from one version of Xcode to the next. Rather than listing all the steps here, please refer to this tutorial: http://blog.db-in.com/universal-framework-for-ios/


CocoaPods:
----------
Add ``pod 'KISSmetrics-iOS-SDK'`` to your Podfile.


Inclusion:
----------
Import the API class in your AppDelegate and in any classes where you'll be tracking from: 

```objective-c
#import <KISSmetricsSDK/KISSmetricsAPI.h>
```


Initialization:
---------------
Manual: (Required if ``KISSmetricsAPI_options.m`` is not used)
At the top of the application delegate's ``didFinishLaunchingWithOptions`` method, add:

```objective-c
[KISSmetricsAPI sharedAPIWithKey:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"];
```

Automatic: (Requires ``KISSmetricsAPI_options.m``)
The customer's settings, including their API key, will live in ``KISSmetricsAPI_options.m``
We can build this file for them based on selections made during new KM Product setup 
and deliver it along with KISSmetricsAPI.framework and ``KISSmetricsAPI.h``.
If this file is included, attemps to initialize with sharedAPIWithKey will be ignored. 
Even if the provided key is different than the key set in ``KISSmetricsAPI_options.m``.

Configuration:
--------------
Events to be tracked must be configured in KISSmetrics.

Log in to https://app.kissmetrics.com and go to the "Events" tab. Click on "Create new tracking rule" to create a new event.
Note that events expect a URL; just create a dummy URL to represent the event. For example, for "App Launched"  use "/app_launched".
You must use this exact URL when you record the event via the API.

Usage:
------

After initializing the API and configuring events as described above, record an event with: 

[[KISSmetricsAPI sharedAPI] record:@"/app_launched"];

To record an event with properties:

[[KISSmetricsAPI sharedAPI] record:@"/content_view" withProperties: @{ @"Content Name": @"Rouge One"}];

Swift:
------

The API has been successfully tested and called from Swift project.

Create a Swift Bridging Header using "How to create a Swift Bridging Header Manually" instructions in http://www.learnswiftonline.com/getting-started/adding-swift-bridging-header/

Your header will look something like this:

```objective-c
//
//  FlappyBird-Bridging-Header.h
//  FlappyBird
//
//  Created by Peter O'Leary on 11/19/16.
//

#ifndef FlappyBird_Bridging_Header_h
#define FlappyBird_Bridging_Header_h

#import "KISSmetrics-iOS-SDK/KISSmetricsAPI.h"

#endif /* FlappyBird_Bridging_Header_h */
```

Call the API like this:

```swift
KISSmetricsAPI.sharedAPI(withKey: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
KISSmetricsAPI.shared().record("/app_launched")
```

Tests:
---------------------------------
The SDK will support both ARC/non-ARC and 32bit/64bit projects.
One test project is included in this workspace for running application integration tests against the build files directly.

Note: the testAppVersionKeychainSetter and testAppVersionKeychainGetter test require setting up Keychain entitlements for the KISSmetricsSDK_buildFiles_arc_imp project


File organization:
------------------
All API files will live in the `KISSmetricsAPI` dir outside of any project.
Projects will link to the shared `KISSmetricsAPI` dir.


Style:
-----
* Private vars - prefix with an underscore
* Private methods - prefix with ``kma_``
* Unit test helper methods - prefix with ``uth_``


Building:
--------
* Select `KISSmetricsAPI Scheme > iPhone Simulator` and `Run`
* Select `KISSmetricsSDK Scheme > iOS Device` and `Run`
* Select `UniversaliOS Scheme > iOS Device` and `Run`


You should find the compiled framework `KISSmetricsAPI.framework` in this repo's root dir.


32bit and 64bit architectures:
--------------------------
In order to support arm64, arm7, arm7s both the KISSmetricsAPI lib target and
UniversaliOS aggregate target need to be built targeting iOS7 with
Standard architectures (including 64-bit)(armv7, armv7s, arm64).
To confirm that the these architectures were included in the final framework build,
cd into the built KISSmetricsAPI.framework dir and run:

```bash
otool -V -f KISSmetricsSDK
```

Logging:
-------
Internal logging for our own purposes.

Don't use ``NSLog``, use ``KMALog`` which can be toggled by KMALogVerbose for release of our compiled SDK and only applies under DEBUG. (see KMAMacros.c)

We may wish to define a ``KMAInfoLog`` which will output logs to our customer devs. This should also have a verbose toggle
that the customer dev can control.


Assertions:
----------
Our SDK should always fail gracefully when not in DEBUG. Use ``KMAAssert`` over ``NSAssert`` to prevent assertions from our SDK when the customer's app has been built for release.

Only use ``KMAAssert`` for crucial warnings to the customer devs. Otherwise use ``NSLog``
or ``KMAInfoLog`` (if implemented)


Testing:
-------
We're using OCMockito to aid in unit and application testing.
https://github.com/jonreid/OCMockito

The `KISSmetricsSDK_framework_builder` includes a set of unit tests but because the
framework builder is not an application, application tests of the framework
are conducted under `KISSmetricsSDK_buildFiles_arc_imp`.

You should write your application tests in `KISSmetricsSDK_buildFiles_arc_imp` first rather
than rebuilding the framework between each change to the SDK.


Category Extension:
------------------
Any category added to our SDK framework must use a unique name and every method within must also use a unique prefix to avoid conflicts with customer dev categories!

* Use ``KMA`` as a class or constants prefix.
* Use ``kmac_`` for any public category methods.
* Use ``kma_`` as normal for any private methods.


Maintenance:
-----------
1. Run all tests against each new release of iOS.
2. As new iOS devices and device families are released, we'll need to add them to UIDevice+KMAHardware.
3. Be sure to update the kKMAAPIUserAgent value of KMAArchiver with each update.



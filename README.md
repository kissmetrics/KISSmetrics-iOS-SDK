KISSmetrics-iOS-SDK
===================


This workspace contains the source files that build the SDK as a framework (``KISSmetricsSDK.framework``) and the required public interface (``KISSmetricsAPI.h``). The source files included here are not intended to be used directly in your app.


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

```objective-c
import <KISSmetrics/KISSmetricsAPI.h>
```
```swift
import KISSmetrics
```

Initialization:
---------------
Manual: (Required if ``KISSmetricsAPI_options.m`` is not used)
At the top of the application delegate's ``didFinishLaunchingWithOptions`` method, add:

```objective-c
[KISSmetricsAPI sharedAPIWithKey:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"];
```

```swift
KISSmetricsAPI.sharedAPI(withKey: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
```

Automatic: (Requires ``KISSmetricsAPI_options.m``)
The customer's settings, including their API key, will live in ``KISSmetricsAPI_options.m``
We can build this file for them based on selections made during new KM Product setup
and deliver it along with KISSmetricsAPI.framework and ``KISSmetricsAPI.h``.
If this file is included, attemps to initialize with sharedAPIWithKey will be ignored.
Even if the provided key is different than the key set in ``KISSmetricsAPI_options.m``.

Usage:
------

After initializing the API and configuring events as described above, record an event with:

```objective-c
[[KISSmetricsAPI sharedAPI] record:@"/app_launched"];
```

```swift
KISSmetricsAPI.shared().record("/app_launched")
```

To record an event with properties:

```objective-c
[[KISSmetricsAPI sharedAPI] record:@"/content_view" withProperties: @{ @"Content Name": @"Rogue One"}];
```
```swift
KISSmetricsAPI.shared().record("/content_view", withProperties: ["Content Name": "Rogue One"])
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



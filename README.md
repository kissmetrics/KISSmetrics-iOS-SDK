KISSmetrics-iOS-SDK
===================


This workspace contains the source files that build the SDK as a framework (``KISSmetricsSDK.framework``) and the required public interface (``KISSmetricsAPI.h``). The source files included here are not intended to be used directly in your app.


For implementation details please see: http://support.kissmetrics.com/apis/ios-v2/


Framework project setup:
------------------------
Setting up a framework project requires several steps and may change from one version of Xcode to the next. Rather than listing all the steps here, please refer to this tutorial: http://blog.db-in.com/universal-framework-for-ios/


Initialization:
---------------
Manual: (Required if ``KISSmetricsAPI_options.m`` is not used)
At the top of the application delegate's didFinishLaunching method, add
[KISSmetricsAPI sharedAPIWithKey:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"];

Automatic: (Requires ``KISSmetricsAPI_options.m``)
The customer's settings, including their API key, will live in ``KISSmetricsAPI_options.m``
We can build this file for them based on selections made during new KM Product setup 
and deliver it along with KISSmetricsAPI.framework and ``KISSmetricsAPI.h``.
If this file is included, attemps to initialize with sharedAPIWithKey will be ignored. 
Even if the provided key is different than the key set in ``KISSmetricsAPI_options.m``.


Tests:
---------------------------------
The SDK will support both ARC/non-ARC and 32bit/64bit projects.
One test project is included in this workspace for running application integration tests against the build files directly.


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


You should find the compiled framework at:

```
~/Library/Developer/Xcode/DerivedData/KISSmetrics-iOS-SDK-xxxxxxxxxx/Build/Products/KISSmetricsAPI.framework
```

(Your location will vary slightly)


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



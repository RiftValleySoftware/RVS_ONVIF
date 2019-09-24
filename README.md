![Icon](./icon.png)

RVS_ONVIF
=
This project is a low-level [ONVIF](https://onvif.org) "driver" for Cocoa (Apple's [MacOS](https://www.apple.com/macos), [iOS](https://www.apple.com/ios) and [tvOS](https://www.apple.com/tvos)).

WARNING: THIS IS A WORK IN PROGRESS!
-
RVS_ONVIF is a large-scale project that is still very much under development. It does not yet have full support for the ONVIF Core profile, and there's still a lot of work to do on the S profile (for example, supporting PTZ).

That said, it has been tested on cameras from a number of different manufacturers, and is designed to be completely "manufacturer-agnostic." There's a lot of "leeway" built into the driver, and it works well with the current functionality.

MULTI-OPERATING SYSTEM
-
RVS_ONVIF is designed to support [iOS](https://apple.com/ios)/[ipadOS](https://apple.com/ipados), [macOS](https://apple.com/ios), and [tvOS](https://apple.com/ios). There are test harnesses for all of these operating systems.

BASIC STRUCTURE
-
The project uses a "hub and spokes" structure, with a central "engine," and adapters for the various profiles.

DISPATCHERS
-
The driver uses a "Dispatcher" pattern, similar to Apple's Delegate pattern, but with a couple of differences:

1) You can have more than one "delegate." We call them "Dispatchers." The approach is more like registering for observer notifications than the "one only" registration that the Delegate pattern uses, but with the back-and-forth that the Delegate pattern prescribes. Each Dispatcher talks to the driver. It is not a one-way conversation.
2) Each "Dispatcher" prescribes a protocol (not a class, like a delegate) that extends a central one.

The messages that each profile handler/dispatcher wrks with are an "opaque" enum. We play some games to allow each dispatcher to add its own commands to the "smart" enum declared by the the central "hub."

DEPENDENCIES
=
BUILD DEPENDENCIES
-
For testing, we depend upon [SWXMLHash](https://github.com/drmohundro/SWXMLHash), written by [David Mohundro](https://mohundro.com/) to parse mock XML data.
***NOTE:** For whatever reason, the CocoaPods project sets the Swift version of the SWXMLHash project to 3.0. Set it to 5. It will work*.
For code LINTing, we use [SwiftLint](https://github.com/realm/SwiftLint), written by the fine folks at [Realm.io](https://realm.io/).
For video display in our test harneses, we depend on variations of [VLCKit](https://code.videolan.org/videolan/VLCKit), written and maintained by the team at [VideoLAN](https://www.videolan.org/).

We use [Carthage](https://github.com/Carthage/Carthage) to include the VLCKit variants, and [CocoaPods](https://cocoapods.org) to include SwiftLint.

RUNTIME DEPENDENCIES
-
We use [SOAPEngine](https://github.com/priore/SOAPEngine) written and maintained by [the Priore Group](https://www.prioregroup.com) for dealing with the low-level SOAP wrapper.

SOAPEngine is directly copied and embedded in the project. It is not a submodule.

If you want to use RVS_ONVIF on devices, then you must [obtain a license for SOAPEngine](https://github.com/priore/SOAPEngine/blob/master/README.md#licenses) from Priore Group.

NOTE ABOUT TESTING:
-
We directly include the unit tests, as opposed to building the modules, because we are using completely generic tests, applied to all three platforms, so we don't want to deal with any conditional import weirdness.

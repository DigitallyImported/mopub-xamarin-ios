using System;
using ObjCRuntime;

[assembly: LinkWith (
    "mopub.a", 
    LinkTarget.Simulator | LinkTarget.Simulator64 | LinkTarget.ArmV7 | LinkTarget.Arm64, 
    SmartLink = true, 
    ForceLoad = true,
    Frameworks = "AVFoundation AudioToolbox CoreGraphics CoreLocation CoreTelephony EventKit EventKitUI Foundation MediaPlayer MessageUI QuartzCore StoreKit SystemConfiguration UIKit iAd AdSupport StoreKit")]

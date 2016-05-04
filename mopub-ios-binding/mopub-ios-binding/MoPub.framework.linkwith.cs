using ObjCRuntime;

[assembly: LinkWith (
	"MoPub.framework",
	LinkTarget.Simulator | LinkTarget.Simulator64 | LinkTarget.ArmV7 | LinkTarget.Arm64,
	SmartLink = true,
	Frameworks = "AudioToolbox AVFoundation CoreGraphics CoreLocation CoreMedia CoreTelephony EventKit EventKitUI Foundation iAd MediaPlayer MessageUI MobileCoreServices QuartzCore SystemConfiguration UIKit",
	WeakFrameworks = "AdSupport CoreBluetooth PassKit Social StoreKit")]

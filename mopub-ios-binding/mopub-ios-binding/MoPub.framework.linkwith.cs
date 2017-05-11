using ObjCRuntime;

[assembly: LinkWith (
	"MoPub.framework",
	LinkTarget.Simulator | LinkTarget.Simulator64 | LinkTarget.ArmV7 | LinkTarget.Arm64,
	SmartLink = true,
	Frameworks = "AudioToolbox AVFoundation CoreGraphics CoreLocation CoreMedia CoreMotion CoreTelephony EventKit EventKitUI Foundation MediaPlayer MessageUI MobileCoreServices QuartzCore SystemConfiguration UIKit CFNetwork",
    WeakFrameworks = "AdSupport CoreBluetooth PassKit Social StoreKit Webkit")]

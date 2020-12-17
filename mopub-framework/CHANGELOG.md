## Version 5.8.0 (July 22, 2019)
- **Features**
  - Minimum version of the MoPub SDK bumped to iOS 9.
  - StoreKit Improvement: New Apple URL schemes for apps.apple.com, books.apple.com, and music.apple.com are now parsed for `SKStoreProductViewController`.
  - StoreKit Improvement: Affiliate token and campagin token are now parsed for `SKStoreProductViewController`.
  - Existing banner constants are deprecated in favor of new, configurable height-based constants. To use these, `MPAdView`'s frame must be set before an ad load is attempted.
  - Updated `MPAdView`'s `initWithAdUnitId:size:`, `loadAd`, and `adViewDidLoadAd:` APIs by providing overloads `initWithAdUnitId:`, `loadAdWithMaxAdSize:`, and `adViewDidLoadAd:adSize:` which move the requested ad size to load time instead of at initialization time.
  - `SFSafariViewController` is now exclusively used for in-app clickthrough destinations.
  - Disallow the sending of empty ad unit IDs for consent.

- **Bug Fixes**
  - iOS 13 fixes: Explicitly set `modalPresentationStyle` for all modals in the MoPubSDK to `UIModalPresentationFullSCreen` since iOS 13 beta 1 changed the default modal presentation behavior.
  - Fixed occasional crash due with `MPTimer` by ensuring it is always run on the main runloop.
  - Fixed bug where banner and medium rectangle auto refresh timer was being fired even if the refresh interval was zero.
  - Fixed bug where updated ad targeting parameters were not sent when banners were auto refreshing.
  - Fixed a bug where the `UIButton+MPAdditions` category was impacting all `UIButton`s in the app. MoPub-specific `UIButton` customization is now contained in a subclass.

## Version 5.7.1 (June 3, 2019)
- **Features**
  - Impression Level Revenue Data can now be received via a notification

- **Bug Fixes**
  - Fixed occasional crash due to multithreading bug

## Version 5.7.0 (May 20, 2019)
- **Features**
  - Impression Level Revenue Data: A data object that includes revenue information associated with each impression
  - Verizon Ads SDK now supported as a mediated network

- **Bug Fixes**
  - Fixed bug where native video fires an impression when main image asset is missing
  - Fixed MRAID off-screen compliance for resized ads on tablets
  - Fixed crash in Canary App when tapping on the `+` on iPad
  - Replaced deprecated usage of `openURL:` with `openURL:options:completionHandler:` for iOS10+
  - Fixed bug where click trackers can fire more than once on HTML banners and HTML interstitials
  - Fixed bug in Canary App where ad units that were read using the QR code reader were not being saved
  - Fixed bug where GDPR consent dialog was allowed to be presented twice in a row

## Version 5.6.0 (March 18, 2019)
- **Features**
  - Added `+` button to the Canary sample app allowing manual entry of custom ad units

- **Bug Fixes**
  - MRAID orientation, expansion, and resizing edge case bug fixes
  - MRAID expansion will no longer trigger a click tracking event
  - MRAID logging no longer spams the device console
  - Fixed position bug of the Rewarded Video countdown timer when rotating the device after the ad loads

## Version 5.5.0 (January 28, 2019)
- **Features**
  - Advanced Bidding automatically initializes
  - GDPR legitimate interest API now available; publishers may opt into allowing supported networks to collect user information on the basis of legitimate interest.
  - We now distribute separate frameworks for simulator, device, and universal architectures

- **Bug Fixes**
  - Fixed rewarded video state occasionally not being reset correctly upon load failure
  - Tweaked MRAID `ready` event timing so that it's in-spec
  - Canary test app improvements and bug fixes

## Version 5.4.1 (November 28, 2018)
- **Bug Fixes**
  - Changed the MoPubSampleApp+Framework target to MoPubSampleApp in the Objective-C Sample App.
  - Fixed crash when `MPTableViewAdPlacer` makes multiple ad requests within a short amount of time.
  - Fixed bug with the internal state of rewarded video when the video fails to play.

## Version 5.4.0 (October 3, 2018)
- **Features**
  - SDK distribution as a dynamic framework is now available.
  - Local extras are now supported for all ad formats.

- **Bug Fixes**
  - HTTP error codes now include the localized error description.
  - Added missing mraid.js file protections when showing MRAID ads.
  - Fixed native video crash.
  - Fixed native ad timeout timer invalidation.

## Version 5.3.0 (August 15, 2018)
- **Features**
  - Laying the foundation for platform optimization work that enables the SDK to receive multiple ad responses per ad request, reducing the number of round trips between the server and the client required to fill the requests.

## Version 5.2.0 (July 9, 2018)
- **Features**
  - SDK initialization is required for ads to load.
  - Added callback to the consent dialog when it is dismissed.

- **Bug Fixes**
  - Synchronized access to shared `NSMutableDictionary` in `MPHTTPNetworkSession`.
  - Video ads using Device orientation now appear aligned correctly on iPhone X.

## Version 5.1.0 (June 5, 2018)
- **Features**
  - Updated `MPReachability` to be IPv6 compliant.
  - Allow publishers to determine which users should be treated as GDPR compliant users through the new API `forceGDPRApplicable`.
  - Alert a publisher (through logs) when they are trying to use the new GDPR consent flow without being whitelisted.
  - Banner refresh will only occur after an impression.

## Version 5.0.0 (May 14, 2018)
- **Features**
  - General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain and manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads.
  - New SDK initialization method to initialize consent management and rewarded video ad networks. Required for receiving personalized ads. In future versions of the SDK, initialization will be required to receive ads.
  - Updated the networking stack to use `NSURLSession` in place of the deprecated `NSURLConnection`.
  - Updated ad requests to use POST instead of GET.

- **Bug Fixes**
  - Renamed the `/MoPubSDK/Native Ads/` folder to `/MoPubSDK/NativeAds/`.
  - Removed the usage of deprecated `shouldAutorotateToInterfaceOrientation`.

## Version 4.20.1 (March 12, 2018)
- **Bug Fixes**
  - Fixes compatibility issues with some fullscreen ads on iPhone X

## Version 4.20.0 (February 20, 2018)
- **Bug Fixes**
  - Fixed ad expiration check for rewarded ad formats

- **Ad Network Mediation Updates**
  - Network mediation adapters are now in a separate repository to enable an independent release cadence and faster updates to the adapters. Please find the new location [here](https://github.com/mopub/mopub-ios-mediation).

## Version 4.19.0 (December 11, 2017)
- **Bug Fixes**
  - Ensure proper viewability initialization before ad content is loaded
  - Fire appropriate error delegate when rewarded video ad view is not ready to be shown
  - Resolve video playback sizing issue when creative MoPubForceOrientation is set to "Device"
  - Resolve WKWebView sizing and alignment issues on iPhoneX

- **Ad Network Mediation Updates**
  - Certified Facebook Audience Network 4.26.1
  - Certified Flurry 8.1.0
  - Added support for Millennial/AOL Rewarded Video adapters for 6.6.0

## Version 4.18.0 (November 1, 2017)
- **Features**
    - iPhone X compatibility improvements including moving the close button into safe area.

- **Bug Fixes**
  - Fixed a bug with unspecified rewarded video currencies.
  - Fixed C99 compilation bug.

- **Ad Network Mediation Updates**
  - AdColony 3.2.1
  - AdMob 7.24.1
  - AOL 6.6.0 (formerly Millennial)
  - Chartboost 7.0
  - Facebook Audience Network 4.26.0
  - Tapjoy 11.11.0
  - Unity Ads 2.1.1
  - Vungle 5.3.0

## Version 4.17.0 (September 27, 2017)
- **Features**
    - Rewarded videos can now optionally pass back custom data to the publisher's reward server.
    - Updated the minimum iOS version of the SDK to iOS 8.
    - Update Facebook adapter with non whitespace clickable policy.

## Version 4.16.0 (August 23, 2017)
- **Features**
  - Added viewability support for Integral Ad Science (IAS) and Moat, two of the leading independent viewability measurement providers
    - To disable this feature, see note below on [Disabling Viewability Measurement](#disableViewability).
  - New app launch rewarded video initialization method for mediated network SDKs
- **Bug Fixes**
  - Fixed native video crash caused by empty VAST tracking event
  - Prevent interstitials from firing clicks without user interaction
### <a name="disableViewability"></a>Disabling Viewability Measurement
There are a few options for opting out of viewability measurement:
##### Opting Out in a Manual Integration
Before dragging the MoPubSDK folder into your Xcode project, simply delete the “Moat” folder to opt out of Moat or the “Avid” folder to opt out of IAS in MoPubSDK/Viewability/. If you would like to opt out of both, delete both folders.
##### Opting Out in a CocoaPods Integration
Including `pod 'mopub-ios-sdk'` in your Podfile will include both IAS and Moat SDKs, as well as the MoPub SDK. In order to opt out:
- `pod 'mopub-ios-sdk/Avid'` will include the IAS SDK, but not the Moat SDK, as well as the MoPub SDK.
- `pod 'mopub-ios-sdk/Moat'` will include the Moat SDK, but not the IAS SDK, as well as the MoPub SDK.
- `pod 'mopub-ios-sdk/Core'` will only include the MoPub SDK, with viewability measurement totally disabled.

Make sure to run `pod update` once your Podfile is set up to your preferences.
##### Software Disable
If you would like to opt out of viewability measurement but do not want to modify the MoPub SDK, a function is provided for your convenience. As soon as possible after calling `[[MoPub sharedInstance] start]`, call `[[MoPub sharedInstance] disableViewability:(vendors)]`. In place of “(vendors)”, `MPViewabilityOptionIAS` will disable IAS but leave Moat enabled, `MPViewabilityOptionMoat` will disable Moat but leave IAS enabled, and `MPViewabilityOptionAll` will disable all viewability measurement.

### Disclosure
MoPub v4.16 SDK integrates technology from our partners Integral Ad Science, Inc. (“IAS”) and Moat, Inc. (“Moat”) in order to support viewability measurement and other proprietary reporting that [IAS](https://integralads.com/capabilities/viewability/) and [Moat](https://moat.com/analytics) provide to their advertiser and publisher clients. You have the option to remove or disable this technology by following the opt-out instructions [above](#disableViewability).

If you do not remove or disable IAS's and/or Moat’s technology in accordance with these instructions, you agree that IAS's [privacy policy](https://integralads.com/privacy-policy/) and [license](https://integralads.com/sdk-license-agreement) and Moat’s [privacy policy](https://moat.com/privacy),  [terms](https://moat.com/terms), and [license](https://moat.com/sdklicense.txt), respectively, apply to your integration of these partners' technologies into your application.

## Version 4.15.0 (June 19th, 2017)
- **Bug Fixes**
  - Updated Facebook Audience Network banner and interstitial impression tracking
  - Allow taps to pass through the gradient overlays for rewarded videos

## Version 4.14.0 (May 10th, 2017)
- **Features**
  - For Rewarded ads, the client-side callback will now be invoked when using server-side rewarding.
  - Non-mediated interstitial, rewarded, and native ad placer ads will expire within 4 hours.

- **Bug Fixes**
  - Fix old custom events that use the wrong native renderer.
  - Replace usage of typeof with __typeof__ for C99 and C11 compliance.
  - Fix CFBridgingRetain casting bug.
  - Native ad impression tracker will now fire while scrolling.
  - Fix HTML click tracker to fire when using window.location and window.open.

## Version 4.13.1 (April 6th, 2017)
- **Bug Fixes**
  - Fixed compile error in the MoPub Base SDK Excluding Native bundle.

## Version 4.13.0 (March 23rd, 2017)
- **Features**
  - Added support for mediation of Google AdMob rewarded video demand (Google Mobile Ads SDK v7.19.0).
  - Google AdMob native ads mediation is now generally available (Google Mobile Ads SDK v7.19.0).
  - Updated the Tapjoy network mediation adapter to support Tapjoy SDK v11.10.0

- **Bug Fixes**
  - Introduced additional preventative measures to improve creative quality.

## Version 4.12.0 (February 9th, 2017)
- **Features**
  - Rewarded ad units now support rich media.
  - Allow MoPub static native renderer to render Flurry native ads.
  - Removed size limit for native ad main images.

- **Bug Fixes**
  - Native video selection logic now filters by supported MIME types.
  - Ad placer now supports section count.
  - Fix CFStringRef variable initialization.

## Version 4.11.1 (November 28th, 2016)
- **App Transport Security Updates**
	- Checks for "NSAllowsArbitraryLoadsInMedia" were changed to "NSAllowsArbitraryLoadsForMedia", per updated Apple documentation
	- Resolves issue in which explicitly using NSAllowsArbitraryLoadsForMedia or NSAllowsArbitraryLoadsInWebContent causes HTTP clickthroughs not to resolve on iOS 10.1 or higher

## Version 4.11.0 (November 10th, 2016)
- **The MoPub SDK now uses WKWebView to display ads when possible. Backwards compatibility for old OS versions is retained using UIWebView.**
- **Native video start tracker now fires immediately upon successful video playback.**
- **Bug fixes**
  - Native ads and native video ads now correctly fire impression trackers while scrolling.

## Version 4.10.1 (October 28th, 2016)
- **Bug fixes**
  - Fixed iOS 10 bug that causes SKStoreProductViewController to crash if the app does not list portrait as a supported orientation.

## Version 4.10.0 (October 18th, 2016)
- **Certified FAN 4.15.1**
- **Certified Chartboost 6.5.2**
- **Certified Yahoo 7.6.4**
- **Certified TapJoy support for 11.8.2**
- **Certified Millennial support for 6.3.1**
- **Certified Vungle 4.0.6**
- **Bug fixes**
  - Added support for the CocoaPods use_frameworks! directive

## Version 4.9.1 (September 14th, 2016)
- **iOS 10 compatibility updates**
	- Fixed an issue related to screen bounds calculation
- **Removed EventKit, EventKitUI frameworks and a few files related to EventKit and MRAID image downloader**
	- Please completely remove the MoPub SDK from your project and re-integrate this version to ensure that files are properly removed from your project

## Version 4.9.0 (September 1st, 2016)
- **Modular SDK - publishers can download the base or base excluding native SDK package**
- **Removed the full SDK bundle**
- **iOS 10 compatibility updates**
	- Rotating frequency capping ID for non-targeted ads under 'Limit Ad Tracking' setting
	- Removed save picture and save to calendar MRAID functionality
- **Removed iAd and InMobi adapters**
- **Added Cocoapods module name: "MoPub"**
- **Bug fixes**
  - Fixed an issue when multiple rewarded videos are loaded at the same time

## Version 4.8.0 (August 1st, 2016)
- **renamed MPError enums to avoid possible naming conflict with MediaPlayer framework errors**.

## Version 4.7.0 (June 2nd, 2016)
- **Rewarded video server-side currency rewarding (Beta)**.

## Version 4.6.0 (April 21th, 2016)
- **Certified Chartboost version 6.4.0**
- **Certified Tapjoy version 11.5.1**
- **Bug fixes**
	- Fixed resource loading issues when using cocoapods and frameworks

## Version 4.5.1 (April 4th, 2016)

- **bitcode support for MoPub Fabric Kit**

## Version 4.5 (March 24th, 2016)

- **Rewarded video support from the MoPub Marketplace (Beta)**
- **Bug fixes**
	- The SDK now correctly sends matched modal presented/dismissed callbacks on clickthrough

## Version 4.4 (February 17th, 2016)

- **Enabled SSL ad requests by default**
- **Bug fixes**
	- Fixed native video impression tracking
	- Made closeable hot spot consistent across all full-screen creative types


## Version 4.3 (December 15th, 2015)

- **Minor SDK improvements**.

## Version 4.2 (November 30th, 2015)

- **Upgraded Facebook SDK support to 4.8.0**.
	- Facebook Audience Network custom events for native and native video automatically display Facebook's AdChoices icon.
- **Added mediation support for Facebook video**.
- **Bug fixes**
    - Added mp prefix to common constants.
    - Fixed minor issue with video resuming during background to foreground transitions.
    - Fixed minor issue generating the 'mute' video status event.

## Version 4.1 (November 12th, 2015)

- **Added MoPub prefixes to constants and category methods**.
- **Certified Tapjoy 11.2.2**.
- **Certified Vungle 3.2.0**.

## Version 4.0 (October 6th, 2015)

- **Minimum supported iOS version is now 6.0**.
- **Updated native ad integration APIs**.
- **Improved native ad placer caching and request logic**.
- **Clicks are now automatically tracked for native ads that use the manual integration**.
- **Removed deprecated classes**.
  - Removed legacy custom event classes deprecated in 1.10.
  - Removed MPTableViewAdManager class deprecated in 3.0.

## Version 3.13 (September 17th, 2015)

- **Added iOS 9 support**.

## Version 3.12 (August 31st, 2015)

- **Added Privacy Information icon support for MoPub native ads**.
- **GA of rewarded video ad mediation**.
	- Added mediation support for AdColony, Chartboost, Vungle, and Unity rewarded video ads.

## Version 3.11 (August 20th, 2015)

- **Updated Millennial Media custom events (Millennial Media SDK 6.0+ only)**.

## Version 3.10 (August 3rd, 2015)

- **Minor improvements**.
- **Bug fixes**.
	- didDismissInterstitial is now called when the dismiss animation has completed.

## Version 3.9 (July 1st, 2015)

- **Added VAST 3.0 standard support for video ads**.
- **Improved video player UX**.
- **Improved error messages**.
- **Improved deep link handling**.
- **Bug fixes**.
	- Fixed clickthrough behavior for MRAID ads that use iframes.

## Version 3.8 (June 1st, 2015)

- **Minor improvements**.

## Version 3.7 (April 30th, 2015)

- **Added iAd medium rectangle ad support**.
- **Certified Google AdMob SDK version 7.1.0**.
- **Certified Greystripe SDK version 4.4.0**.
- **Certified Vungle SDK version 3.0.13**.
	- Added click callback support.
- **Bug fixes**.
	- Addressed a race condition when receiving location updates after calling -`[MPGeolocationProvider disableLocationUpdates:]`.

## Version 3.6 (April 3rd, 2015)

  - **Bug fixes**.
    - Fixed crash caused by some MRAID ads attempting to set an orientation that the app doesn't support.

## Version 3.5 (March 10th, 2015)

  - **Deprecated custom event class methods and constants for setting ad network parameters**.
  - **Changed banner minimum refresh time interval to 10 seconds**.
  - **Greystripe custom events now accept parameters configured using app.mopub.com**.

## Version 3.4 (January 30th, 2015)

  - **Certified Facebook SDK Version 3.21.1**.
  - **Bug fixes**.
    - Fixed MRAID force orientation command for MRAID interstitials.
    - Fixed interstitial bug where sound and video would continue to play after dismissal.

## Version 3.3 (December 8th, 2014)

  - **MRAID 2.0 support**. The MoPub SDK is now compliant with the MRAID 2.0 specification to enable rich media ads in banners and interstitial ad units. Learn more about MRAID from the [IAB](http://www.iab.net/MRAID#MRAID). To minimize integration errors, please completely remove the existing MoPub SDK from your project and then integrate the latest version.
  - **Automatic geolocation updates**. If your app already has location permissions, the MoPub SDK will automatically attempt to acquire location data for ad requests. Please use `locationUpdatesEnabled` in `MoPub.h` to opt out of this functionality. The MoPub SDK will never prompt the user for permission if location permissions are not currently granted.
  - **Added support for AdColony SDK 2.4.12**.
  - **Bug fixes**.
    - Fixed displaying previously cached Chartboost interstitials.
    - Fixed crash caused by refreshing Facebook banners after click.
    - Fixed iAd interstitial dismissed callback on iOS 8
    - Fixed HTML interstitial duplicate click trackers

## Version 3.2 (October 17th, 2014)

  - **We have launched a new license as of version 3.2.0.** To view the full license, visit [http://www.mopub.com/legal/sdk-license-agreement/](http://www.mopub.com/legal/sdk-license-agreement/)

## Version 3.1 (October 9th, 2014)

  - Updated native mediation framework to support Facebook Audience Network SDK 3.18.2
    - If you're directly using `MPNativeAd`, you should implement the `MPNativeAdDelegate` protocol found in `MPNativeAdDelegate.h` and set the delegate property on your `MPNativeAd` instance.
  - Added convenience methods to `MPTableViewAdPlacer` and `MPCollectionViewAdPlacer` that default to using server-controlled native ad positioning
    - `+ (instancetype)placerWithTableView:viewController:defaultAdRenderingClass:(Class)defaultAdRenderingClass;`
    - `+ (instancetype)placerWithCollectionView:viewController:defaultAdRenderingClass:(Class)defaultAdRenderingClass;`
  - Fixed compiler error in `MPDiskLRUCache.m` if `OS_OBJECT_USE_OBJC` is false

## Version 3.0 (September 30th, 2014)

  - **The MoPub SDK now uses Automatic Reference Counting**
  - **Swift support:** to use the MoPub SDK in your Swift project, simply import `MoPubSDK/MoPub-Bridging-Header.h` to your project and ensure the Objective-C Bridging Header build setting under Swift Compiler - Code Generation has a path to the header.
  - Updated Chartboost custom event (Chartboost SDK 5.0.1)
  - Bug fixes
    - mraid.js will reject mraid calls until the SDK signals it is ready
    - banner ads will pause autorefresh when the app enters the background and resume autorefresh when the app enters the foreground

### IMPORTANT UPGRADE INSTRUCTIONS

As of version 3.0.0, the MoPub SDK uses Automatic Reference Counting. If you're upgrading from an earlier version (2.4.0 or earlier) that uses Manual Reference Counting, in order to minimize integration errors with the manual removal of the `-fno-objc-arc` compiler flag, our recommendation is to completely remove the existing MoPub SDK from your project and then integrate the latest version. Alternatively, you can manually remove the `-fno-objc-arc` compiler flag from all MoPub SDK files. If your project uses Manual Reference Counting, you must add the `-fobjc-arc` compiler flag to all MoPub SDK files.

## Version 2.4 (August 28th, 2014)

  - **Simplified native ads integration**: integration instructions and documentation are available on the [GitHub wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Native-Ads-Integration)
  - Updated Vungle custom event (Vungle SDK 3.0.8)
  - Optional method `- (void)interstitialDidReceiveTapEvent:` added to `MPInterstitialAdControllerDelegate`
  - Hardened native ad custom events against invalid image URLs

## Version 2.3 (July 17th, 2014)

  - MoPub base SDK is now 64-bit compatible (Please check mediated networks for 64-bit support)
  - Certified support for InMobi 4.4.1, Greystripe/Conversant 4.3, and AdMob 6.9.3
  - Additional measures to prevent autoloading deep-links without user interaction for banners
  - Bug fixes
    - A cached Millennial Media interstitial will be correctly loaded
    - Fixed crash if the close button is quickly tapped after tapping an MRAID interstitial

## Version 2.2 (June 19th, 2014)

  - **Native ads mediation**: integration instructions and documentation are available on the [GitHub wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Integrating-Native-Third-Party-Ad-Networks). Facebook and InMobi native ads may be mediated using the MoPub SDK.
  - **Native ads content filtering**: Added the ability to specify which native ad elements you want to receive from the MoPub Marketplace to optimize bandwidth use and download only required assets, via `MPNativeAdRequestTargeting.desiredAssets`. This feature only works for the six standard Marketplace assets, found in `MPNativeAdConstants.h`. Any additional elements added in direct sold ads will always be sent down in the extras.
  - Added star rating information to the `MPNativeAd` object, via `MPNativeAd.starRating`. This method returns an `NSNumber` (double value) corresponding to an app's rating on a 5-star scale.
  - Bug fixes
    - Handle Millennial Media SDK's `MillennialMediaAdWillTerminateApplication` notification
    - Ensured that banners never autorefresh until they have been loaded at least once

## Version 2.1 (May 15th, 2014)

  - Improved user privacy protection
    - Device identifiers are removed from logging output
  - Improved user protection against auto-dialing ads
    - Prompt user for confirmation when a `tel` URL is encountered
  - Updated Millennial Media custom events (Millennial Media SDK 5.2+ only)
  - Updated Vungle custom event (Vungle SDK 2.0+ only)

### Version 2.1.1 (May 22nd, 2014)

  - Fixed Millennial Media SDK 5.2 banner custom event failover

## Version 2.0 (April 23rd, 2014)

  - Added support for MoPub Native Ads. Please view the integration wiki [here](https://github.com/mopub/mopub-ios-sdk/wiki/Native-Ads-Integration).
  - Updated the minimum required iOS version to iOS 5.0
    - Removed `TouchJSON` dependency. `TouchJSON` files may be removed from your project.

## Version 1.17 (November 20, 2013)

  - AdColony Custom Event
    - Supports AdColony as a custom native ad network for interstitial videos. Note that V4VC (virtual currency reward) is currently not supported.
  - Handle ISO Latin-1 site encoding in addition to UTF-8
  - Bug fixes

### Version 1.17.3.0 (March 20th, 2014)

  - Updated Chartboost custom event (Chartboost SDK 4.0+ only)
  - Bug fixes
    - Fixed iOS 7 bug where certain interstitial images may fail to load

### Version 1.17.2.0 (February 20th, 2014)

  - Updated InMobi custom events (InMobi SDK 4.0.3+ only)
  - Bug fixes
    - MRAID viewable property now correctly updates on app background and resume
    - MRAID command urls are no longer re-encoded for processing

### Version 1.17.1.0 (January 23rd, 2014)

  - Sample app improvements
    - Improved manual ad unit entry view
    - Save manually entered ad unit ids
    - Ability to enter keywords for each ad unit
  - Bug fixes
    - MRAID `isViewable` command now correctly returns a boolean value

## Version 1.16 (October 15, 2013)

  - Creative Controls
    - Creative Flagging
      - **Important**: ```MPAdAlertGestureRecognizer``` and ```MPAdAlertManager``` classes as well as ```MessageUI.framework``` must be added to your project to enable flagging functionality.
      - Allows users to report certain inappropriate ad experiences directly to MoPub with a special gesture.
      - User must swipe back and forth at least four times within the ad view to flag a creative.
      - Swipes must cover more than ⅓ of the ad width and must be completely horizontal.
      - Only works for direct sold, Marketplace, and server to server ad network ads.
    - Blocked Popups
      - Javascript alert, confirm, and prompt dialogs are blocked.
    - Blocked Auto-redirects
      - Ads that automatically redirect users to another page without user interaction are automatically blocked.
  - MoPub Video Pre-caching
    - Video ads from the Marketplace will be pre-cached automatically and videos will not be shown until they can play without additional buffering.
  - Simple Ads Demo Improvements
    - 300x250 and 728x90 test spots added to the demo app.
  - Vungle Custom Event
    - Supports Vungle as a custom native ad network for interstitial videos.
  - SKStoreProductViewController iOS 7 Orientation Crash Fix
    - Fixes iOS 7 bug that causes SKStoreProductViewController to crash if the app does not list portrait as a supported orientation.
  - Log more readable message in response to the "no ads available" server error.
  - Updated mraid.getVersion() to return 2.0

### Version 1.16.0.1 (October 24, 2013)

  - MRAID commands now properly handle encoded URLs.

## Version 1.14 (September 12, 2013)

  - iOS 7 Gold Master support
  - Verified compatibility with latest Millennial iOS SDK (5.1.1)
  - Updated support for InMobi SDK version 4.0
  - Bug fixes

#### Updates to InMobi Integrations
  - **Important**: As of version 1.14.0.0, the InMobi custom events packaged with the MoPub SDK only support InMobi version 4.00 and up. Follow the instructions [here](http://www.inmobi.com/support/art/25856216/22465648/integrating-mopub-with-inmobi-ios-sdk-4-0/) to integrate InMobi version 4.00 and up. If you would like to continue to use a prior version of the InMobi SDK, do not update the custom event files and follow the instructions [here](http://developer.inmobi.com/wiki/index.php?title=MoPub_InMobi_iOS) to integrate.

### Version 1.14.1.0 (September 18, 2013)
  - Fixed an issue causing certain interstitials to be incorrectly centered or sized
  - Updated the SDK bundle to include the Millennial Media 5.1.1 SDK

## Version 1.13 (August 22, 2013)

  - Added support for creating calendar events, storing pictures, and video playback via MRAID APIs
  - Fixed a rendering issue with HTML interstitials on iOS 5
  - Fixed crashes resulting from delegate callbacks being executed on deallocated objects

## Version 1.12 (April 25, 2013)

#### Updates to Third Party Integrations
  - Third-party ad network integrations are **now implemented as custom events instead of adapters**.

    > **Please remove any old adapters from your code and use the new custom events located in the `AdNetworkSupport` folder instead.**

  - Added support for Millennial SDK 5.0
  - Updated Chartboost integration to honor the location parameter (configurable via the server)
  - Updated Custom Events API.

    > **If you have implemented a Custom Event, please read the Custom Events [documentation](https://github.com/mopub/mopub-ios-sdk/wiki/Custom-Events) and update your code appropriately.**

#### Updates to the MoPub SDK
  - The MoPub SDK now requires **iOS 4.3+**
  - Removed all references to `[UIDevice uniqueIdentifier]`
  - Added support for opening iTunes links in an `SKStoreProductViewController`
  - Added [session tracking](https://github.com/mopub/mopub-ios-sdk/wiki/Conversion-Tracking#session-tracking)
  - Added numerous data signals (wireless connectivity, location accuracy, bundle version, telephony information) to ad requests
  - Added test coverage to MoPub SDK

#### Distribution and Documentation Updates
  - Added .zip archive distribution options with bundled third party network SDKs.  Learn more at the updated [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started).
  - Added appledoc style [Class Documentation](https://github.com/mopub/mopub-ios-sdk/tree/master/ClassDocumentation)
  - Updated the MoPub Sample Application

### Version 1.12.5.0 (August 1, 2013)
  - Updated to support Millennial SDK 5.1.0
  - Fixed warnings resulting from duplicate category methods
  - Fixed a crash occurring when an interstitial was tapped and dismissed immediately afterwards

### Version 1.12.4.0 (June 26, 2013)
  - Fixed a memory leak when displaying MRAID ads

### Version 1.12.3.0 (June 18, 2013)
  - Fixed inconsistency between ad request user agent and click-handling user agent
  - Fixed crashes that occur when banners are deallocated in the process of displaying modal content

### Version 1.12.2.0 (June 7, 2013)
  - Fixed issue causing expanded MRAID banner ads to obscure modal content
  - Fixed issue in which impressions were not tracked properly for MRAID banner ads
  - Added new API methods on `MPAdView` for managing ad refresh behavior (`-startAutomaticallyRefreshingContents` and `-stopAutomaticallyRefreshingContents`)
  - Deprecated `ignoresAutorefresh` property on `MPAdView`

### Version 1.12.1.0 (May 13, 2013)
  - Fixed issue causing banners from custom HTML networks to be improperly sized
  - Updated the SDK bundle to include the Millennial Media 5.0.1 SDK

### Version 1.12.0.1 (April 26, 2013)
  - Fixed some leaks reported by the static analyzer

## Version 1.11 (March 13, 2013)
  - Fixed issue causing a crash for legacy custom event methods
  - Fixed issue causing refresh timer to not be scheduled properly on connection errors
  - Updated the sample Chartboost custom event to avoid improperly setting the Chartboost delegate to nil in -dealloc

## Version 1.10 (February 13, 2013)
  - Introduced custom event classes
  - Fixed issue causing metrics-recording URLs to be incorrect when certain ad sources fail
  - Fixed issue causing interstitials to be sized incorrectly when the status bar changes state
  - Fixed issue preventing loading indicator from being dismissed properly for HTML interstitials
  - Fixed issue that allows the browser controller to continue loading after it has been dismissed
  - Added 'testing' property on `MPAdView` and `MPInterstitialAdController`
  - Increased accuracy of iAd impression tracking

## Version 1.9.0.0 (September 27, 2012)
  - Added support for iOS 6 and the new iPhone 5 screen size
  - Added support for the Facebook ads test program
  - Added support for `ASIdentifierManager` (`UIDevice.identifierForAdvertising` replacement)
  - Re-introduced UDID as a fall-back identifier on earlier iOS ## Versions (with an opt-out mechanism)
  - Fixed issues with redirecting certain native iOS URLs (e.g. itunes.apple.com) in the in-app browser
  - Fixed an issue in which an interstitial might not dismiss properly when leaving an app via a click
  - Updated the SimpleAdsDemo sample app for iOS 6
  - Added clarity to certain console log entries
  - Added some minor visual improvements to the click progress indicator

## Version 1.8.0.0
  - Fixed a crash in `MPAdManager` due to uncanceled NSURLConnections
  - Fixed an issue with mraid://open URL decoding
  - Fixed an issue in which third-party interstitials could block the display of subsequent HTML interstitials
  - Fixed an issue in which third-party interstitials could trigger lifecycle callbacks after expiration
  - Added iOS 6 view controller auto-rotation methods to `MPInterstitialAdController`
  - Added support for iOS 6 advertising identifier
  - Removed references to `-[UIDevice uniqueIdentifier]` and OpenUDID
  - Added runtime checks for `CALayer` and `UIActionSheet` selectors to prevent crashes on iOS 3.1
  - Improved the Millennial interstitial adapter to handle all return values from `-checkForCachedAd`

## Version 1.7.0.0
  - Improved click experience to avoid blank screens when loading pages with many redirects
  - Fixed an issue in which `MPAdView` would implicitly change its 'hidden' property
  - Fixed an issue in which the in-app browser failed to dismiss properly upon `-[UIApplication openURL:]`
  - Fixed issues in which the `MRAID.isViewable` method would erroneously return true
  - Fixed a divide-by-zero exception which occurred when presenting MRAID interstitials

## Version 1.6.0.0
  - Added new API method for displaying an interstitial (`-showFromViewController:`)
  - Added new delegate property on `MPInterstitialAdController`
  - Deprecated old API method for displaying an interstitial (`-show:`)
  - Deprecated parent property on `MPInterstitialAdController`
  - Deprecated various callbacks in `MPInterstitialAdControllerDelegate`

## Version 1.5.0.0
  - Added support for Millennial Media SDK 4.5.5
  - Modified Millennial Media interstitial adapter to be more robust to ad display failures

## Version 1.4.0.0
  - Reduced the amount of logging messages regarding autorefresh
  - Modified JSON deserializer to avoid getting NSNull objects
  - Fixed issue in which interstitials could appear blank upon repeated show: calls
  - Removed call to deprecated `SKMutablePayment` class method
  - Added APIs for enabling and disabling the in-app purchase transaction observer
  - Fixed a memory leak in `MPInterstitialAdController`
  - Added support for OpenUDID as a optional replacement for `UIDevice's -uniqueIdentifier`

## Version 1.2.0.0
  - Fixed a bug in which landscape interstitials appeared off-center on iOS 5.0+
  - Fixed some static analyzer warnings in `MPAdManager` and `MPAdBrowserController`
  - Fixed a memory leak in `MPAdConversionTracker`
  - Changed '\*\*\*CLEAR\*\*\*' message to 'No ad available' for clarity
  - Added support for Millennial Media leaderboard ads
  - Changed behavior of `-setIgnoresAutorefresh:` to pause (rather than cancel) existing timers
  - Added support for interstitial custom events

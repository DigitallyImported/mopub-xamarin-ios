This repository is used to create the mopub xamarin bindings for iOS. It currently has support for iAd and GoogleAdMob banner ads and Vungle, AdColony, and Facebook video ads.

Version info:
* MoPub version 4.6 [github](https://github.com/mopub/mopub-ios-sdk)
* iAd - built into iOS
* GoogleAdMob version 7.1.0
* Vungle version 3.2.0 [website](https://v.vungle.com/sdk)
* AdColony version 2.6.1 [github](https://github.com/AdColony/AdColony-iOS-SDK)
* Facebook Audience Network 4.13.1 [website](https://developers.facebook.com/docs/ios)

To use MoPub in your project, follow these directions:

1. Within Terminal, navigate to the mopub-framework folder
2. Run 'bash universal-framework.sh' in that directory
3. Open mopub-ios-binding/mopub-ios-binding.sln in Xamarin
4. Rebuild that solution.
5. Copy the resulting bin/<BuildType>/MoPubSDK.dll to your own Xamarin project.
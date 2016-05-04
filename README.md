This repository is used to create the mopub xamarin bindings for iOS. It currently has support for iAd and GoogleAdMob banner ads.

We are currently using the 4.6 version of MoPub found [here](https://github.com/mopub/mopub-ios-sdk).

To use MoPub in your project, follow these directions:

1. Within Terminal, navigate to the mopub-framework folder
2. Run 'bash universal-framework.sh' in that directory
3. Open mopub-ios-binding/mopub-ios-binding.sln in Xamarin
4. Rebuild that solution.
5. Copy the resulting bin/<BuildType>/MoPubSDK.dll to your own Xamarin project.
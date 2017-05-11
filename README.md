This repository is used to create the mopub xamarin bindings for iOS. It currently has support for GoogleAdMob banner ads and Vungle, AdColony, and Facebook video ads.

Version info:
* MoPub version 4.14.0 [github](https://github.com/mopub/mopub-ios-sdk)
* GoogleAdMob version 7.20.0 [googleAdMob](https://firebase.google.com/docs/admob/ios/download)
* Vungle version 4.1.0 [website](https://v.vungle.com/sdk)
* AdColony version 3.1.1 [github](https://github.com/AdColony/AdColony-iOS-SDK-3)
* Facebook Audience Network 4.22.0 [website](https://developers.facebook.com/docs/ios)

The MoPub folder contains 2 sub projects: one is Xcode project for building the MoPub framework which is then used in the
second subproject which is a binding into the C# .dll library. The Xcode project is setup to build framework and uses MopubSDK 
provided by third party. Also Mopub supports other ads providers that are interacted via plugins. Taking into acount this 
structure the update process will consist of the following steps:

1. Open Xcode project and remove old MoPubSDK folder
2. Drag updated version of MoPubSDK into your Xcode project (native version of mopub doesn't contain AdNetworks support.
In order to get that one should download the AdNetworksSupport from Mopub github - that could be done for example by 
fetching zip version of mopub repositorium from github)
3. Add appropriate (updated) ad networks SDKs in corresponding folders of AdNetwoksSupport subfolders.
4. Drag AdNetwoksSupport folder into the MoPubSDK folder of your Xcode project.
5. Make sure Xcode project is built without errors.
6. Within Terminal, navigate to the mopub-framework folder
7. Run 'bash universal-frameworks.sh' in that directory
8. Open mopub-ios-binding/mopub-ios-binding.sln in Xamarin/VisualStudio
9. Rebuild that solution.
10. Copy the resulting bin/<BuildType>/MoPubSDK.dll to your own Xamarin/VisualStudio project.

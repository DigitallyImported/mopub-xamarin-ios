This repository is used to create the mopub xamarin bindings for iOS. It currently has support for GoogleAdMob, Facebook banner ads and Vungle and Facebook video (interstitial) ads.

Version info:
* MoPub version 5.8.0 [github](https://github.com/mopub/mopub-ios-sdk)
* GoogleAdMob version 7.39.0 [googleAdMob](https://firebase.google.com/docs/admob/ios/download)
* Vungle version 6.3.2 [website](https://v.vungle.com/sdk)
* Facebook Audience Network 5.2.0.0 [website](https://developers.facebook.com/docs/ios)

The MoPub folder contains 2 sub projects: one is Xcode project for building the MoPub framework which is then used in the second subproject which is a binding into the C# .dll library. The Xcode project is setup to build framework and uses MopubSDK source code provided by Mopub. Also Mopub supports other ads providers that are interacted via plugins and require corresponding SDK frameworks being downloaded from the providers and copied into the Mopab Xcode project. Taking into acount this structure the update process will consist of the following steps:

1. Open Xcode project and remove old MoPubSDK folder
2. Drag updated version of MoPubSDK into your Xcode project
3. From a [separate repository](https://github.com/mopub/mopub-ios-mediation) fetch corresponding folders with the required ad adapters and drag the appropriate whole folders into the root of Mopub Xcode project so they are at the same level with MoPubSDK and MoPub subfolders
4. Add appropriate (updated) ad networks SDKs in corresponding (just added) folders.
5. Make sure Xcode project is built without errors.
6. Within Terminal, navigate to the mopub-framework folder
7. Run 'bash universal-frameworks.sh' in that directory (that builds a fat library)
8. Open mopub-ios-binding/mopub-ios-binding.sln in VisualStudio - rework the binding methods and enums
9. Rebuild that solution.
10. Copy the resulting bin/<BuildType>/MoPubSDK.dll to your own VisualStudio project.

Keep in mind:
- that the built MoPub framework contains the other providers SDKs inside.
- when MoPub framework is added into the Xamarin binding project the framework link is added under Native References.
- the settings of linked frameworks and weak frameworks are filled in the properties of the framework when it is selected under Native References.
- the file Mopub.framework.linkwith.cs IS NOT USED and is only left for reference to have a list of the required frameworks at hand (the build action for that file is None).
- ApiDefinitions.cs and StructsAndEnums.cs only contains code of the used API calls and in case some other methods or properties are needed one may need to extend the binding with those additional methods, properties or enums.

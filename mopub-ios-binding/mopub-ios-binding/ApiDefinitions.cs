using System;
using CoreGraphics;
using CoreLocation;
using Foundation;
using ObjCRuntime;
using UIKit;

namespace MoPubSDK
{
    // @interface MPAdConversionTracker : NSObject <NSURLConnectionDataDelegate>
    [BaseType (typeof(NSObject))]
    interface MPAdConversionTracker : INSUrlConnectionDataDelegate
    {
        // +(MPAdConversionTracker *)sharedConversionTracker;
        [Static]
        [Export ("sharedConversionTracker")]
        MPAdConversionTracker SharedConversionTracker { get; }

        // -(void)reportApplicationOpenForApplicationID:(NSString *)appID;
        [Export ("reportApplicationOpenForApplicationID:")]
        void ReportApplicationOpenForApplicationID (string appID);
    }

    // @interface MPAdView : UIView
    [BaseType (typeof(UIView))]
    interface MPAdView
    {
        // -(id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size;
        [Export ("initWithAdUnitId:size:")]
        IntPtr Constructor (string adUnitId, CGSize size);

        [Wrap ("WeakDelegate")]
        [NullAllowed]
        MPAdViewDelegate Delegate { get; set; }

        // @property (nonatomic, weak) id<MPAdViewDelegate> _Nullable delegate;
        [NullAllowed, Export ("delegate", ArgumentSemantic.Weak)]
        NSObject WeakDelegate { get; set; }

        // @property (copy, nonatomic) NSString * adUnitId;
        [Export ("adUnitId")]
        string AdUnitId { get; set; }

        // @property (copy, nonatomic) NSString * keywords;
        [Export ("keywords")]
        string Keywords { get; set; }

        // @property (copy, nonatomic) CLLocation * location;
        [Export ("location", ArgumentSemantic.Copy)]
        CLLocation Location { get; set; }

        // @property (getter = isTesting, assign, nonatomic) BOOL testing;
        [Export ("testing")]
        bool Testing { [Bind ("isTesting")] get; set; }

        // -(void)loadAd;
        [Export ("loadAd")]
        void LoadAd ();

        // -(void)forceRefreshAd;
        [Export ("forceRefreshAd")]
        void ForceRefreshAd ();

        // -(void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;
        [Export ("rotateToOrientation:")]
        void RotateToOrientation (UIInterfaceOrientation newOrientation);

        // -(void)lockNativeAdsToOrientation:(MPNativeAdOrientation)orientation;
        [Export ("lockNativeAdsToOrientation:")]
        void LockNativeAdsToOrientation (MPNativeAdOrientation orientation);

        // -(void)unlockNativeAdsOrientation;
        [Export ("unlockNativeAdsOrientation")]
        void UnlockNativeAdsOrientation ();

        // -(MPNativeAdOrientation)allowedNativeAdsOrientation;
        [Export ("allowedNativeAdsOrientation")]
        MPNativeAdOrientation AllowedNativeAdsOrientation { get; }

        // -(CGSize)adContentViewSize;
        [Export ("adContentViewSize")]
        CGSize AdContentViewSize { get; }

        // -(void)stopAutomaticallyRefreshingContents;
        [Export ("stopAutomaticallyRefreshingContents")]
        void StopAutomaticallyRefreshingContents ();

        // -(void)startAutomaticallyRefreshingContents;
        [Export ("startAutomaticallyRefreshingContents")]
        void StartAutomaticallyRefreshingContents ();
    }

    // @protocol MPAdViewDelegate <NSObject>
    [Protocol, Model]
    [BaseType (typeof(NSObject))]
    interface MPAdViewDelegate
    {
        // @required -(UIViewController *)viewControllerForPresentingModalView;
        [Abstract]
        [Export ("viewControllerForPresentingModalView")]
        UIViewController ViewControllerForPresentingModalView { get; }

        // @optional -(void)adViewDidLoadAd:(MPAdView *)view;
        [Export ("adViewDidLoadAd:")]
        void AdViewDidLoadAd (MPAdView view);

        // @optional -(void)adViewDidFailToLoadAd:(MPAdView *)view;
        [Export ("adViewDidFailToLoadAd:")]
        void AdViewDidFailToLoadAd (MPAdView view);

        // @optional -(void)willPresentModalViewForAd:(MPAdView *)view;
        [Export ("willPresentModalViewForAd:")]
        void WillPresentModalViewForAd (MPAdView view);

        // @optional -(void)didDismissModalViewForAd:(MPAdView *)view;
        [Export ("didDismissModalViewForAd:")]
        void DidDismissModalViewForAd (MPAdView view);

        // @optional -(void)willLeaveApplicationFromAd:(MPAdView *)view;
        [Export ("willLeaveApplicationFromAd:")]
        void WillLeaveApplicationFromAd (MPAdView view);
    }

    // @protocol MPBannerCustomEventDelegate <NSObject>
    [Protocol, Model]
    [BaseType (typeof(NSObject))]
    interface MPBannerCustomEventDelegate
    {
        // @required -(UIViewController *)viewControllerForPresentingModalView;
        [Abstract]
        [Export ("viewControllerForPresentingModalView")]
        UIViewController ViewControllerForPresentingModalView { get; }

        // @required -(CLLocation *)location;
        [Abstract]
        [Export ("location")]
        CLLocation Location { get; }

        // @required -(void)bannerCustomEvent:(MPBannerCustomEvent *)event didLoadAd:(UIView *)ad;
        [Abstract]
        [Export ("bannerCustomEvent:didLoadAd:")]
        void BannerCustomEvent (MPBannerCustomEvent @event, UIView ad);

        // @required -(void)bannerCustomEvent:(MPBannerCustomEvent *)event didFailToLoadAdWithError:(NSError *)error;
        [Abstract]
        [Export ("bannerCustomEvent:didFailToLoadAdWithError:")]
        void BannerCustomEvent (MPBannerCustomEvent @event, NSError error);

        // @required -(void)bannerCustomEventWillBeginAction:(MPBannerCustomEvent *)event;
        [Abstract]
        [Export ("bannerCustomEventWillBeginAction:")]
        void BannerCustomEventWillBeginAction (MPBannerCustomEvent @event);

        // @required -(void)bannerCustomEventDidFinishAction:(MPBannerCustomEvent *)event;
        [Abstract]
        [Export ("bannerCustomEventDidFinishAction:")]
        void BannerCustomEventDidFinishAction (MPBannerCustomEvent @event);

        // @required -(void)bannerCustomEventWillLeaveApplication:(MPBannerCustomEvent *)event;
        [Abstract]
        [Export ("bannerCustomEventWillLeaveApplication:")]
        void BannerCustomEventWillLeaveApplication (MPBannerCustomEvent @event);

        // @required -(void)trackImpression;
        [Abstract]
        [Export ("trackImpression")]
        void TrackImpression ();

        // @required -(void)trackClick;
        [Abstract]
        [Export ("trackClick")]
        void TrackClick ();
    }

    // @interface MPBannerCustomEvent : NSObject
    [BaseType (typeof(NSObject))]
    interface MPBannerCustomEvent
    {
        // -(void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info;
        [Export ("requestAdWithSize:customEventInfo:")]
        void RequestAdWithSize (CGSize size, NSDictionary info);

        // -(void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;
        [Export ("rotateToOrientation:")]
        void RotateToOrientation (UIInterfaceOrientation newOrientation);

        // -(void)didDisplayAd;
        [Export ("didDisplayAd")]
        void DidDisplayAd ();

        // -(BOOL)enableAutomaticImpressionAndClickTracking;
        [Export ("enableAutomaticImpressionAndClickTracking")]
        bool EnableAutomaticImpressionAndClickTracking ();

        [Wrap ("WeakDelegate")]
        [NullAllowed]
        MPBannerCustomEventDelegate Delegate { get; set; }

        // @property (nonatomic, weak) id<MPBannerCustomEventDelegate> _Nullable delegate;
        [NullAllowed, Export ("delegate", ArgumentSemantic.Weak)]
        NSObject WeakDelegate { get; set; }
    }

    // @interface MPInterstitialAdController : UIViewController
    [BaseType (typeof(UIViewController))]
    interface MPInterstitialAdController
    {
        // +(MPInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)adUnitId;
        [Static]
        [Export ("interstitialAdControllerForAdUnitId:")]
        MPInterstitialAdController InterstitialAdControllerForAdUnitId (string adUnitId);

        [Wrap ("WeakDelegate")]
        [NullAllowed]
        MPInterstitialAdControllerDelegate Delegate { get; set; }

        // @property (nonatomic, weak) id<MPInterstitialAdControllerDelegate> _Nullable delegate;
        [NullAllowed, Export ("delegate", ArgumentSemantic.Weak)]
        NSObject WeakDelegate { get; set; }

        // @property (copy, nonatomic) NSString * adUnitId;
        [Export ("adUnitId")]
        string AdUnitId { get; set; }

        // @property (copy, nonatomic) NSString * keywords;
        [Export ("keywords")]
        string Keywords { get; set; }

        // @property (copy, nonatomic) CLLocation * location;
        [Export ("location", ArgumentSemantic.Copy)]
        CLLocation Location { get; set; }

        // @property (getter = isTesting, assign, nonatomic) BOOL testing;
        [Export ("testing")]
        bool Testing { [Bind ("isTesting")] get; set; }

        // -(void)loadAd;
        [Export ("loadAd")]
        void LoadAd ();

        // @property (readonly, assign, nonatomic) BOOL ready;
        [Export ("ready")]
        bool Ready { get; }

        // -(void)showFromViewController:(UIViewController *)controller;
        [Export ("showFromViewController:")]
        void ShowFromViewController (UIViewController controller);

        // +(void)removeSharedInterstitialAdController:(MPInterstitialAdController *)controller;
        [Static]
        [Export ("removeSharedInterstitialAdController:")]
        void RemoveSharedInterstitialAdController (MPInterstitialAdController controller);

        // +(NSMutableArray *)sharedInterstitialAdControllers;
        [Static]
        [Export ("sharedInterstitialAdControllers")]
        NSMutableArray SharedInterstitialAdControllers { get; }
    }

    // @protocol MPInterstitialAdControllerDelegate <NSObject>
    [Protocol, Model]
    [BaseType (typeof(NSObject))]
    interface MPInterstitialAdControllerDelegate
    {
        // @optional -(void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialDidLoadAd:")]
        void InterstitialDidLoadAd (MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialDidFailToLoadAd:")]
        void InterstitialDidFailToLoadAd (MPInterstitialAdController interstitial);

        // @optional -(void)interstitialWillAppear:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialWillAppear:")]
        void InterstitialWillAppear (MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidAppear:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialDidAppear:")]
        void InterstitialDidAppear (MPInterstitialAdController interstitial);

        // @optional -(void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialWillDisappear:")]
        void InterstitialWillDisappear (MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialDidDisappear:")]
        void InterstitialDidDisappear (MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidExpire:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialDidExpire:")]
        void InterstitialDidExpire (MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial;
        [Export ("interstitialDidReceiveTapEvent:")]
        void InterstitialDidReceiveTapEvent (MPInterstitialAdController interstitial);
    }

    // @protocol MPInterstitialCustomEventDelegate <NSObject>
    [Protocol, Model]
    [BaseType (typeof(NSObject))]
    interface MPInterstitialCustomEventDelegate
    {
        // @required -(CLLocation *)location;
        [Abstract]
        [Export ("location")]
        CLLocation Location { get; }

        // @required -(void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent didLoadAd:(id)ad;
        [Abstract]
        [Export ("interstitialCustomEvent:didLoadAd:")]
        void InterstitialCustomEvent (MPInterstitialCustomEvent customEvent, NSObject ad);

        // @required -(void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent didFailToLoadAdWithError:(NSError *)error;
        [Abstract]
        [Export ("interstitialCustomEvent:didFailToLoadAdWithError:")]
        void InterstitialCustomEvent (MPInterstitialCustomEvent customEvent, NSError error);

        // @required -(void)interstitialCustomEventDidExpire:(MPInterstitialCustomEvent *)customEvent;
        [Abstract]
        [Export ("interstitialCustomEventDidExpire:")]
        void InterstitialCustomEventDidExpire (MPInterstitialCustomEvent customEvent);

        // @required -(void)interstitialCustomEventWillAppear:(MPInterstitialCustomEvent *)customEvent;
        [Abstract]
        [Export ("interstitialCustomEventWillAppear:")]
        void InterstitialCustomEventWillAppear (MPInterstitialCustomEvent customEvent);

        // @required -(void)interstitialCustomEventDidAppear:(MPInterstitialCustomEvent *)customEvent;
        [Abstract]
        [Export ("interstitialCustomEventDidAppear:")]
        void InterstitialCustomEventDidAppear (MPInterstitialCustomEvent customEvent);

        // @required -(void)interstitialCustomEventWillDisappear:(MPInterstitialCustomEvent *)customEvent;
        [Abstract]
        [Export ("interstitialCustomEventWillDisappear:")]
        void InterstitialCustomEventWillDisappear (MPInterstitialCustomEvent customEvent);

        // @required -(void)interstitialCustomEventDidDisappear:(MPInterstitialCustomEvent *)customEvent;
        [Abstract]
        [Export ("interstitialCustomEventDidDisappear:")]
        void InterstitialCustomEventDidDisappear (MPInterstitialCustomEvent customEvent);

        // @required -(void)interstitialCustomEventDidReceiveTapEvent:(MPInterstitialCustomEvent *)customEvent;
        [Abstract]
        [Export ("interstitialCustomEventDidReceiveTapEvent:")]
        void InterstitialCustomEventDidReceiveTapEvent (MPInterstitialCustomEvent customEvent);

        // @required -(void)interstitialCustomEventWillLeaveApplication:(MPInterstitialCustomEvent *)customEvent;
        [Abstract]
        [Export ("interstitialCustomEventWillLeaveApplication:")]
        void InterstitialCustomEventWillLeaveApplication (MPInterstitialCustomEvent customEvent);

        // @required -(void)trackImpression;
        [Abstract]
        [Export ("trackImpression")]
        void TrackImpression ();

        // @required -(void)trackClick;
        [Abstract]
        [Export ("trackClick")]
        void TrackClick ();
    }

    // @interface MPInterstitialCustomEvent : NSObject
    [BaseType (typeof(NSObject))]
    interface MPInterstitialCustomEvent
    {
        // -(void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info;
        [Export ("requestInterstitialWithCustomEventInfo:")]
        void RequestInterstitialWithCustomEventInfo (NSDictionary info);

        // -(void)showInterstitialFromRootViewController:(UIViewController *)rootViewController;
        [Export ("showInterstitialFromRootViewController:")]
        void ShowInterstitialFromRootViewController (UIViewController rootViewController);

        // -(BOOL)enableAutomaticImpressionAndClickTracking;
        [Export ("enableAutomaticImpressionAndClickTracking")]
        bool EnableAutomaticImpressionAndClickTracking ();

        [Wrap ("WeakDelegate")]
        [NullAllowed]
        MPInterstitialCustomEventDelegate Delegate { get; set; }

        // @property (nonatomic, weak) id<MPInterstitialCustomEventDelegate> _Nullable delegate;
        [NullAllowed, Export ("delegate", ArgumentSemantic.Weak)]
        NSObject WeakDelegate { get; set; }
    }

    // @interface MoPub : NSObject
    [BaseType (typeof(NSObject))]
    interface MoPub
    {
        // +(MoPub *)sharedInstance;
        [Static]
        [Export ("sharedInstance")]
        MoPub SharedInstance { get; }

        // @property (assign, nonatomic) BOOL locationUpdatesEnabled;
        [Export ("locationUpdatesEnabled")]
        bool LocationUpdatesEnabled { get; set; }

        // -(void)initializeRewardedVideoWithGlobalMediationSettings:(NSArray *)globalMediationSettings delegate:(id)delegate;
        [Export ("initializeRewardedVideoWithGlobalMediationSettings:delegate:")]
        void InitializeRewardedVideoWithGlobalMediationSettings (NSObject[] globalMediationSettings, NSObject @delegate);

        // -(id)globalMediationSettingsForClass:(Class)aClass;
        [Export ("globalMediationSettingsForClass:")]
        NSObject GlobalMediationSettingsForClass (Class aClass);

        // -(void)start;
        [Export ("start")]
        void Start ();

        // -(NSString *)version;
        [Export ("version")]
        string Version { get; }

        // -(NSString *)bundleIdentifier;
        [Export ("bundleIdentifier")]
        string BundleIdentifier { get; }
    }
}

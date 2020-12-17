namespace MoPubSDK
{
    using System;
    using CoreGraphics;
    using CoreLocation;
    using Foundation;
    using ObjCRuntime;
    using UIKit;

    // @interface MPAdConversionTracker : NSObject
    [BaseType(typeof(NSObject))]
    interface MPAdConversionTracker
    {
        // +(MPAdConversionTracker *)sharedConversionTracker;
        [Static]
        [Export("sharedConversionTracker")]
        MPAdConversionTracker SharedConversionTracker { get; }

        // -(void)reportApplicationOpenForApplicationID:(NSString *)appID;
        [Export("reportApplicationOpenForApplicationID:")]
        void ReportApplicationOpenForApplicationID(string appID);
    }

    // @interface MPInterstitialAdController : UIViewController
    [BaseType(typeof(UIViewController))]
    interface MPInterstitialAdController
    {
        // +(MPInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)adUnitId;
        [Static]
        [Export("interstitialAdControllerForAdUnitId:")]
        MPInterstitialAdController InterstitialAdControllerForAdUnitId(string adUnitId);

        [Wrap("WeakDelegate")]
        MPInterstitialAdControllerDelegate Delegate { get; set; }

        // @property (nonatomic, weak) id<MPInterstitialAdControllerDelegate> delegate;
        [NullAllowed, Export("delegate", ArgumentSemantic.Weak)]
        NSObject WeakDelegate { get; set; }

        // @property (copy, nonatomic) NSString * adUnitId;
        [Export("adUnitId")]
        string AdUnitId { get; set; }

        // @property (copy, nonatomic) NSString * keywords;
        [Export("keywords")]
        string Keywords { get; set; }

        // @property (copy, nonatomic) NSString * userDataKeywords;
        [Export("userDataKeywords")]
        string UserDataKeywords { get; set; }

        // @property (copy, nonatomic) CLLocation * location;
        [Export("location", ArgumentSemantic.Copy)]
        CLLocation Location { get; set; }

        // -(void)loadAd;
        [Export("loadAd")]
        void LoadAd();

        // @property (readonly, assign, nonatomic) BOOL ready;
        [Export("ready")]
        bool Ready { get; }

        // -(void)showFromViewController:(UIViewController *)controller;
        [Export("showFromViewController:")]
        void ShowFromViewController(UIViewController controller);

        // +(void)removeSharedInterstitialAdController:(MPInterstitialAdController *)controller;
        [Static]
        [Export("removeSharedInterstitialAdController:")]
        void RemoveSharedInterstitialAdController(MPInterstitialAdController controller);

        // +(NSMutableArray *)sharedInterstitialAdControllers;
        [Static]
        [Export("sharedInterstitialAdControllers")]
        NSMutableArray SharedInterstitialAdControllers { get; }
    }

    // @protocol MPInterstitialAdControllerDelegate <NSObject>
    [Protocol, Model]
    [BaseType(typeof(NSObject))]
    interface MPInterstitialAdControllerDelegate
    {
        // @optional -(void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial;
        [Export("interstitialDidLoadAd:")]
        void InterstitialDidLoadAd(MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial;
        [Export("interstitialDidFailToLoadAd:")]
        void InterstitialDidFailToLoadAd(MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error;
        [Export("interstitialDidFailToLoadAd:withError:")]
        void InterstitialDidFailToLoadAd(MPInterstitialAdController interstitial, NSError error);

        // @optional -(void)interstitialWillAppear:(MPInterstitialAdController *)interstitial;
        [Export("interstitialWillAppear:")]
        void InterstitialWillAppear(MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidAppear:(MPInterstitialAdController *)interstitial;
        [Export("interstitialDidAppear:")]
        void InterstitialDidAppear(MPInterstitialAdController interstitial);

        // @optional -(void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial;
        [Export("interstitialWillDisappear:")]
        void InterstitialWillDisappear(MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial;
        [Export("interstitialDidDisappear:")]
        void InterstitialDidDisappear(MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidExpire:(MPInterstitialAdController *)interstitial;
        [Export("interstitialDidExpire:")]
        void InterstitialDidExpire(MPInterstitialAdController interstitial);

        // @optional -(void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial;
        [Export("interstitialDidReceiveTapEvent:")]
        void InterstitialDidReceiveTapEvent(MPInterstitialAdController interstitial);
    }

    // @interface MPAdView : UIView
    [BaseType(typeof(UIView))]
    interface MPAdView
    {
        // -(id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size;
        [Export("initWithAdUnitId:size:")]
        IntPtr Constructor(string adUnitId, CGSize size);

        [Wrap("WeakDelegate")]
        MPAdViewDelegate Delegate { get; set; }

        // @property (nonatomic, weak) id<MPAdViewDelegate> delegate;
        [NullAllowed, Export("delegate", ArgumentSemantic.Weak)]
        NSObject WeakDelegate { get; set; }

        // @property (copy, nonatomic) NSString * adUnitId;
        [Export("adUnitId")]
        string AdUnitId { get; set; }

        // @property (copy, nonatomic) NSString * keywords;
        [Export("keywords")]
        string Keywords { get; set; }

        // @property (copy, nonatomic) NSString * userDataKeywords;
        [Export("userDataKeywords")]
        string UserDataKeywords { get; set; }

        // @property (copy, nonatomic) CLLocation * location;
        [Export("location", ArgumentSemantic.Copy)]
        CLLocation Location { get; set; }

        // -(void)loadAd;
        [Export("loadAd")]
        void LoadAd();

        // -(void)forceRefreshAd;
        [Export("forceRefreshAd")]
        void ForceRefreshAd();

        // -(void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;
        [Export("rotateToOrientation:")]
        void RotateToOrientation(UIInterfaceOrientation newOrientation);

        // -(void)lockNativeAdsToOrientation:(MPNativeAdOrientation)orientation;
        [Export("lockNativeAdsToOrientation:")]
        void LockNativeAdsToOrientation(MPNativeAdOrientation orientation);

        // -(void)unlockNativeAdsOrientation;
        [Export("unlockNativeAdsOrientation")]
        void UnlockNativeAdsOrientation();

        // -(MPNativeAdOrientation)allowedNativeAdsOrientation;
        [Export("allowedNativeAdsOrientation")]
        MPNativeAdOrientation AllowedNativeAdsOrientation { get; }

        // -(CGSize)adContentViewSize;
        [Export("adContentViewSize")]
        CGSize AdContentViewSize { get; }

        // -(void)stopAutomaticallyRefreshingContents;
        [Export("stopAutomaticallyRefreshingContents")]
        void StopAutomaticallyRefreshingContents();

        // -(void)startAutomaticallyRefreshingContents;
        [Export("startAutomaticallyRefreshingContents")]
        void StartAutomaticallyRefreshingContents();
    }

    // @protocol MPAdViewDelegate <NSObject>
    [Protocol, Model]
    [BaseType(typeof(NSObject))]
    interface MPAdViewDelegate
    {
        // @required -(UIViewController *)viewControllerForPresentingModalView;
        [Abstract]
        [Export("viewControllerForPresentingModalView")]
        UIViewController ViewControllerForPresentingModalView { get; }

        // @optional -(void)adViewDidLoadAd:(MPAdView *)view;
        [Export("adViewDidLoadAd:")]
        void AdViewDidLoadAd(MPAdView view);

        // @optional -(void)adViewDidFailToLoadAd:(MPAdView *)view;
        [Export("adViewDidFailToLoadAd:")]
        void AdViewDidFailToLoadAd(MPAdView view);

        // @optional -(void)willPresentModalViewForAd:(MPAdView *)view;
        [Export("willPresentModalViewForAd:")]
        void WillPresentModalViewForAd(MPAdView view);

        // @optional -(void)didDismissModalViewForAd:(MPAdView *)view;
        [Export("didDismissModalViewForAd:")]
        void DidDismissModalViewForAd(MPAdView view);

        // @optional -(void)willLeaveApplicationFromAd:(MPAdView *)view;
        [Export("willLeaveApplicationFromAd:")]
        void WillLeaveApplicationFromAd(MPAdView view);
    }

    // @interface MoPub : NSObject
    [BaseType(typeof(NSObject))]
    interface MoPub
    {
        // +(MoPub * _Nonnull)sharedInstance;
        [Static]
        [Export("sharedInstance")]
        MoPub SharedInstance { get; }

        // @property (assign, nonatomic) BOOL locationUpdatesEnabled;
        [Export("locationUpdatesEnabled")]
        bool LocationUpdatesEnabled { get; set; }

        // @property (nonatomic) BOOL frequencyCappingIdUsageEnabled;
        [Export("frequencyCappingIdUsageEnabled")]
        bool FrequencyCappingIdUsageEnabled { get; set; }

        // @property (assign, nonatomic) BOOL forceWKWebView;
        [Export("forceWKWebView")]
        bool ForceWKWebView { get; set; }

        // @property (assign, nonatomic) int logLevel;
        [Export("logLevel")]
        int LogLevel { get; set; }

        // @property (assign, nonatomic) BOOL enableAdvancedBidding;
        //[Export("enableAdvancedBidding")]
        //bool EnableAdvancedBidding { get; set; }

        // -(void)initializeSdkWithConfiguration:(id)configuration completion:(void (^ _Nullable)(void))completionBlock;
        [Export("initializeSdkWithConfiguration:completion:")]
        void InitializeSdkWithConfiguration(NSObject configuration, [NullAllowed] Action completionBlock);

        // @property (readonly, nonatomic) BOOL isSdkInitialized;
        [Export("isSdkInitialized")]
        bool IsSdkInitialized { get; }

        // -(id _Nullable)globalMediationSettingsForClass:(Class)aClass;
        [Export("globalMediationSettingsForClass:")]
        [return: NullAllowed]
        NSObject GlobalMediationSettingsForClass(Class aClass);

        // -(NSString * _Nonnull)version;
        [Export("version")]
        string Version { get; }

        // -(NSString * _Nonnull)bundleIdentifier;
        [Export("bundleIdentifier")]
        string BundleIdentifier { get; }

        // -(void)setClickthroughDisplayAgentType:(id)displayAgentType;
        [Export("setClickthroughDisplayAgentType:")]
        void SetClickthroughDisplayAgentType(NSObject displayAgentType);

        // -(void)disableViewability:(id)vendors;
        [Export("disableViewability:")]
        void DisableViewability(NSObject vendors);

        // -(NSArray<Class> * _Nullable)allCachedNetworks;
        [NullAllowed, Export("allCachedNetworks")]
        Class[] AllCachedNetworks { get; }

        // -(void)clearCachedNetworks;
        [Export("clearCachedNetworks")]
        void ClearCachedNetworks();

        // @property (readonly, nonatomic) BOOL canCollectPersonalInfo;
        [Export("canCollectPersonalInfo")]
        bool CanCollectPersonalInfo { get; }

        // @property (readonly, nonatomic) int currentConsentStatus;
        [Export("currentConsentStatus")]
        MPConsentStatus CurrentConsentStatus { get; }

        // @property (readonly, nonatomic) int isGDPRApplicable;
        [Export("isGDPRApplicable")]
        int IsGDPRApplicable { get; }

        // @property (readonly, nonatomic) BOOL isConsentDialogReady;
        [Export("isConsentDialogReady")]
        bool IsConsentDialogReady { get; }

        // -(void)loadConsentDialogWithCompletion:(void (^ _Nullable)(NSError * _Nullable))completion;
        [Export("loadConsentDialogWithCompletion:")]
        void LoadConsentDialogWithCompletion([NullAllowed] Action<NSError> completion);

        // -(void)showConsentDialogFromViewController:(UIViewController *)viewController completion:(void (^ _Nullable)(void))completion;
        [Export("showConsentDialogFromViewController:completion:")]
        void ShowConsentDialogFromViewController(UIViewController viewController, [NullAllowed] Action completion);

        // @property (readonly, nonatomic) BOOL shouldShowConsentDialog;
        [Export("shouldShowConsentDialog")]
        bool ShouldShowConsentDialog { get; }

        // -(NSURL * _Nullable)currentConsentPrivacyPolicyUrl;
        [NullAllowed, Export("currentConsentPrivacyPolicyUrl")]
        NSUrl CurrentConsentPrivacyPolicyUrl { get; }

        // -(NSURL * _Nullable)currentConsentPrivacyPolicyUrlWithISOLanguageCode:(NSString * _Nonnull)isoLanguageCode;
        [Export("currentConsentPrivacyPolicyUrlWithISOLanguageCode:")]
        [return: NullAllowed]
        NSUrl CurrentConsentPrivacyPolicyUrlWithISOLanguageCode(string isoLanguageCode);

        // -(NSURL * _Nullable)currentConsentVendorListUrl;
        [NullAllowed, Export("currentConsentVendorListUrl")]
        NSUrl CurrentConsentVendorListUrl { get; }

        // -(NSURL * _Nullable)currentConsentVendorListUrlWithISOLanguageCode:(NSString * _Nonnull)isoLanguageCode;
        [Export("currentConsentVendorListUrlWithISOLanguageCode:")]
        [return: NullAllowed]
        NSUrl CurrentConsentVendorListUrlWithISOLanguageCode(string isoLanguageCode);

        // -(void)grantConsent;
        [Export("grantConsent")]
        void GrantConsent();

        // -(void)revokeConsent;
        [Export("revokeConsent")]
        void RevokeConsent();

        // @property (readonly, copy, nonatomic) NSString * _Nullable currentConsentIabVendorListFormat;
        [NullAllowed, Export("currentConsentIabVendorListFormat")]
        string CurrentConsentIabVendorListFormat { get; }

        // @property (readonly, copy, nonatomic) NSString * _Nullable currentConsentPrivacyPolicyVersion;
        [NullAllowed, Export("currentConsentPrivacyPolicyVersion")]
        string CurrentConsentPrivacyPolicyVersion { get; }

        // @property (readonly, copy, nonatomic) NSString * _Nullable currentConsentVendorListVersion;
        [NullAllowed, Export("currentConsentVendorListVersion")]
        string CurrentConsentVendorListVersion { get; }

        // @property (readonly, copy, nonatomic) NSString * _Nullable previouslyConsentedIabVendorListFormat;
        [NullAllowed, Export("previouslyConsentedIabVendorListFormat")]
        string PreviouslyConsentedIabVendorListFormat { get; }

        // @property (readonly, copy, nonatomic) NSString * _Nullable previouslyConsentedPrivacyPolicyVersion;
        [NullAllowed, Export("previouslyConsentedPrivacyPolicyVersion")]
        string PreviouslyConsentedPrivacyPolicyVersion { get; }

        // @property (readonly, copy, nonatomic) NSString * _Nullable previouslyConsentedVendorListVersion;
        [NullAllowed, Export("previouslyConsentedVendorListVersion")]
        string PreviouslyConsentedVendorListVersion { get; }
    }

    //// @interface Mediation (MoPub)
    //[BaseType(typeof(MoPub))]
    //interface MoPub_Mediation
    //{
    //    // -(NSArray<Class> * _Nullable)allCachedNetworks;
    //    [NullAllowed, Export("allCachedNetworks")]
    //    Class[] AllCachedNetworks { get; }

    //    // -(void)clearCachedNetworks;
    //    [Export("clearCachedNetworks")]
    //    void ClearCachedNetworks();
    //}

    //// @interface Consent (MoPub)
    //[Category(typeof(MoPub))]
    //[BaseType(typeof(MoPub))]
    //interface MoPub_Consent
    //{
    //    // @property (readonly, nonatomic) BOOL canCollectPersonalInfo;
    //    [Export("canCollectPersonalInfo")]
    //    bool CanCollectPersonalInfo { get; }

    //    // @property (readonly, nonatomic) int currentConsentStatus;
    //    [Export("currentConsentStatus")]
    //    int CurrentConsentStatus { get; }

    //    // @property (readonly, nonatomic) int isGDPRApplicable;
    //    [Export("isGDPRApplicable")]
    //    int IsGDPRApplicable { get; }

    //    // @property (readonly, nonatomic) BOOL isConsentDialogReady;
    //    [Export("isConsentDialogReady")]
    //    bool IsConsentDialogReady { get; }

    //    // -(void)loadConsentDialogWithCompletion:(void (^ _Nullable)(NSError * _Nullable))completion;
    //    [Export("loadConsentDialogWithCompletion:")]
    //    void LoadConsentDialogWithCompletion([NullAllowed] Action<NSError> completion);

    //    // -(void)showConsentDialogFromViewController:(UIViewController *)viewController completion:(void (^ _Nullable)(void))completion;
    //    [Export("showConsentDialogFromViewController:completion:")]
    //    void ShowConsentDialogFromViewController(UIViewController viewController, [NullAllowed] Action completion);

    //    // @property (readonly, nonatomic) BOOL shouldShowConsentDialog;
    //    [Export("shouldShowConsentDialog")]
    //    bool ShouldShowConsentDialog { get; }

    //    // -(NSURL * _Nullable)currentConsentPrivacyPolicyUrl;
    //    [NullAllowed, Export("currentConsentPrivacyPolicyUrl")]
    //    NSUrl CurrentConsentPrivacyPolicyUrl { get; }

    //    // -(NSURL * _Nullable)currentConsentPrivacyPolicyUrlWithISOLanguageCode:(NSString * _Nonnull)isoLanguageCode;
    //    [Export("currentConsentPrivacyPolicyUrlWithISOLanguageCode:")]
    //    [return: NullAllowed]
    //    NSUrl CurrentConsentPrivacyPolicyUrlWithISOLanguageCode(string isoLanguageCode);

    //    // -(NSURL * _Nullable)currentConsentVendorListUrl;
    //    [NullAllowed, Export("currentConsentVendorListUrl")]
    //    NSUrl CurrentConsentVendorListUrl { get; }

    //    // -(NSURL * _Nullable)currentConsentVendorListUrlWithISOLanguageCode:(NSString * _Nonnull)isoLanguageCode;
    //    [Export("currentConsentVendorListUrlWithISOLanguageCode:")]
    //    [return: NullAllowed]
    //    NSUrl CurrentConsentVendorListUrlWithISOLanguageCode(string isoLanguageCode);

    //    // -(void)grantConsent;
    //    [Export("grantConsent")]
    //    void GrantConsent();

    //    // -(void)revokeConsent;
    //    [Export("revokeConsent")]
    //    void RevokeConsent();

    //    // @property (readonly, copy, nonatomic) NSString * _Nullable currentConsentIabVendorListFormat;
    //    [NullAllowed, Export("currentConsentIabVendorListFormat")]
    //    string CurrentConsentIabVendorListFormat { get; }

    //    // @property (readonly, copy, nonatomic) NSString * _Nullable currentConsentPrivacyPolicyVersion;
    //    [NullAllowed, Export("currentConsentPrivacyPolicyVersion")]
    //    string CurrentConsentPrivacyPolicyVersion { get; }

    //    // @property (readonly, copy, nonatomic) NSString * _Nullable currentConsentVendorListVersion;
    //    [NullAllowed, Export("currentConsentVendorListVersion")]
    //    string CurrentConsentVendorListVersion { get; }

    //    // @property (readonly, copy, nonatomic) NSString * _Nullable previouslyConsentedIabVendorListFormat;
    //    [NullAllowed, Export("previouslyConsentedIabVendorListFormat")]
    //    string PreviouslyConsentedIabVendorListFormat { get; }

    //    // @property (readonly, copy, nonatomic) NSString * _Nullable previouslyConsentedPrivacyPolicyVersion;
    //    [NullAllowed, Export("previouslyConsentedPrivacyPolicyVersion")]
    //    string PreviouslyConsentedPrivacyPolicyVersion { get; }

    //    // @property (readonly, copy, nonatomic) NSString * _Nullable previouslyConsentedVendorListVersion;
    //    [NullAllowed, Export("previouslyConsentedVendorListVersion")]
    //    string PreviouslyConsentedVendorListVersion { get; }
    //}

    // @interface MPMoPubConfiguration : NSObject
    [BaseType(typeof(NSObject))]
    [DisableDefaultCtor]
    interface MPMoPubConfiguration
    {
        // @property (nonatomic, strong) NSString * _Nonnull adUnitIdForAppInitialization;
        [Export("adUnitIdForAppInitialization", ArgumentSemantic.Strong)]
        string AdUnitIdForAppInitialization { get; set; }

        // @property (nonatomic, strong) NSArray<Class> * _Nullable advancedBidders;
        //[NullAllowed, Export("advancedBidders", ArgumentSemantic.Strong)]
        //Class[] AdvancedBidders { get; set; }

        // @property (nonatomic, strong) NSArray<id> * _Nullable globalMediationSettings;
        [NullAllowed, Export("globalMediationSettings", ArgumentSemantic.Strong)]
        NSObject[] GlobalMediationSettings { get; set; }

        // @property (nonatomic, strong) NSArray<Class> * _Nullable mediatedNetworks;
        //[NullAllowed, Export("mediatedNetworks", ArgumentSemantic.Strong)]
        //Class[] MediatedNetworks { get; set; }

        // -(instancetype _Nonnull)initWithAdUnitIdForAppInitialization:(NSString * _Nonnull)adUnitId __attribute__((objc_designated_initializer));
        [Export("initWithAdUnitIdForAppInitialization:")]
        IntPtr Constructor(string adUnitId);
    }
}

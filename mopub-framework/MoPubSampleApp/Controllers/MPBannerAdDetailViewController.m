//
//  MPBannerAdDetailViewController.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBannerAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPSampleAppInstanceProvider.h"
#import "MPGlobal.h"
#import "MPAdPersistenceManager.h"

@interface MPBannerAdDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPAdView *adView;
@property (nonatomic, assign) BOOL didLoadAd;

@end

@implementation MPBannerAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)info
{
    self = [super initWithNibName:@"MPBannerAdDetailViewController" bundle:nil];
    if (self) {
        self.info = info;

        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Banner";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;
    self.keywordsTextField.text = self.info.keywords;

    self.loadAdButton.enabled = NO;

    [self.spinner startAnimating];
}

- (IBAction)loadAdClicked:(id)sender
{
    self.adView.keywords = self.keywordsTextField.text;

    self.info.keywords = self.adView.keywords;
    // persist last used keywords if this is a saved ad
    if ([[MPAdPersistenceManager sharedManager] savedAdForID:self.info.ID] != nil) {
        [[MPAdPersistenceManager sharedManager] addSavedAd:self.info];
    }

    [self loadAd];
}

- (void)configureAd
{
    self.adView = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:self.info.ID
                                                                                     size:self.adViewContainer.bounds.size];
    self.adView.delegate = self;
    self.adView.accessibilityLabel = @"banner";
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.adViewContainer addSubview:self.adView];

    [self.adView stopAutomaticallyRefreshingContents];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.didLoadAd) {
        [self configureAd];
        [self loadAd];
        self.didLoadAd = YES;
    }
}

- (void)loadAd
{
    [self.keywordsTextField endEditing:YES];

    self.loadAdButton.enabled = NO;
    self.failLabel.hidden = YES;
    [self.spinner startAnimating];
    [self startTimer];
    [self.adView loadAd];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.adView rotateToOrientation:toInterfaceOrientation];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];

    return YES;
}

#pragma mark - <MPAdViewDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize
{
    self.loadAdButton.enabled = YES;
    self.adView.frame = ({
        CGRect frame = self.adView.frame;
        frame.size.height = adSize.height;
        frame;
    });

    [self.spinner stopAnimating];
    [self endTimer];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    self.loadAdButton.enabled = YES;

    [self.spinner stopAnimating];
    self.failLabel.hidden = NO;

    [self endTimer];
}

@end

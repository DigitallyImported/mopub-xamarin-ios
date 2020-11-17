//
//  MPRewardedVideoAdDetailViewController.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoAdDetailViewController.h"
#import "MPAdPersistenceManager.h"
#import "MPRewardedVideo.h"
#import "MPAdInfo.h"
#import "MoPub.h"

@interface MPRewardedVideoAdDetailViewController () <MPRewardedVideoDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UITextField *customDataTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *rewardPickerView;
@property (nonatomic, assign) NSInteger selectedRewardIndex;
@property (nonatomic, strong) MPAdInfo *info;

@end

@implementation MPRewardedVideoAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)adInfo
{
    self = [super init];
    if (self) {
        self.info = adInfo;

        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"Rewarded Video";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;
    self.showButton.hidden = YES;
    self.rewardPickerView.dataSource = self;
    self.rewardPickerView.delegate = self;
    self.keywordsTextField.text = self.info.keywords;

    [MPRewardedVideo setDelegate:self forAdUnitId:self.info.ID];

    [super viewDidLoad];
}

- (void)dealloc
{
    [MPRewardedVideo removeDelegateForAdUnitId:self.info.ID];
}

- (IBAction)didTapLoadButton:(id)sender
{
    [self.keywordsTextField endEditing:YES];

    [self.spinner startAnimating];
    self.showButton.hidden = YES;
    self.loadButton.enabled = NO;
    self.expireLabel.hidden = YES;
    self.failLabel.hidden = YES;
    self.willAppearLabel.alpha = 0.1;
    self.didAppearLabel.alpha = 0.1;
    self.willDisappearLabel.alpha = 0.1;
    self.didDisappearLabel.alpha = 0.1;
    self.didReceiveTapLabel.alpha = 0.1;
    self.shouldRewardLabel.alpha = 0.1;
    self.rewardPickerView.userInteractionEnabled = false;
    [self.rewardPickerView reloadAllComponents];

    self.info.keywords = self.keywordsTextField.text;
    // persist last used keywords if this is a saved ad
    if ([[MPAdPersistenceManager sharedManager] savedAdForID:self.info.ID] != nil) {
        [[MPAdPersistenceManager sharedManager] addSavedAd:self.info];
    }


    // create Instance Mediation Settings as needed here
    [self startTimer];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:self.info.ID keywords:self.info.keywords userDataKeywords:nil location:nil customerId:@"testCustomerId" mediationSettings:@[]];
}

- (IBAction)didTapShowButton:(id)sender
{
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:self.info.ID]) {
        NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID:self.info.ID];
        MPRewardedVideoReward * reward = rewards[self.selectedRewardIndex];
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:self.info.ID fromViewController:self withReward:reward customData:self.customDataTextField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];

    return YES;
}

#pragma mark - <MPRewardedVideoDelegate>

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID
{
    [self endTimer];
    [self.spinner stopAnimating];
    self.showButton.hidden = NO;
    self.loadButton.enabled = YES;

    self.rewardPickerView.userInteractionEnabled = true;
    [self.rewardPickerView reloadAllComponents];
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
    [self endTimer];
    self.failLabel.hidden = NO;
    self.loadButton.enabled = YES;
    [self.spinner stopAnimating];
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID
{
    self.willAppearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID
{
    self.didAppearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID
{
    self.willDisappearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID
{
    self.showButton.hidden = YES;
    self.didDisappearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID
{
    self.expireLabel.hidden = NO;
    self.loadButton.enabled = YES;
    self.showButton.hidden = YES;
    [self.spinner stopAnimating];
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID
{
    self.didReceiveTapLabel.alpha = 1.0;
}

- (void)rewardedVideoWillLeaveApplicationForAdUnitID:(NSString *)adUnitID
{

}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward
{
    self.shouldRewardLabel.alpha = 1.0;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (![MPRewardedVideo hasAdAvailableForAdUnitID:self.info.ID]) {
        return 0;
    }

    NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID:self.info.ID];
    return rewards.count;
}

#pragma mark - UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID:self.info.ID];
    MPRewardedVideoReward * reward = rewards[row];
    NSString * title = [NSString stringWithFormat:@"%@ %@", reward.amount, reward.currencyType];
    NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    return attributedTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedRewardIndex = row;
}

@end

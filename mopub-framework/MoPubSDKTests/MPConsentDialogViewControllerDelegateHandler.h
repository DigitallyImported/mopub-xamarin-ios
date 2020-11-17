//
//  MPConsentDialogViewControllerDelegateHandler.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPConsentDialogViewController.h"

@interface MPConsentDialogViewControllerDelegateHandler : NSObject <MPConsentDialogViewControllerDelegate>

@property (nonatomic, copy, nullable) void (^consentDialogViewControllerDidReceiveConsentResponse)(BOOL response, MPConsentDialogViewController * _Nullable consentDialogViewController);
@property (nonatomic, copy, nullable) void (^consentDialogViewControllerWillDisappear)(MPConsentDialogViewController * _Nullable consentDialogViewController);

@end

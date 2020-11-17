//
//  MPConsentDialogViewControllerDelegateHandler.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPConsentDialogViewControllerDelegateHandler.h"

@implementation MPConsentDialogViewControllerDelegateHandler

- (void)consentDialogViewControllerDidReceiveConsentResponse:(BOOL)response consentDialogViewController:(MPConsentDialogViewController *)consentDialogViewController { if (self.consentDialogViewControllerDidReceiveConsentResponse) self.consentDialogViewControllerDidReceiveConsentResponse(response, consentDialogViewController); }
- (void)consentDialogViewControllerWillDisappear:(MPConsentDialogViewController *)consentDialogViewController { if (self.consentDialogViewControllerWillDisappear) self.consentDialogViewControllerWillDisappear(consentDialogViewController); }

@end

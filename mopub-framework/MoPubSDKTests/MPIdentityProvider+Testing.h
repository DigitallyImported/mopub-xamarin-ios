//
//  MPIdentityProvider+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPIdentityProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPIdentityProvider (Testing)
+ (NSString *)mopubIdentifier:(BOOL)obfuscate;
@end

NS_ASSUME_NONNULL_END

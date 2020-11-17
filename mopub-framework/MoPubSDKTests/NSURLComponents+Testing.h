//
//  NSURLComponents+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@interface NSURLComponents (Testing)

- (NSString *)valueForQueryParameter:(NSString *)key;
- (BOOL)hasQueryParameter:(NSString *)key;

@end

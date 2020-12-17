//
//  NSURLComponents+Testing.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "NSURLComponents+Testing.h"

@implementation NSURLComponents (Testing)

- (NSString *)valueForQueryParameter:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[self.queryItems filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

- (BOOL)hasQueryParameter:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    return [self.queryItems filteredArrayUsingPredicate:predicate].count > 0;
}

@end

//
//  MPHTTPNetworkSession+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPHTTPNetworkSession.h"
#import "MPHTTPNetworkTaskData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPHTTPNetworkSession (Testing)

// Expose private methods
@property (nonatomic, strong) NSURLSession * sharedSession;

- (void)setSessionData:(MPHTTPNetworkTaskData *)data forTask:(NSURLSessionTask *)task;
- (MPHTTPNetworkTaskData *)sessionDataForTask:(NSURLSessionTask *)task;
- (void)appendData:(NSData *)data toSessionDataForTask:(NSURLSessionTask *)task;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END

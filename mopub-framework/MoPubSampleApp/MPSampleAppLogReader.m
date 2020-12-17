//
//  MPSampleAppLogReader.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPSampleAppLogReader.h"
#import "MPLogging.h"

@interface MPSampleAppLogReader () <MPBLogger, UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *warmingUpAlertView;

@end

@implementation MPSampleAppLogReader

+ (MPSampleAppLogReader *)sharedLogReader
{
    static dispatch_once_t once;
    static MPSampleAppLogReader *sharedLogReader;
    dispatch_once(&once, ^{
        sharedLogReader = [[self alloc] init];
    });

    return sharedLogReader;
}

- (void)dealloc
{
    [MPLogging removeLogger:self];
}

- (void)beginReadingLogMessages
{
    [MPLogging removeLogger:self];
    [MPLogging addLogger:self];
}

#pragma mark - <MPBLogger>

- (MPBLogLevel)logLevel
{
    return MPBLogLevelDebug;
}

- (void)logMessage:(NSString *)message
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[kMPWarmingUpErrorLogFormatWithAdUnitID stringByReplacingOccurrencesOfString:@"%@" withString:@".*"]
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];

    if (self.warmingUpAlertView == nil && [regex numberOfMatchesInString:message options:0 range:NSMakeRange(0, message.length)] > 0) {
        self.warmingUpAlertView = [[UIAlertView alloc] initWithTitle:@"Warming Up"
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [self.warmingUpAlertView show];
    }
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.warmingUpAlertView = nil;
}


@end

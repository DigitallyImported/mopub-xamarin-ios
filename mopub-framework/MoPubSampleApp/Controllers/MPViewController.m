//
//  MPViewController.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPViewController.h"

@interface MPViewController ()
@property (nonatomic, strong) NSDate * startTime;
@property (nonatomic, strong) NSDate * endTime;
@property (nonatomic, strong) UILabel * timeLabel;
@end

@implementation MPViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.timeLabel];

    [self.timeLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.timeLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.timeLabel.heightAnchor constraintEqualToConstant:20].active = YES;
    [self.timeLabel.widthAnchor constraintEqualToConstant:300].active = YES;
}

- (NSTimeInterval)lastTimeInterval {
    if (self.endTime == nil || self.startTime == nil) {
        return 0;
    }

    return (self.endTime.timeIntervalSince1970 - self.startTime.timeIntervalSince1970);
}

- (void)startTimer {
    self.startTime = [NSDate date];
}

- (void)endTimer {
    self.endTime = [NSDate date];
    self.timeLabel.text = [NSString stringWithFormat:@"%f seconds", self.lastTimeInterval];
}

@end

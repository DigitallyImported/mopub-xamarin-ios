//
//  XCTestCase+MPAddition.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "XCTestCase+MPAddition.h"

@implementation XCTestCase (MPAddition)

- (NSData *)dataFromXMLFileNamed:(NSString *)name class:(Class)aClass
{
    NSString *file = [[NSBundle bundleForClass:[aClass class]] pathForResource:name ofType:@"xml"];
    return [NSData dataWithContentsOfFile:file];
}

@end

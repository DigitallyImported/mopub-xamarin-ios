//
//  AppDelegate.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "AppDelegate.h"
#import "MPAdPersistenceManager.h"
#import "MPAdTableViewController.h"
#import "MPAdSection.h"
#import "MPIdentityProvider.h"
#import "MPAdConversionTracker.h"
#import "MPAdInfo.h"
#import "MPLogging.h"
#import "MoPub.h"
#import <UIKit/UIKit.h>

@interface AppDelegate()
@property (nonatomic, strong) MPAdTableViewController * adTable;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"This device's advertisingIdentifier: %@", [MPIdentityProvider identifier]);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.adTable = [[MPAdTableViewController alloc] initWithAdSections:[MPAdSection adSections]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.adTable];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];

    [[MPAdConversionTracker sharedConversionTracker] reportApplicationOpenForApplicationID:@"112358"];

    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1]};

    MPMoPubConfiguration * sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization: @"0ac59b0996d947309c33f59d6676399f"];
    sdkConfig.globalMediationSettings = @[];
    sdkConfig.loggingLevel = MPBLogLevelInfo;
    [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
        NSLog(@"SDK initialization complete");
    }];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme isEqualToString:@"mopub"] && [url.host isEqualToString:@"load"]) {
        // Convert the query parameters into a dictionary.
        NSDictionary * queryParameters = ({
            NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

            NSMutableDictionary * params = [NSMutableDictionary dictionary];
            for (NSURLQueryItem * queryItem in urlComponents.queryItems) {
                [params setObject:queryItem.value forKey:queryItem.name];
            }

            params;
        });

        // Extract the info needed to create the `MPAdInfo` object.
        MPAdInfo * adUnit = [MPAdInfo infoWithDictionary:queryParameters];
        if (adUnit == nil) {
            return NO;
        }

        // Dispatch the display of the ad unit onto the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.adTable loadAd:adUnit];
            [[MPAdPersistenceManager sharedManager] addSavedAd:adUnit];
        });

        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h"
    #import "MPMediationSettingsProtocol.h"
#endif

@interface MPGoogleGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>

@property (nonatomic,copy) NSString *npa;

@end

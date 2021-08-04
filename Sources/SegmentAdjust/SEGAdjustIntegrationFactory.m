#import "SEGAdjustIntegrationFactory.h"
#import "SEGAdjustIntegration.h"


@implementation SEGAdjustIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static SEGAdjustIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings forAnalytics:(SEGAnalytics *)analytics
{
    return [[SEGAdjustIntegration alloc] initWithSettings:settings withAnalytics:analytics];
}

- (NSString *)key
{
    return @"Adjust";
}

@end

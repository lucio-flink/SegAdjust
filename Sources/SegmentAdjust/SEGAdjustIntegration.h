#import <Foundation/Foundation.h>
#import <Adjust.h> 

#import <SEGAnalytics.h>


@interface SEGAdjustIntegration : NSObject <SEGIntegration, AdjustDelegate>

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) SEGAnalytics *analytics;

- (instancetype)initWithSettings:(NSDictionary *)settings withAnalytics:(SEGAnalytics *)analytics;

@end

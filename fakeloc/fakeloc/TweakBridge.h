//
//  TweakBridge.h
//  fakeloc
//
//  Created by jackrex on 25/5/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TweakBridge : NSObject

+ (instancetype) shareInstance;

- (CLLocation *) getCoreLocation;
- (BOOL) isStop;

@property (nonatomic, strong) CLLocation *currentCLL;

@end

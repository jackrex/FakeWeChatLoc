//
//  TweakBridgeIOS.h
//  TestFakeTweak
//
//  Created by jackrex on 26/5/2016.
//  Copyright © 2016 Jackrex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TweakBridgeIOS : NSObject

+ (instancetype) shareInstance;

@property (nonatomic) CLLocationCoordinate2D c2d;


- (CLLocation *) getCoreLocation;
- (void)setLocWithLat:(double) lat andLng:(double)lng;


@end

//
//  TweakBridge.m
//  fakeloc
//
//  Created by jackrex on 25/5/2016.
//
//

#import "TweakBridge.h"

@implementation TweakBridge

+ (instancetype)shareInstance {
    static TweakBridge *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
        NSLog(@"TweakBridge is me %@",self);
        
    });
    return manager;
}

// 停止伪装
- (BOOL)isStop {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/location"];
    if (dict) {
        BOOL stop = [dict objectForKey:@"isStop"];
        return stop;
    }
    return NO;
}


- (CLLocation *)getCoreLocation {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/location"];
    NSLog(@"dict is %@", dict);
    if (dict) {
        double longNum = [dict[@"long"] doubleValue];
        double latNum = [dict [@"lat"] doubleValue];
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:latNum longitude:longNum];
        return location1;
    }
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:28.0000 longitude:113.0000];
    return location1;
}

@end

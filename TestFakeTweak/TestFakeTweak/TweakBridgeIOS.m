//
//  TweakBridgeIOS.m
//  TestFakeTweak
//
//  Created by jackrex on 26/5/2016.
//  Copyright © 2016 Jackrex. All rights reserved.
//

#import "TweakBridgeIOS.h"
#import <dlfcn.h>
#import <CoreLocation/CoreLocation.h>

#define TWEAK_PATH "/Library/MobileSubstrate/DynamicLibraries/fakeloc.dylib"
#define LOCATION_PATH @"/var/mobile/Library/Preferences/location"


@implementation TweakBridgeIOS

+ (instancetype)shareInstance {
    static TweakBridgeIOS *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
        
    });
    return manager;
}

- (CLLocation *)getCoreLocation {
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:31.154352 longitude:121.425362];
    return location1;
}

- (void)setLocWithLat:(double)lat andLng:(double)lng {
    NSLog(@"set lat & lng is %f &&&& %f", lat, lng);
    Class TweakBridge = NSClassFromString(@"TweakBridge");
    void *handle = dlopen(TWEAK_PATH, RTLD_LAZY);
    if (handle) {
        NSLog(@"handle");
        TweakBridge = NSClassFromString(@"TweakBridge");
        NSDictionary *dict = @{@"lat":[NSNumber numberWithDouble:lat], @"long":[NSNumber numberWithDouble:lng]};
        BOOL isSuccess = [dict writeToFile:LOCATION_PATH atomically:YES];
        NSLog(@"isSuccess, %d", isSuccess);
        CLLocation *location = [[TweakBridge shareInstance] getCoreLocation];
        if (0 != dlclose(handle)) {
            printf("dlclose failed! %s\n", dlerror());
        }else {
            
        }
    } else {
        NSLog(@"nohandle");
        printf("dlopen failed! %s\n", dlerror());
    }
}

@end

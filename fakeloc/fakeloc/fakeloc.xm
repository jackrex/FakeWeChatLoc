#import<UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>
#import "TweakBridge.h"

%hook MicroMessengerAppDelegate

- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    NSLog(@"weixin-weixin-weixin");
    return %orig;
}

%end


%hook SeePeopleNearByLogicController

- (void)onRetrieveLocationOK:(id)arg1 {

    CLLocation *location = [[TweakBridge shareInstance] getCoreLocation];
    %orig(location); //这里把原来获取真正的地理信息缓存我们自己的

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[@"enter onRetrieveLocationOK" stringByAppendingString:[[NSString alloc] initWithFormat:@"location is %@", location]] message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
}

%end



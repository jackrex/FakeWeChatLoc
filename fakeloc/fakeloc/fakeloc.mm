#line 1 "/Users/jackrex/Desktop/Share/fakeloc/fakeloc/fakeloc.xm"
#import<UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>
#import "TweakBridge.h"

#include <logos/logos.h>
#include <substrate.h>
@class MicroMessengerAppDelegate; @class SeePeopleNearByLogicController; 
static BOOL (*_logos_orig$_ungrouped$MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$)(MicroMessengerAppDelegate*, SEL, id, id); static BOOL _logos_method$_ungrouped$MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$(MicroMessengerAppDelegate*, SEL, id, id); static void (*_logos_orig$_ungrouped$SeePeopleNearByLogicController$onRetrieveLocationOK$)(SeePeopleNearByLogicController*, SEL, id); static void _logos_method$_ungrouped$SeePeopleNearByLogicController$onRetrieveLocationOK$(SeePeopleNearByLogicController*, SEL, id); 

#line 6 "/Users/jackrex/Desktop/Share/fakeloc/fakeloc/fakeloc.xm"


static BOOL _logos_method$_ungrouped$MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$(MicroMessengerAppDelegate* self, SEL _cmd, id arg1, id arg2) {
    NSLog(@"weixin-weixin-weixin");
    return _logos_orig$_ungrouped$MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$(self, _cmd, arg1, arg2);
}






static void _logos_method$_ungrouped$SeePeopleNearByLogicController$onRetrieveLocationOK$(SeePeopleNearByLogicController* self, SEL _cmd, id arg1) {

    CLLocation *location = [[TweakBridge shareInstance] getCoreLocation];
    _logos_orig$_ungrouped$SeePeopleNearByLogicController$onRetrieveLocationOK$(self, _cmd, location); 

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[@"enter onRetrieveLocationOK" stringByAppendingString:[[NSString alloc] initWithFormat:@"location is %@", location]] message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
}




static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$MicroMessengerAppDelegate = objc_getClass("MicroMessengerAppDelegate"); MSHookMessageEx(_logos_class$_ungrouped$MicroMessengerAppDelegate, @selector(application:didFinishLaunchingWithOptions:), (IMP)&_logos_method$_ungrouped$MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$, (IMP*)&_logos_orig$_ungrouped$MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$);Class _logos_class$_ungrouped$SeePeopleNearByLogicController = objc_getClass("SeePeopleNearByLogicController"); MSHookMessageEx(_logos_class$_ungrouped$SeePeopleNearByLogicController, @selector(onRetrieveLocationOK:), (IMP)&_logos_method$_ungrouped$SeePeopleNearByLogicController$onRetrieveLocationOK$, (IMP*)&_logos_orig$_ungrouped$SeePeopleNearByLogicController$onRetrieveLocationOK$);} }
#line 30 "/Users/jackrex/Desktop/Share/fakeloc/fakeloc/fakeloc.xm"

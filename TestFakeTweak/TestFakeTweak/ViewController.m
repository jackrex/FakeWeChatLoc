//
//  ViewController.m
//  TestFakeTweak
//
//  Created by jackrex on 26/5/2016.
//  Copyright © 2016 Jackrex. All rights reserved.
//

@import  UIKit;
#import "ViewController.h"
#import "TweakBridgeIOS.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField *latTextField;
@property (strong, nonatomic) IBOutlet UITextField *longTextField;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)go:(id)sender {
    double lat = [_latTextField.text doubleValue];
    double longt = [_longTextField.text doubleValue];
    [[TweakBridgeIOS shareInstance] setLocWithLat:lat andLng:longt];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设置成功，打开微信附近的人看看吧" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

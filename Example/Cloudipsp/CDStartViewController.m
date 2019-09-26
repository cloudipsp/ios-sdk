//
//  CDStartViewController.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 6/30/17.
//  Copyright © 2017 Nadiia. All rights reserved.
//

#import "CDStartViewController.h"
#import "CDCustomProgramViewController.h"
#import <Cloudipsp/PSCloudipsp.h>

@interface CDStartViewController () <PSPayCallbackDelegate, PSApplePayCallbackDelegate>

@property(nonatomic, strong) PSCloudipspApi *api;

@end

@implementation CDStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.api = [PSCloudipspApi apiWithMerchant:1396424 andCloudipspView:nil];
}
    
- (IBAction)customProgrammaticallyClicked:(UIButton *)sender {
    CDCustomProgramViewController *vc = [[CDCustomProgramViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)applePayClicked:(id)sender {
    if ([PSCloudipspApi supportsApplePay]) {
        NSString *orderId = [NSString stringWithFormat:@"ApplePayTest_%ld", (long)NSDate.date.timeIntervalSince1970];
        PSOrder *order = [[PSOrder alloc] initOrder:100 aCurrency:PSCurrencyUAH aIdentifier:orderId aAbout:@"Test_ApplePay_:)"];
        
        [self.api applePay:order andDelegate:self];
    } else {
        UIAlertController *alert =  [UIAlertController
                                   alertControllerWithTitle:@"Whoops"
                                   message:@"Apple pay doesn't supported"
                                   preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction: [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)onPaidProcess:(PSReceipt *)receipt {
    
}

- (void)onPaidFailure:(NSError *)error {
    NSLog(@"onPaidFailure %@", error);
}

- (void)onWaitConfirm {
    
}

- (void)onApplePayNavigate:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

@end

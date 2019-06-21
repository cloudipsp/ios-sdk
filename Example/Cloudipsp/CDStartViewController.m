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

@interface CDStartViewController () <PSPayCallbackDelegate>

@property(nonatomic, strong) PSCloudipspApi *api;

@end

@implementation CDStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.api = [PSCloudipspApi apiWithMerchant:900234 andCloudipspView:nil];
}
    
- (IBAction)customProgrammaticallyClicked:(UIButton *)sender {
    CDCustomProgramViewController *vc = [[CDCustomProgramViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)applePayClicked:(id)sender {
    if ([PSCloudipspApi supportsApplePay]) {
        NSString *orderId = [NSString stringWithFormat:@"ApplePayTest_%ld", (long)NSDate.date.timeIntervalSince1970];
        PSOrder *order = [[PSOrder alloc] initOrder:123 aCurrency:PSCurrencyRUB aIdentifier:orderId aAbout:@"Test_ApplePay_:)"];

        UIViewController *applePayViewController = [self.api applePay:@"merchant.fondy.eu" aOrder:order aPayCallbackDelegate:self];
        [self presentViewController:applePayViewController animated:YES completion:nil];
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
    
}

- (void)onWaitConfirm {
    
}

@end

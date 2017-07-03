//
//  CDBaseViewController.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 6/30/17.
//  Copyright © 2017 Nadiia. All rights reserved.
//

#import "CDBaseViewController.h"
#import "CDResultViewController.h"

static NSString * const resultSegue = @"resultSegue";

@interface CDBaseViewController ()
    
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) UIView *lockView;
    
@end

@implementation CDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
}
    
#pragma mark - KeyboardNotifications
    
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
    
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}
    
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}
    
#pragma mark - Progress
    
- (void)taskWillStarted {
    self.lockView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:self.lockView];
    [self.indicatorView startAnimating];
}
    
- (void)taskDidFinished {
    [self.lockView removeFromSuperview];
    [self.indicatorView stopAnimating];
}
    
- (void)showToastWithText:(NSString *)text {
    UIAlertController * ac =  [UIAlertController
                               alertControllerWithTitle:nil
                               message:text
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:ac animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       [ac dismissViewControllerAnimated:YES completion:nil];
                   });
}
    
#pragma mark - Validation
   
- (BOOL)isEmpty:(NSString *)str {
    return str.length == 0;
}
    
#pragma mark - PayCallbackDelegate
    
- (void)onPaidProcess:(PSReceipt *)receipt {
    self.result = [NSString stringWithFormat:NSLocalizedString(@"PAID_STATUS_KEY", nil), [PSReceipt getStatusName:receipt.status], (long)receipt.paymentId];
    [self taskDidFinished];
    [self performSegueWithIdentifier:resultSegue sender:self];
    //for getting all response fields
    //[PSReceiptUtils dumpFields:receipt];
}
    
- (void)onPaidFailure:(NSError *)error {
    if ([error code] == PSPayErrorCodeFailure) {
        NSDictionary *info = [error userInfo];
        self.result = [NSString stringWithFormat:@"PayError. Code %@\nDescription: %@", [info valueForKey:@"error_code"], [info valueForKey:@"error_message"]];
    } else {
        self.result = [NSString stringWithFormat:@"Error: %@", [error localizedDescription]];
    }
    [self performSegueWithIdentifier:resultSegue sender:self];
    [self taskDidFinished];
}
    
- (void)onWaitConfirm {
    [self taskDidFinished];
}
    
#pragma mark - ConfirmationErrorHandler
    
- (void)onCardInputErrorClear:(PSCardInputView *)cardInputView
                   aTextField:(UITextField *)textField {
    
}
    
- (void)onCardInputErrorCatched:(PSCardInputView *)cardInputView
                     aTextField:(UITextField *)textField
                         aError:(PSConfirmationError)error {
    switch (error) {
        case PSConfirmationErrorInvalidCardNumber:
        [self showToastWithText:NSLocalizedString(@"INVALID_CARD_NUMBER_KEY", nil)];
        break;
        case PSConfirmationErrorInvalidMm:
        [self showToastWithText:NSLocalizedString(@"INVALID_EXPIRY_MONTH_KEY", nil)];
        break;
        case PSConfirmationErrorInvalidYy:
        [self showToastWithText:NSLocalizedString(@"INVALID_EXPIRY_YEAR_KEY", nil)];
        break;
        case PSConfirmationErrorInvalidDate:
        [self showToastWithText:NSLocalizedString(@"INVALID_EXPIRY_DATE_KEY", nil)];
        break;
        case PSConfirmationErrorInvalidCvv:
        [self showToastWithText:NSLocalizedString(@"INVALID_CVV_KEY", nil)];
        break;
        
        default:
        break;
    }
}

#pragma mark - Navigation
    
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:resultSegue]) {
        CDResultViewController *vc = (CDResultViewController *)segue.destinationViewController;
        vc.result = self.result;
    }
}

@end

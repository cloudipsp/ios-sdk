//
//  CDViewController.m
//  Cloudipsp
//
//  Created by Nadiia on 02/02/2016.
//  Copyright (c) 2016 Nadiia. All rights reserved.
//

#import "CDViewController.h"
#import <Cloudipsp/PSCloudipsp.h>
#import "CDResultViewController.h"

static NSString * const resultSegue = @"resultSegue";

@interface CDViewController () <PSPayCallbackDelegate, PSConfirmationErrorHandler, UIPickerViewDataSource, UIPickerViewDelegate, PSCardInputViewDelegate>

@property (nonatomic, strong) PSCloudipspWKWebView *webView;


@property (nonatomic, weak) IBOutlet UITextField *amountTextField;
@property (nonatomic, weak) IBOutlet UITextField *currencyTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *descriptionTextField;

@property (nonatomic, weak) IBOutlet PSCardInputView *cardInputView;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *fields;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *lockView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) PSCloudipspApi *api;

@end

@implementation CDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardInputView.inputDelegate = self;
    [self registerForKeyboardNotifications];
    [self setupPickerView];
    self.webView = [[PSCloudipspWKWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.webView];
    self.api = [PSCloudipspApi apiWithMerchant:1396424 andCloudipspView:self.webView];
}

- (void)addCustomLocalization {
    [PSCloudipspApi setLocalization:[PSLocalization customLocalization:@"card:" aExpiry:@"expiry:" aMonth:@"month" aYear:@"year" aCvv:@"cvv"]];
    PSCardInputView *view = [[PSCardInputView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.inputDelegate = self;
    [self.view addSubview:view];
}

#pragma mark - setup pickerView

- (void)setupPickerView {
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 150)];
    [self.pickerView setDataSource: self];
    [self.pickerView setDelegate: self];
    self.pickerView.showsSelectionIndicator = YES;
    self.currencyTextField.inputView = self.pickerView;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self action:@selector(changePickerViewValue)];
    toolBar.items = @[barButtonDone];
    self.currencyTextField.inputAccessoryView = toolBar;
}

- (void)changePickerViewValue {
    [self.currencyTextField resignFirstResponder];
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

#pragma mark - IBAction

- (IBAction)test:(UIButton *)sender {
    self.amountTextField.text = @"1";
    self.currencyTextField.text = @"UAH";
    self.emailTextField.text = @"example@test.com";
    self.descriptionTextField.text = @"ios Test";
    [self.cardInputView test];
}

- (IBAction)pay:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self isValidFields]) {
        NSString *orderId = [NSString stringWithFormat:@"dn_%ld", (long)NSDate.date.timeIntervalSince1970];
        PSOrder *order = [[PSOrder alloc] initOrder:[self.amountTextField.text integerValue]
                                      aCurrency:getCurrency(self.currencyTextField.text)
                                    aIdentifier:orderId
                                         aAbout:self.descriptionTextField.text];
        order.reservationData = @"eyJwaG9uZW1vYmlsZSI6IjE1MDI3MTIzMTEiLCJjdXN0b21lcl9hZGRyZXNzIjoiM3JkIFN0cmVldCIsImN1c3RvbWVyX2NvdW50cnkiOiJDQSIsImN1c3RvbWVyX3N0YXRlIjoiT04iLCJjdXN0b21lcl9uYW1lIjoiWXZvbm5lIFRoaWJhdWx0IiwiY3VzdG9tZXJfY2l0eSI6IkFsYmVydGEiLCJjdXN0b21lcl96aXAiOiI0MiJ9";
        if (![self isEmpty:self.emailTextField.text]) {
            order.email = self.emailTextField.text;
        }
        PSCard *card = [self.cardInputView confirm:self];
        if (card != nil) {
            [self taskWillStarted];
            [self.api pay:card aOrder:order aPayCallbackDelegate:self];
        }
    }
}

- (BOOL)isValidFields {
    BOOL valid = YES;
    if ([self isEmpty:self.amountTextField.text]) {
        [self showToastWithText:NSLocalizedString(@"INVALID_AMOUNT_KEY", nil)];
        valid = NO;
    } else if ([self isEmpty:self.currencyTextField.text]) {
        [self showToastWithText:NSLocalizedString(@"INVALID_CURRENCY_KEY", nil)];
        valid = NO;
    } else if ([self isEmpty:self.descriptionTextField.text]) {
        [self showToastWithText:NSLocalizedString(@"INVALID_DESCRIPTION_KEY", nil)];
        valid = NO;
    }
    return valid;
}

- (BOOL)isEmpty:(NSString *)str {
    return str.length == 0;
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:resultSegue]) {
        CDResultViewController *vc = (CDResultViewController *)segue.destinationViewController;
        vc.result = self.result;
    }
    
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

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.amountTextField]) {
        NSCharacterSet *validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSArray *components = [string componentsSeparatedByCharactersInSet:validationSet];
        if ([components count] > 1) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:[self.fields lastObject]]) {
        [textField resignFirstResponder];
        [self.cardInputView.cardNumberTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        UITextField *next = [self.fields objectAtIndex:[self.fields indexOfObject:textField] + 1];
        [next becomeFirstResponder];
    }
    return YES;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        self.currencyTextField.text = getCurrencyName(row + 1);
    }
    return getCurrencyName(row + 1);
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currencyTextField.text = getCurrencyName(row +1);
}

#pragma mark - UnwindSegue

- (IBAction)payUnwind:(UIStoryboardSegue *)unwindSegue {
    self.amountTextField.text = @"";
    self.currencyTextField.text = @"";
    self.emailTextField.text = @"";
    self.descriptionTextField.text = @"";
    [self.cardInputView clear];
}

#pragma mark - PSCardInputViewDelegate

- (void)didEndEditing:(PSCardInputView *)cardInputView {
    NSLog(@"End editing PSCardInputView");
}

@end

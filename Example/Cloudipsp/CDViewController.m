//
//  CDViewController.m
//  Cloudipsp
//
//  Created by Nadiia on 02/02/2016.
//  Copyright (c) 2016 Nadiia. All rights reserved.
//

#import "CDViewController.h"
#import <Cloudipsp/Cloudipsp.h>
#import "CDResultViewController.h"

static NSString * const resultSegue = @"resultSegue";

@interface CDViewController () <PayCallbackDelegate, ConfirmationErrorHandler, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet CloudipspWebView *webView;

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *currencyTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet CardInputView *cardInputView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *fields;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *lockView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) CloudipspApi *api;

@end

@implementation CDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    [self setupPickerView];
    self.api = [CloudipspApi apiWithMerchant:1396424 andCloudipspView:self.webView];
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
    self.amountTextField.text = @"14";
    self.currencyTextField.text = @"UAH";
    self.emailTextField.text = @"nadiia.dovbysh@gmail.com";
    self.descriptionTextField.text = @"ios Test";
    [self.cardInputView test];
}

- (IBAction)pay:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self isValidFields]) {
        NSString *orderId = [NSString stringWithFormat:@"dn_%ld", (long)NSDate.date.timeIntervalSince1970];
        Order *order = [[Order alloc] initOrder:[self.amountTextField.text integerValue]
                                      aCurrency:getCurrency(self.currencyTextField.text)
                                    aIdentifier:orderId
                                         aAbout:self.descriptionTextField.text
                                         aEmail:self.emailTextField.text];
        Card *card = [self.cardInputView confirm:self];
        if (card != nil) {
            [self taskWillStarted];
            [self.api pay:card aOrder:order aPayCallbackDelegate:self];
        }
    }
}

- (BOOL)isValidFields {
    BOOL valid = YES;
    if ([self isEmpty:self.amountTextField.text]) {
        [self showToastWithText:@"Invalid Amount"];
        valid = NO;
    } else if ([self isEmpty:self.currencyTextField.text]) {
        [self showToastWithText:@"Invalid Currency"];
        valid = NO;
    } else if ([self isEmpty:self.emailTextField.text]) {
        [self showToastWithText:@"Invalid Email"];
        valid = NO;
    } else if ([self isEmpty:self.descriptionTextField.text]) {
        [self showToastWithText:@"Invalid Description"];
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

- (void)onCardInputErrorClear:(CardInputView *)cardInputView
                   aTextField:(UITextField *)textField {
    
}

- (void)onCardInputErrorCatched:(CardInputView *)cardInputView
                     aTextField:(UITextField *)textField
                         aError:(ConfirmationError)error {
    switch (error) {
        case ConfirmationErrorInvalidCardNumber:
            [self showToastWithText:@"Invalid Card Number"];
            break;
        case ConfirmationErrorInvalidMm:
            [self showToastWithText:@"Invalid Expiry Month"];
            break;
        case ConfirmationErrorInvalidYy:
            [self showToastWithText:@"Invalid Expiry Year"];
            break;
        case ConfirmationErrorInvalidDate:
            [self showToastWithText:@"Invalid Expiry Date"];
            break;
        case ConfirmationErrorInvalidCvv:
            [self showToastWithText:@"Invalid CVV"];
            break;
            
        default:
            break;
    }
}

#pragma mark - PayCallbackDelegate

- (void)onPaidSuccess:(Receipt *)receipt {
    self.result = @"Successful";
    [self taskDidFinished];
    [self performSegueWithIdentifier:resultSegue sender:self];
}

- (void)onPaidFailure:(NSError *)error {
    self.result = [NSString stringWithFormat:@"Error: %@", [error localizedDescription]];
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

@end

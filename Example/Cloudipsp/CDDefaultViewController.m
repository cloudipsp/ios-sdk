//
//  CDDefaultViewController.m
//  Cloudipsp
//
//  Created by Nadiia on 02/02/2016.
//  Copyright (c) 2016 Nadiia. All rights reserved.
//

#import "CDDefaultViewController.h"

@interface CDDefaultViewController () <PSCardInputViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *fields;
    
@property (nonatomic, weak) IBOutlet UITextField *amountTextField;
@property (nonatomic, weak) IBOutlet UITextField *currencyTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *descriptionTextField;
    
@property (nonatomic, weak) IBOutlet PSCardInputView *cardInputView;
@property (nonatomic, strong) PSCloudipspWKWebView *webView;
@property (nonatomic, strong) PSCloudipspApi *api;
    
@property (nonatomic, strong) UIPickerView *pickerView;

@end

@implementation CDDefaultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPickerView];
    [self setupWebView];
    self.cardInputView.inputDelegate = self;
    self.api = [PSCloudipspApi apiWithMerchant:1396424 andCloudipspView:self.webView];
}

- (void)addCustomLocalization {
    [PSCloudipspApi setLocalization:[PSLocalization customLocalization:@"card:" aExpiry:@"expiry:" aMonth:@"month" aYear:@"year" aCvv:@"cvv"]];
    PSCardInputView *view = [[PSCardInputView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.inputDelegate = self;
    [self.view addSubview:view];
}
    
#pragma mark - Setup WebView
    
- (void)setupWebView {
    self.webView = [[PSCloudipspWKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 66)];
    [self.view addSubview:self.webView];
}
    
#pragma mark - Setup PickerView
    
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
    
#pragma mark - Validation
    
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

#pragma mark - IBAction
    
- (IBAction)test:(UIBarButtonItem *)sender {
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
    
#pragma mark - UIPickerViewDataSource
    
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
    
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 6;
}
    
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        self.currencyTextField.text = getCurrencyName(row + 1);
    }
    return getCurrencyName(row + 1);
}
    
#pragma mark - UIPickerViewDelegate
    
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currencyTextField.text = getCurrencyName(row + 1);
}

#pragma mark - UITextFieldDelegate

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

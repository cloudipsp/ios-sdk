//
//  CDCustomStoryboardViewController.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 7/2/17.
//  Copyright © 2017 Nadiia. All rights reserved.
//

#import "CDCustomStoryboardViewController.h"

@interface CDCustomStoryboardViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
    
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *fields;
    
@property (nonatomic, weak) IBOutlet UITextField *amountTextField;
@property (nonatomic, weak) IBOutlet UITextField *currencyTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *descriptionTextField;
    
@property (nonatomic, weak) IBOutlet PSCardNumberTextField *cardNumberTextField;
@property (nonatomic, weak) IBOutlet PSExpMonthTextField *expMonthTextField;
@property (nonatomic, weak) IBOutlet PSExpYearTextField *expYearTextField;
@property (nonatomic, weak) IBOutlet PSCVVTextField *cvvTextField;
    
@property (nonatomic, weak) IBOutlet PSCardInputLayout *cardInputLayout;
@property (nonatomic, strong) PSCloudipspWKWebView *webView;
@property (nonatomic, strong) PSCloudipspApi *api;

@property (nonatomic, strong) UIPickerView *pickerView;

@end

@implementation CDCustomStoryboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPickerView];
    [self setupWebView];
    self.api = [PSCloudipspApi apiWithMerchant:1396424 andCloudipspView:self.webView];
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
    [self.cardInputLayout test];
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
        PSCard *card = [self.cardInputLayout confirm:self];
        if (card != nil) {
            [self taskWillStarted];
            [self.api pay:card withOrder:order andDelegate:self];
        }
    }
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
    
#pragma mark - UITextFieldDelegate
    
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:[self.fields lastObject]]) {
        [textField resignFirstResponder];
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
    [self.cardInputLayout clear];
}

@end

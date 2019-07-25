//
//  CDCustomProgrammaticallyViewController.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 6/30/17.
//  Copyright © 2017 Nadiia. All rights reserved.
//

#import "CDCustomProgramViewController.h"
#import "CDResultViewController.h"
#import <Cloudipsp/PSCloudipsp.h>

@interface CDCustomProgramViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, PSPayCallbackDelegate, PSConfirmationErrorHandler>

@property (nonatomic, strong)NSMutableArray<UITextField *> *fields;

@property (nonatomic, strong) PSCardNumberTextField *cardNumberTextField;
@property (nonatomic, strong) PSExpMonthTextField *expMonthTextField;
@property (nonatomic, strong) PSExpYearTextField *expYearTextField;
@property (nonatomic, strong) PSCVVTextField *cvvTextField;
    
@property (nonatomic, strong) UITextField *amountTextField;
@property (nonatomic, strong) UITextField *currencyTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *descriptionTextField;

@property (nonatomic, strong) PSCardInputLayout *cardInputLayout;
@property (nonatomic, strong) PSCloudipspWKWebView *webView;
@property (nonatomic, strong) PSCloudipspApi *api;
    
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIBarButtonItem *testBarButtonItem;
@property (nonatomic, strong) UIButton *payButton;
    
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) UIView *lockView;
    
@end

@implementation CDCustomProgramViewController
    
- (instancetype)init
    {
        self = [super init];
        if (self) {
            self.view.backgroundColor = [UIColor whiteColor];
        }
        return self;
    }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fields = [NSMutableArray array];
    self.navigationItem.title = @"Custom Programmatically";
    
    // TEST CONTROL
    self.testBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(test:)];
    self.navigationItem.rightBarButtonItem = self.testBarButtonItem;
    
    // SCROLL
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    // FIELDS
    self.amountTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 72, 280, 30)];
    self.amountTextField.delegate = self;
    self.amountTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.amountTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.amountTextField.returnKeyType = UIReturnKeyNext;
    self.amountTextField.placeholder = @"amount";
    self.amountTextField.font = [UIFont systemFontOfSize:14.f];
    [self.scrollView addSubview:self.amountTextField];
    [self.fields addObject:self.amountTextField];
    
    self.currencyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 110, 280, 30)];
    self.currencyTextField.delegate = self;
    self.currencyTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.currencyTextField.returnKeyType = UIReturnKeyNext;
    self.currencyTextField.placeholder = @"currency";
    self.currencyTextField.font = [UIFont systemFontOfSize:14.f];
    [self.scrollView addSubview:self.currencyTextField];
    [self.fields addObject:self.currencyTextField];
    
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 148, 280, 30)];
    self.emailTextField.delegate = self;
    self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.placeholder = @"email";
    self.emailTextField.font = [UIFont systemFontOfSize:14.f];
    [self.scrollView addSubview:self.emailTextField];
    [self.fields addObject:self.emailTextField];
    
    self.descriptionTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 186, 280, 30)];
    self.descriptionTextField.delegate = self;
    self.descriptionTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.descriptionTextField.returnKeyType = UIReturnKeyNext;
    self.descriptionTextField.placeholder = @"description";
    self.descriptionTextField.font = [UIFont systemFontOfSize:14.f];
    [self.scrollView addSubview:self.descriptionTextField];
    [self.fields addObject:self.descriptionTextField];

    // LAYOUT FIELDS
    self.cardNumberTextField = [[PSCardNumberTextField alloc] initWithFrame:CGRectMake(20, 8, 280, 30)];
    self.cardNumberTextField.placeholder = @"Card Number";
    [self.fields addObject:self.cardNumberTextField];
    
    self.expMonthTextField = [[PSExpMonthTextField alloc] initWithFrame:CGRectMake(20, 46, 136, 30)];
    self.expMonthTextField.placeholder = @"MM";
    [self.fields addObject:self.expMonthTextField];
    
    self.expYearTextField = [[PSExpYearTextField alloc] initWithFrame:CGRectMake(164, 46, 136, 30)];
    self.expYearTextField.placeholder = @"YY";
    [self.fields addObject:self.expYearTextField];
    
    self.cvvTextField = [[PSCVVTextField alloc] initWithFrame:CGRectMake(20, 84, 280, 30)];
    self.cvvTextField.placeholder = @"CVV";
    [self.fields addObject:self.cvvTextField];
    
    self.cardInputLayout = [[PSCardInputLayout alloc] initWithFrame:CGRectMake(0, 216, 320, 122)
                                                cardNumberTextField:self.cardNumberTextField
                                                  expMonthTextField:self.expMonthTextField
                                                   expYearTextField:self.expYearTextField
                                                       cvvTextField:self.cvvTextField];
    [self.scrollView addSubview:self.cardInputLayout];
    
    // PAY CONTROL
    self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.cardInputLayout.frame), 280, 30)];
    [self.payButton setTitle:@"Pay" forState:UIControlStateNormal];
    [self.payButton setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:204.f/255.f blue:102.f/255.f alpha:1.0]];
    self.payButton.layer.cornerRadius = 5.f;
    [self.payButton addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.payButton];

    // CONTENT SIZE
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.payButton.frame) + 8);
    [self registerForKeyboardNotifications];
    
    // PICKERVIEW & WEBVIEW
    [self setupPickerView];
    [self setupWebView];
    
    // INDICATOR
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.color = [UIColor colorWithRed:255.f/255.f green:204.f/255.f blue:102.f/255.f alpha:1.0];
    self.indicatorView.hidden = YES;
    self.indicatorView.center = self.view.center;
    [self.view insertSubview:self.indicatorView aboveSubview:self.scrollView];
    
    // API
    self.api = [PSCloudipspApi apiWithMerchant:1396424 andCloudipspView:self.webView];
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
    
#pragma mark - Setup WebView
    
- (void)setupWebView {
    self.webView = [[PSCloudipspWKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 66)];
    [self.view insertSubview:self.webView aboveSubview:self.scrollView];
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
    [self navigate];
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
    [self navigate];
    [self taskDidFinished];
}
    
- (void)onWaitConfirm {
    [self taskDidFinished];
}
    
- (void)navigate {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    CDResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
    vc.result = self.result;
    [self presentViewController:vc animated:YES completion:nil];
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

@end

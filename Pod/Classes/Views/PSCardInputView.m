//
//  PSCardInputView.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "PSCardNumberTextField.h"
#import "PSCardInputView.h"
#import "PSLocalization.h"
#import "PSCloudipspApi.h"
#import "PSCard.h"


@interface PSCard (private)

+ (instancetype)cardWith:(NSString *)cardNumber
                expireMm:(int)mm
                expireYy:(int)yy
                    aCvv:(NSString *)cvv;

@end

@interface PSDefaultConfirmationErrorHandler : NSObject<PSConfirmationErrorHandler>

@end

@implementation PSDefaultConfirmationErrorHandler


- (void)onCardInputErrorClear:(PSCardInputView *)cardInputView
                   aTextField:(UITextField *)textField {
    
}

- (void)onCardInputErrorCatched:(PSCardInputView *)cardInputView
                     aTextField:(UITextField *)textField
                         aError:(PSConfirmationError)error {
    
}

@end

@interface PSCardInputView ()

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *fields;
@property (nonatomic, strong) IBOutlet UILabel *cardNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *expiryLabel;
@property (nonatomic, strong) IBOutlet UILabel *cvvLabel;
@property (nonatomic, assign) NSInteger iter;

@end

@implementation PSCardInputView

- (void)setupView {
    @try {
        [[[NSBundle bundleForClass:[PSCardInputView class]] loadNibNamed:@"PSCardInputView" owner:self options:nil] firstObject];
        [self.view setFrame:self.bounds];
        [self setUpLocalization:[PSCloudipspApi getLocalization]];
        [self addSubview:self.view];
    }
    @catch (NSException *exception) {
        [NSException exceptionWithName:@"PSCardInputViewExeption" reason:exception.reason userInfo:nil];
    }
}

- (void)setUpLocalization:(PSLocalization *)localization {
    self.cardNumberLabel.text = localization.cardNumber;
    self.expiryLabel.text = localization.expiry;
    self.expMonthTextField.placeholder = localization.month;
    self.expYearTextField.placeholder = localization.year;
    self.cvvLabel.text = localization.cvv;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)clear {
    self.cardNumberTextField.text = @"";
    self.expMonthTextField.text = @"";
    self.expYearTextField.text = @"";
    self.cvvTextField.text = @"";
}

- (PSCard *)confirm {
    return [self confirm:[[PSDefaultConfirmationErrorHandler alloc] init]];
}

- (void)test {
    switch (self.iter) {
        case 0:
            self.cardNumberTextField.text = @"4444111166665555";
            self.expMonthTextField.text = @"10";
            self.expYearTextField.text = @"18";
            self.cvvTextField.text = @"456";
            self.iter++;
            break;
        case 1:
            self.cardNumberTextField.text = @"4444555511116666";
            self.expMonthTextField.text = @"09";
            self.expYearTextField.text = @"19";
            self.cvvTextField.text = @"789";
            self.iter++;
            break;
        case 2:
            self.cardNumberTextField.text = @"4444111155556666";
            self.expMonthTextField.text = @"08";
            self.expYearTextField.text = @"20";
            self.cvvTextField.text = @"149";
            self.iter++;
            break;
        case 3:
            self.cardNumberTextField.text = @"4444555566661111";
            self.expMonthTextField.text = @"11";
            self.expYearTextField.text = @"17";
            self.cvvTextField.text = @"123";
            self.iter = 0;
            break;
        default:
            break;
    }
}

- (PSCard *)confirm:(id<PSConfirmationErrorHandler>)errorHandler {
    [errorHandler onCardInputErrorClear:self aTextField:self.cardNumberTextField];
    [errorHandler onCardInputErrorClear:self aTextField:self.expMonthTextField];
    [errorHandler onCardInputErrorClear:self aTextField:self.expYearTextField];
    [errorHandler onCardInputErrorClear:self aTextField:self.cvvTextField];
    
    NSCharacterSet *validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *cardNumber = [NSMutableString stringWithString:[[self.cardNumberTextField.text componentsSeparatedByCharactersInSet:validationSet] componentsJoinedByString:@""]];
    
    PSCard *card = [PSCard cardWith:cardNumber
                       expireMm:[self.expMonthTextField.text intValue]
                       expireYy:[self.expYearTextField.text intValue]
                           aCvv:self.cvvTextField.text];
    
    if (![card isValidCardNumber]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.cardNumberTextField
                                       aError:PSConfirmationErrorInvalidCardNumber];
    } else if (![card isValidExpireMonth]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.expMonthTextField
                                       aError:PSConfirmationErrorInvalidMm];
    } else if (![card isValidExpireYear]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.expYearTextField
                                       aError:PSConfirmationErrorInvalidYy];
    } else if (![card isValidExpireDate]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.expMonthTextField
                                       aError:PSConfirmationErrorInvalidDate];
    } else if (![card isValidCvv]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.cvvTextField
                                       aError:PSConfirmationErrorInvalidCvv];
    } else {
        return card;
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray *components = [string componentsSeparatedByCharactersInSet:validationSet];
    if ([components count] > 1) {
        return NO;
    }
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    if ([textField isEqual:self.expMonthTextField] || [textField isEqual:self.expYearTextField]) {
        if (newLength > 2) {
            return NO;
        }
        return YES;
    }
    if ([textField isEqual:self.cvvTextField]) {
        if (newLength > 3) {
            return NO;
        }
        return YES;
    }
    if ([textField isEqual:self.cardNumberTextField]) {
        NSString *fullStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSMutableString *resultString = [NSMutableString stringWithString:[[fullStr componentsSeparatedByCharactersInSet:validationSet] componentsJoinedByString:@""]];
        static const int separatorLength = 4;
        if ([resultString length] > separatorLength*4) {
            return NO;
        }
        if ([resultString length] > separatorLength*3) {
            [resultString insertString:@" " atIndex:4];
            [resultString insertString:@" " atIndex:9];
            [resultString insertString:@" " atIndex:14];
        }
        else if ([resultString length] > separatorLength*2) {
            [resultString insertString:@" " atIndex:4];
            [resultString insertString:@" " atIndex:9];
        }
        else if ([resultString length] > separatorLength) {
            [resultString insertString:@" " atIndex:4];
        }
        textField.text = resultString;
    }
    return NO;
}

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

@end

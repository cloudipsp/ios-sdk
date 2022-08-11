//
//  PSCardInputLayout.m
//  Pods
//
//  Created by Nadiia Dovbysh on 6/27/17.
//
//

#import "PSCard.h"
#import "PSLocalization.h"
#import "PSCloudipspApi.h"
#import "PSUtils.h"

#import "PSCardInputLayout.h"
#import "PSCardNumberTextField.h"
#import "PSExpMonthTextField.h"
#import "PSExpYearTextField.h"
#import "PSCVVTextField.h"
#import "PSEmailTextField.h"

#pragma mark - PSCard

@interface PSCard (private)
    
+ (instancetype)cardWith:(NSString *)cardNumber
                expireMm:(int)mm
                expireYy:(int)yy
                     cvv:(NSString *)cvv
                   email:(NSString *)email;
    
@end

#pragma mark - PSCardInputLayout

@interface PSCardInputLayout ()

@property (nonatomic, weak) PSCardNumberTextField *cardNumberTextField;
@property (nonatomic, weak) PSExpMonthTextField *expMonthTextField;
@property (nonatomic, weak) PSExpYearTextField *expYearTextField;
@property (nonatomic, weak) PSCVVTextField *cvvTextField;
@property (nonatomic, weak) PSEmailTextField *emailTextField;
@property (nonatomic, assign) NSInteger iter;
    
@end

@implementation PSCardInputLayout

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
          cardNumberTextField:(PSCardNumberTextField *)cardNumberTextField
            expMonthTextField:(PSExpMonthTextField *)expMonthTextField
             expYearTextField:(PSExpYearTextField *)expYearTextField
                 cvvTextField:(PSCVVTextField *)cvvTextField {
    return [self initWithFrame:frame
           cardNumberTextField:cardNumberTextField
             expMonthTextField:expMonthTextField
              expYearTextField:expYearTextField
                  cvvTextField:cvvTextField
                emailTextField:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
          cardNumberTextField:(PSCardNumberTextField *)cardNumberTextField
            expMonthTextField:(PSExpMonthTextField *)expMonthTextField
             expYearTextField:(PSExpYearTextField *)expYearTextField
                 cvvTextField:(PSCVVTextField *)cvvTextField
               emailTextField:(PSEmailTextField *)emailTextField
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:cardNumberTextField];
        [self addSubview:expMonthTextField];
        [self addSubview:expYearTextField];
        [self addSubview:cvvTextField];
        if (emailTextField != nil) {
            [self addSubview:emailTextField];
        }
        [self setup];
    }
    return self;
}
    
- (void)setup {
    self.cardNumberTextField = [self findOne:[PSCardNumberTextField class]];
    self.expMonthTextField = [self findOne:[PSExpMonthTextField class]];
    self.expYearTextField = [self findOne:[PSExpYearTextField class]];
    self.cvvTextField = [self findOne:[PSCVVTextField class]];
    @try {
        self.emailTextField = [self findOne:[PSEmailTextField class]];
    } @catch (NSException *e) {
    }
}
    
- (id)findOne:(Class)fieldClass {
    NSMutableArray *views = [NSMutableArray array];
    [self find:fieldClass aParent:self aFields:views];
    NSUInteger count = views.count;
    
    if (count == 0) {
        NSString *reason = [NSString stringWithFormat:@"%@ should contains %@", NSStringFromClass([self class]), NSStringFromClass(fieldClass)];
        @throw [NSException exceptionWithName:@"PSMissingTextFieldException"
                                       reason:reason
                                     userInfo:nil];
    }
    
    if (count > 1) {
        NSString *reason = [NSString stringWithFormat:@"%@ should contains only one view %@. Now here %lu instances of %@", NSStringFromClass([self class]), NSStringFromClass(fieldClass), (unsigned long)count, NSStringFromClass(fieldClass)];
        @throw [NSException exceptionWithName:@"PSUnsupportedOperationExeption" reason:reason userInfo:nil];
    }
    return [views firstObject];
}
    
- (void)find:(Class)fieldClass aParent:(UIView *)parent aFields:(inout NSMutableArray *)fields {
    for (id view in parent.subviews) {
        if ([view isKindOfClass:fieldClass]) {
            [fields addObject:view];
        } else {
            [self find:fieldClass aParent:view aFields:fields];
        }
    }
}
    
- (void)clear {
    self.cardNumberTextField.text = @"";
    self.expMonthTextField.text = @"";
    self.expYearTextField.text = @"";
    self.cvvTextField.text = @"";
    if (self.emailTextField) {
        self.emailTextField.text = @"";
    }
}

- (PSCard *)confirm {
    return [self confirm:[[PSDefaultConfirmationErrorHandler alloc] init]];
}
    
- (void)test {
    switch (self.iter) {
        case 0:
        self.cardNumberTextField.text = @"4444111166665555";
        self.expMonthTextField.text = @"10";
        self.expYearTextField.text = @"24";
        self.cvvTextField.text = @"456";
        self.iter++;
        break;
        case 1:
        self.cardNumberTextField.text = @"4444555511116666";
        self.expMonthTextField.text = @"09";
        self.expYearTextField.text = @"24";
        self.cvvTextField.text = @"789";
        self.iter++;
        break;
        case 2:
        self.cardNumberTextField.text = @"4444111155556666";
        self.expMonthTextField.text = @"08";
        self.expYearTextField.text = @"24";
        self.cvvTextField.text = @"149";
        self.iter++;
        break;
        case 3:
        self.cardNumberTextField.text = @"4444555566661111";
        self.expMonthTextField.text = @"11";
        self.expYearTextField.text = @"24";
        self.cvvTextField.text = @"123";
        self.iter++;
        break;
        case 4:
        self.cardNumberTextField.text = @"378282246310005";
        self.expMonthTextField.text = @"11";
        self.expYearTextField.text = @"24";
        self.cvvTextField.text = @"123";
        self.iter = 0;
        break;
        default:
        break;
    }
    if (self.emailTextField != nil) {
        self.emailTextField.text = @"example@test.com";
    }
}
    
- (PSCard *)confirm:(id<PSConfirmationErrorHandler>)errorHandler {
    return [self confirm:errorHandler singleShotValidation:YES];
}
    
- (PSCard *)confirm:(id<PSConfirmationErrorHandler>)errorHandler singleShotValidation:(BOOL)singleShotValidation {
    [errorHandler onCardInputErrorClear:self aTextField:self.cardNumberTextField];
    [errorHandler onCardInputErrorClear:self aTextField:self.expMonthTextField];
    [errorHandler onCardInputErrorClear:self aTextField:self.expYearTextField];
    [errorHandler onCardInputErrorClear:self aTextField:self.cvvTextField];
    if (self.emailTextField != nil) {
        [errorHandler onCardInputErrorClear:self aTextField:self.emailTextField];
    }
    
    NSCharacterSet *validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *cardNumber = [NSMutableString stringWithString:[[self.cardNumberTextField.text componentsSeparatedByCharactersInSet:validationSet] componentsJoinedByString:@""]];
    
    PSCard *card = [PSCard cardWith:cardNumber
                           expireMm:[self.expMonthTextField.text intValue]
                           expireYy:[self.expYearTextField.text intValue]
                                cvv:self.cvvTextField.text
                              email:self.emailTextField == nil ? nil : self.emailTextField.text];
    
    BOOL cardValidated = YES;
    if (![card isValidCardNumber]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.cardNumberTextField
                                       aError:PSConfirmationErrorInvalidCardNumber];
        if (singleShotValidation) {
            return nil;
        } else {
            cardValidated = NO;
        }
    }
    if (![card isValidExpireMonth]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.expMonthTextField
                                       aError:PSConfirmationErrorInvalidMm];
        if (singleShotValidation) {
            return nil;
        } else {
            cardValidated = NO;
        }
    }
    if (![card isValidExpireYear]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.expYearTextField
                                       aError:PSConfirmationErrorInvalidYy];
        if (singleShotValidation) {
            return nil;
        } else {
            cardValidated = NO;
        }
    }
    if (![card isValidExpireDate]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.expMonthTextField
                                       aError:PSConfirmationErrorInvalidDate];
        if (singleShotValidation) {
            return nil;
        } else {
            cardValidated = NO;
        }
    }
    if (![card isValidCvv]) {
        [errorHandler onCardInputErrorCatched:self
                                   aTextField:self.cvvTextField
                                       aError:PSConfirmationErrorInvalidCvv];
        if (singleShotValidation) {
            return nil;
        } else {
            cardValidated = NO;
        }
    }
    if (cardValidated) {
        return card;
    }

    return nil;
}
    
- (BOOL)lengthHandlerFor:(UITextField *)textField aNewString:(NSString *)newString aMaxLength:(NSUInteger)maxLength {
    if ([textField isKindOfClass: [PSCVVTextField class]]) {
        return newString.length <= [self cvvMaxLength: self.cardNumberTextField.text];
    }
    if ([textField isKindOfClass: [PSCardNumberTextField class]]) {
        if (self.cvvTextField.text.length > [self cvvMaxLength: newString]) {
            self.cvvTextField.text = [self.cvvTextField.text substringToIndex:3];
        }
    }
    return newString.length <= maxLength;
}
    
- (NSUInteger)cvvMaxLength:(NSString *)cardNumber {
    return [PSUtils isCvv4Length:cardNumber] ? 4 : 3;
}

@end

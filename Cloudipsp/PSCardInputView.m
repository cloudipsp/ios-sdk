//
//  PSCardInputView.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "PSCard.h"
#import "PSCloudipspApi.h"
#import "PSLocalization.h"
#import "PSCardNumberTextField.h"
#import "PSExpMonthTextField.h"
#import "PSExpYearTextField.h"
#import "PSCVVTextField.h"
#import "PSEmailTextField.h"
#import "PSCardInputLayout.h"
#import "PSCardInputView.h"



#pragma mark - PSCard

@interface PSCard (private)

+ (instancetype)cardWith:(NSString *)cardNumber
                expireMm:(int)mm
                expireYy:(int)yy
                    aCvv:(NSString *)cvv;

@end

#pragma mark - PSCardInputView

@interface PSCardInputView ()



@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *fields;
@property (nonatomic, strong) IBOutlet UILabel *cardNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *expiryLabel;
@property (nonatomic, strong) IBOutlet UILabel *cvvLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet PSEmailTextField *emailTextInput;
@property (nonatomic, weak) IBOutlet PSCardInputLayout *cardInputLayout;
@property (strong, nonnull) NSArray<NSLayoutConstraint *> *emailConstraints;


@end

@implementation PSCardInputView

- (void)setupView {
    self.emailConstraints = @[];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[[NSBundle bundleForClass:[PSCardInputView class]] loadNibNamed:@"PSCardInputView" owner:self options:nil] firstObject];
    [self.view setFrame:self.bounds];
    [self setUpLocalization:[PSCloudipspApi getLocalization]];
    [self addSubview:self.view];
}

-(void)setEmailVisibility:(BOOL)visible {
    if (self.emailConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.emailConstraints];
    }

    if (visible) {
        [self.cardInputLayout addSubview:self.emailLabel];
        [self.cardInputLayout addSubview:self.emailTextInput];

        self.emailConstraints = @[
            [self.emailLabel.leadingAnchor constraintEqualToAnchor:self.cardInputLayout.leadingAnchor constant:20.0f],
            [self.emailLabel.trailingAnchor constraintEqualToAnchor:self.cardInputLayout.trailingAnchor constant:20.0f],
            [self.emailLabel.topAnchor constraintEqualToAnchor:self.cvvTextField.bottomAnchor constant:8.0f],

            [self.emailTextInput.leadingAnchor constraintEqualToAnchor:self.cardInputLayout.leadingAnchor constant:20.0f],
            [self.emailTextInput.trailingAnchor constraintEqualToAnchor:self.cardInputLayout.trailingAnchor constant:20.0f],
            [self.emailTextInput.topAnchor constraintEqualToAnchor:self.emailLabel.bottomAnchor constant:8.0f],


            [self.cardInputLayout.bottomAnchor constraintEqualToAnchor:self.emailTextInput.bottomAnchor]
        ];
    } else {
        [self.emailLabel removeFromSuperview];
        [self.emailTextInput removeFromSuperview];
        self.emailConstraints = @[
            [self.cardInputLayout.bottomAnchor constraintEqualToAnchor:self.cvvTextField.bottomAnchor]
        ];
    }
    [NSLayoutConstraint activateConstraints:self.emailConstraints];
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

- (void)adaptForApi:(PSCloudipspApi *)api
        andCurrency:(NSString *)currency {
    [api isPayerEmailRequiredForCurrency:currency withCallback:^(BOOL isRequired, NSError *error) {
        if (error) {
            return;
        }
        [self setEmailVisibility:isRequired];
    }];
}
- (void)adaptForApi:(PSCloudipspApi *)api
           andToken:(NSString *)token {
    [api isPayerEmailRequiredForToken:token withCallback:^(BOOL isRequired, NSError *error) {
        if (error) {
            return;
        }
        [self setEmailVisibility:isRequired];
    }];
}

- (void)clear {
    [self.cardInputLayout clear];
}

- (PSCard *)confirm {
    return [self.cardInputLayout confirm:[[PSDefaultConfirmationErrorHandler alloc] init]];
}


- (void)test {
    [self.cardInputLayout test];
}

- (PSCard *)confirm:(id<PSConfirmationErrorHandler>)errorHandler {
    return [self.cardInputLayout confirm:errorHandler];
}

- (PSCard *)confirm:(id<PSConfirmationErrorHandler>)errorHandler singleShotValidation:(BOOL)singleShotValidation {
    return [self.cardInputLayout confirm:errorHandler singleShotValidation:singleShotValidation];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:[self.fields lastObject]]) {
        [textField resignFirstResponder];
        [self.inputDelegate didEndEditing:self];
    } else {
        [textField resignFirstResponder];
        UITextField *next = [self.fields objectAtIndex:[self.fields indexOfObject:textField] + 1];
        [next becomeFirstResponder];
    }
    return YES;
}

@end

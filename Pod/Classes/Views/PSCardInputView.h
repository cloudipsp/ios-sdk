//
//  PSCardInputView.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSCardInputView;

typedef enum : NSUInteger {
    PSConfirmationErrorInvalidCardNumber,
    PSConfirmationErrorInvalidMm,
    PSConfirmationErrorInvalidYy,
    PSConfirmationErrorInvalidDate,
    PSConfirmationErrorInvalidCvv
} PSConfirmationError;

@protocol PSConfirmationErrorHandler <NSObject>

- (void)onCardInputErrorClear:(PSCardInputView *)cardInputView
                   aTextField:(UITextField *)textField;

- (void)onCardInputErrorCatched:(PSCardInputView *)cardInputView
                     aTextField:(UITextField *)textField
                         aError:(PSConfirmationError)error;

@end

@class PSCardNumberTextField;
@class PSCard;

@interface PSCardInputView : UIView

@property (nonatomic, weak) IBOutlet PSCardNumberTextField *cardNumberTextField;
@property (nonatomic, weak) IBOutlet UITextField *expMonthTextField;
@property (nonatomic, weak) IBOutlet UITextField *expYearTextField;
@property (nonatomic, weak) IBOutlet UITextField *cvvTextField;
@property (nonatomic, strong) IBOutlet UIView *view;

- (void)clear;
- (PSCard *)confirm;
- (PSCard *)confirm:(id<PSConfirmationErrorHandler>)errorHandler;
- (void)test;

@end
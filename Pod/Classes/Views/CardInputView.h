//
//  CardInputView.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardInputView;

typedef enum : NSUInteger {
    ConfirmationErrorInvalidCardNumber,
    ConfirmationErrorInvalidMm,
    ConfirmationErrorInvalidYy,
    ConfirmationErrorInvalidDate,
    ConfirmationErrorInvalidCvv
} ConfirmationError;

@protocol ConfirmationErrorHandler <NSObject>

- (void)onCardInputErrorClear:(CardInputView *)cardInputView
                   aTextField:(UITextField *)textField;

- (void)onCardInputErrorCatched:(CardInputView *)cardInputView
                     aTextField:(UITextField *)textField
                         aError:(ConfirmationError)error;

@end

@class CardNumberTextField;
@class Card;

@interface CardInputView : UIView

@property (nonatomic, weak, readonly) IBOutlet CardNumberTextField *cardNumberTextField;
@property (nonatomic, weak, readonly) IBOutlet UITextField *expMonthTextField;
@property (nonatomic, weak, readonly) IBOutlet UITextField *expYearTextField;
@property (nonatomic, weak, readonly) IBOutlet UITextField *cvvTextField;

- (void)clear;
- (Card *)confirm;
- (Card *)confirm:(id<ConfirmationErrorHandler>)errorHandler;
- (void)test;

@end

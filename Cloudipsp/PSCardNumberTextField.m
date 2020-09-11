//
//  PSCardNumberEdit.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "PSCardNumberTextField.h"
#import "PSTextFieldHandler.h"

@interface PSCardNumberFieldHandler : PSTextFieldHandler

-(instancetype)init;
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end

@implementation PSCardNumberFieldHandler

NSString *previousTextFieldContent;
UITextRange *previousSelection;

-(instancetype)init {
    return [super initWith:19];
}

-(void)reformatAsCardNumber:(UITextField *)textField
{
    NSUInteger targetCursorPosition =
        [textField offsetFromPosition:textField.beginningOfDocument
                           toPosition:textField.selectedTextRange.start];

    NSString *cardNumberWithoutSpaces =
        [self removeNonDigits:textField.text
                  andPreserveCursorPosition:&targetCursorPosition];

    if ([cardNumberWithoutSpaces length] > 19) {
        [textField setText:previousTextFieldContent];
        textField.selectedTextRange = previousSelection;
        return;
    }

    NSString *cardNumberWithSpaces =
        [self insertCreditCardSpaces:cardNumberWithoutSpaces
           andPreserveCursorPosition:&targetCursorPosition];

    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
        [textField positionFromPosition:[textField beginningOfDocument]
                                 offset:targetCursorPosition];

    [textField setSelectedTextRange:
        [textField textRangeFromPosition:targetPosition
                              toPosition:targetPosition]
    ];
}

-(BOOL)textField:(UITextField *)textField
         shouldChangeCharactersInRange:(NSRange)range
                     replacementString:(NSString *)string
{
    previousTextFieldContent = textField.text;
    previousSelection = textField.selectedTextRange;

    return YES;
}

- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i = 0; i < [string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
        } else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    return digitsOnlyString;
}

- (NSString *)insertCreditCardSpaces:(NSString *)string
           andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i = 0; i < [string length]; i++) {
        if (i > 0 && (i % 4) == 0) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];

        [stringWithAddedSpaces appendString:stringToAdd];
    }

    return stringWithAddedSpaces;
}

@end

@implementation PSCardNumberTextField

- (PSTextFieldHandler *)setup {
    PSCardNumberFieldHandler* handler = [[PSCardNumberFieldHandler alloc] init];
    [self addTarget:handler action:@selector(reformatAsCardNumber:) forControlEvents:UIControlEventEditingChanged];
    return handler;
}

@end

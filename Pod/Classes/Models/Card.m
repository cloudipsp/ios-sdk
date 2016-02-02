//
//  Card.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "Card.h"

NSString *stringWithCardType(CardType type) {
    NSArray *arr = @[
                     @"UNKNOWN",
                     @"VISA",
                     @"MASTERCARD",
                     @"MAESTRO"
                     ];
    return (NSString *)[arr objectAtIndex:type];
}

CardType cardTypeWithString(NSString *str) {
    NSArray *arr = @[
                     @"UNKNOWN",
                     @"VISA",
                     @"MASTERCARD",
                     @"MAESTRO"
                     ];
    return (CardType)[arr indexOfObject:str];
}

@interface Card ()

@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, assign) int mm;
@property (nonatomic, assign) int yy;
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, assign) CardType type;

@end

@implementation Card

+ (instancetype)cardWith:(NSString *)cardNumber
                expireMm:(int)mm
                expireYy:(int)yy
                    aCvv:(NSString *)cvv
{
    Card * card = [[Card alloc] init];
    card.cardNumber = cardNumber;
    card.mm = mm;
    card.yy = yy;
    card.cvv = cvv;
    return card;
}

- (CardType)cardType:(NSString *)cardNumber {
    if ([cardNumber characterAtIndex:0] == '4') {
        return _type = CardTypeVisa;
    } else if ('0' <= [cardNumber characterAtIndex:1] && [cardNumber characterAtIndex:1] <= '5') {
        return _type = CardTypeMastercard;
    } else if ([cardNumber characterAtIndex:0] == '6') {
        return _type = CardTypeMaestro;
    } else {
        return _type = CardTypeUnknown;
    }
}

- (BOOL)isValidExpireMonth {
    return self.mm >= 1 && self.mm <= 12;
}

- (BOOL)isValidExpireYearValue {
    return self.yy >= 15 && self.yy <= 99;
}

- (BOOL)isValidExpireYear {
    if (![self isValidExpireYearValue]) {
        return false;
    }
    NSInteger year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:NSDate.date] - 2000;
    return year <= self.yy;
}


- (BOOL)isValidExpireDate {
    if (![self isValidExpireMonth]) {
        return NO;
    }
    if (![self isValidExpireYear]) {
        return NO;
    }
    
    NSInteger year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:NSDate.date] - 2000;
    NSInteger month = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:NSDate.date];
    
    return (self.yy >= year && self.mm >= month);
}

- (BOOL)isValidCvv {
    return self.cvv != nil && self.cvv.length == 3;
}

- (BOOL)lunaCheck:(NSString *)cardNumber {
    NSInteger sum = 0;
    NSInteger num;
    char *chars = (char *)[cardNumber dataUsingEncoding:NSUTF8StringEncoding].bytes;

    for (int i = 0; i < 16; i += 2) {
        char a = (char)chars[i];
        char b = (char)chars[i + 1];
        
        if (!(('0' <= a && a <= '9') && ('0' <= b && b <= '9'))) {
            return false;
        }
        num = (a - '0') * 2;
        if (num > 9) {
            num -= 9;
        }
        sum += num + (b - '0');
    }
    return sum % 10 == 0;
}

- (BOOL)isValidCardNumber {
    if (self.cardNumber == nil || self.cardNumber.length != 16) {
        return false;
    }

    if ([self cardType:self.cardNumber] == CardTypeUnknown) {
        return false;
    }
    
    if (![self lunaCheck:self.cardNumber]) {
        return false;
    }
    
    return true;
}


- (BOOL)isValidCard {
    return [self isValidExpireDate] && [self isValidCvv] && [self isValidCardNumber];
}

- (NSString *)getFormattedCardNumber {
    if (![self isValidCardNumber]) {
        @throw [NSException exceptionWithName:@"IllegalCardNumberException" reason:@"CardNumber should be valid before formatting" userInfo:nil];
    }
    NSMutableString *newStr = [NSMutableString stringWithCapacity:20];

    for (NSInteger i = 0; i < 16; i += 4) {
        if (i != 0) {
            [newStr appendString:@" "];
        }
        [newStr appendString:[self.cardNumber substringWithRange:NSMakeRange(i, 4)]];
    }
    return newStr;
}

- (CardType)type {
    if (![self isValidCardNumber]) {
        @throw [NSException exceptionWithName:@"IllegalCardNumberException" reason:@"CardNumber should be valid before for getType" userInfo:nil];
    }
    return _type;
}

+ (NSString *)getCardTypeName:(CardType)type {
    return stringWithCardType(type);
}

+ (CardType)getCardType:(NSString *)typeName {
    return cardTypeWithString(typeName);
}


@end

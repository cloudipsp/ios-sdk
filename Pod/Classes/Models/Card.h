//
//  Card.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CardTypeUnknown,
    CardTypeVisa,
    CardTypeMastercard,
    CardTypeMaestro,
} CardType;

@interface Card : NSObject

@property (nonatomic, assign, readwrite) int mm;
@property (nonatomic, assign, readwrite) int yy;
@property (nonatomic, strong, readwrite) NSString *cvv;
@property (nonatomic, assign, readwrite) CardType type;
@property (nonatomic, strong) NSString *cardNumber;

- (BOOL)isValidExpireMonth;
- (BOOL)isValidExpireYear;
- (BOOL)isValidExpireDate;
- (BOOL)isValidCvv;
- (BOOL)isValidCardNumber;
- (BOOL)isValidCard;

+ (NSString *)getCardTypeName:(CardType)type;
+ (CardType)getCardType:(NSString *)typeName;

@end

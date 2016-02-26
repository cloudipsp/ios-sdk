//
//  Order.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

#pragma clang diagnostic ignored "-Wnullability-completeness"

typedef enum : NSUInteger {
    VerificationUnknown = 0,
    VerificationAmount,
    VerificationCode
} Verification;

typedef enum : NSUInteger {
    LangUnknown = 0,
    LangRu,
    LangUk,
    LangEn,
    LangLv,
    LangFr
} Lang;

@interface Order : NSObject

@property (nonatomic, assign, readonly) NSInteger amount;
@property (nonatomic, assign, readonly) Currency currency;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *about;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSDictionary *arguments;

@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *paymentSystems;
@property (nonatomic, strong) NSString *defaultPaymentSystem;
@property (nonatomic, assign) NSInteger lifetime;
@property (nonatomic, strong) NSString *merchantData;
@property (nonatomic, assign) BOOL preauth;
@property (nonatomic, assign) BOOL requiredRecToken;
@property (nonatomic, assign) BOOL verification;
@property (nonatomic, assign) Verification verificationType;
@property (nonatomic, strong) NSString *recToken;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, assign) Lang lang;
@property (nonatomic, strong) NSString *serverCallbackUrl;

- (instancetype)initOrder:(NSInteger)amount
                aCurrency:(Currency)currency
              aIdentifier:(NSString * _Nonnull )identifier
                   aAbout:(NSString * _Nonnull )about
                   aEmail:(NSString * _Nonnull )email;

+ (NSString *)getLangName:(Lang)lang;
+ (NSString *)getVerificationName:(Verification)verification;
+ (Verification)getVerificationSign:(NSString *)verificationName;

@end

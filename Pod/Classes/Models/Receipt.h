//
//  Receipt.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Currency.h"

typedef enum : NSUInteger {
    ReceiptStatusUnknown,
    ReceiptStatusCreated,
    ReceiptStatusProcessing,
    ReceiptStatusDeclined,
    ReceiptStatusApproved,
    ReceiptStatusExpired,
    ReceiptStatusReversed
} ReceiptStatus;

typedef enum : NSUInteger {
    ReceiptTransationTypeUnknown,
    ReceiptTransationTypePurchase,
    ReceiptTransationTypeReverse
} ReceiptTransationType;


typedef enum : NSUInteger {
    ReceiptVerificationStatusUnknown,
    ReceiptVerificationStatusVerified,
    ReceiptVerificationStatusIncorrect,
    ReceiptVerificationStatusFailed,
    ReceiptVerificationStatusCreated
} ReceiptVerificationStatus;

@interface Receipt : NSObject

@property (nonatomic, strong, readonly) NSString *maskedCard;
@property (nonatomic, assign, readonly) NSInteger cardBin;
@property (nonatomic, assign, readonly) NSInteger amount;
@property (nonatomic, assign, readonly) NSInteger paymentId;
@property (nonatomic, assign, readonly) Currency currency;
@property (nonatomic, assign, readonly) ReceiptStatus status;
@property (nonatomic, assign, readonly) ReceiptTransationType transationType;
@property (nonatomic, strong, readonly) NSString *senderCellPhone;
@property (nonatomic, strong, readonly) NSString *senderAccount;
@property (nonatomic, assign, readonly) CardType cardType;
@property (nonatomic, strong, readonly) NSString *rrn;
@property (nonatomic, strong, readonly) NSString *approvalCode;
@property (nonatomic, strong, readonly) NSString *responseCode;
@property (nonatomic, strong, readonly) NSString *productId;
@property (nonatomic, strong, readonly) NSString *recToken;
@property (nonatomic, strong, readonly) NSDate *recTokenLifeTime;
@property (nonatomic, assign, readonly) NSInteger reversalAmount;
@property (nonatomic, assign, readonly) NSInteger settlementAmount;
@property (nonatomic, assign, readonly) Currency settlementCurrency;
@property (nonatomic, strong, readonly) NSDate *settlementDate;
@property (nonatomic, assign, readonly) NSInteger eci;
@property (nonatomic, assign, readonly) NSInteger fee;
@property (nonatomic, assign, readonly) NSInteger actualAmount;
@property (nonatomic, assign, readonly) Currency actualCurrency;
@property (nonatomic, strong, readonly) NSString *paymentSystem;
@property (nonatomic, assign, readonly) ReceiptVerificationStatus verificationStatus;

- (instancetype)initReceipt:(NSString *)maskedCard
                   aCardBin:(NSInteger)cardBin
                    aAmount:(NSInteger)amount
                 aPaymentId:(NSInteger)paymentId
                  acurrency:(Currency)currency
                    aStatus:(ReceiptStatus)status
            aTransationType:(ReceiptTransationType)transationType
           aSenderCellPhone:(NSString *)senderCellPhone
             aSenderAccount:(NSString *)senderAccount
                  aCardType:(CardType)cardType
                       aRrn:(NSString *)rrn
              aApprovalCode:(NSString *)approvalCode
              aResponseCode:(NSString *)responseCode
                 aProductId:(NSString *)productId
                  aRecToken:(NSString *)recToken
          aRecTokenLifeTime:(NSDate *)recTokenLifeTime
            aReversalAmount:(NSInteger)reversalAmount
          aSettlementAmount:(NSInteger)settlementAmount
        aSettlementCurrency:(Currency)settlementCurrency
            aSettlementDate:(NSDate *)settlementDate
                       aEci:(NSInteger)eci
                       aFee:(NSInteger)fee
              aActualAmount:(NSInteger)actualAmount
            aActualCurrency:(Currency)actualCurrency
             aPaymentSystem:(NSString *)paymentSystem
        aVerificationStatus:(ReceiptVerificationStatus)verificationStatus;

+ (NSString *)getStatusName:(ReceiptStatus)status;
+ (ReceiptStatus)getStatusSign:(NSString *)statusName;

+ (NSString *)getTransationTypeName:(ReceiptTransationType)transitionType;
+ (ReceiptTransationType)getTransationTypeSign:(NSString *)transitionTypeName;

+ (NSString *)getVerificationStatusName:(ReceiptVerificationStatus)verificationStatus;
+ (ReceiptVerificationStatus)getVerificationStatusSign:(NSString *)verificationStatusName;

@end

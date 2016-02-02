//
//  Receipt.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "Receipt.h"

NSString *stringWithReceiptStatus(ReceiptStatus status) {
    NSArray *arr = @[
                     @"unknown",
                     @"created",
                     @"processing",
                     @"declined",
                     @"approved",
                     @"expired",
                     @"reversed"
                     ];
    return (NSString *)[arr objectAtIndex:status];
}

ReceiptStatus receiptStatusWithString(NSString *str) {
    NSArray *arr = @[
                     @"unknown",
                     @"created",
                     @"processing",
                     @"declined",
                     @"approved",
                     @"expired",
                     @"reversed"
                     ];
    return (ReceiptStatus)[arr indexOfObject:str];
}

NSString *stringWithReceiptTransationType(ReceiptTransationType status) {
    NSArray *arr = @[
                     @"unknown",
                     @"purchase",
                     @"reverse"
                     ];
    return (NSString *)[arr objectAtIndex:status];
}

ReceiptTransationType receiptTransationTypeWithString(NSString *str) {
    NSArray *arr = @[
                     @"unknown",
                     @"purchase",
                     @"reverse"
                     ];
    return (ReceiptTransationType)[arr indexOfObject:str];
}

NSString *stringWithReceiptVerificationStatus(ReceiptVerificationStatus verificationStatus) {
    NSArray *arr = @[
                     @"unknown",
                     @"verified",
                     @"incorrect",
                     @"failed",
                     @"created"
                     ];
    return (NSString *)[arr objectAtIndex:verificationStatus];
}

ReceiptVerificationStatus receiptVerificationStatusWithString(NSString *str) {
    NSArray *arr = @[
                     @"unknown",
                     @"verified",
                     @"incorrect",
                     @"failed",
                     @"created"
                     ];
    return (ReceiptVerificationStatus)[arr indexOfObject:str];
}

@interface Receipt ()

@property (nonatomic, strong) NSString *maskedCard;
@property (nonatomic, assign) NSInteger cardBin;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, assign) NSInteger paymentId;
@property (nonatomic, assign) Currency currency;
@property (nonatomic, assign) ReceiptStatus status;
@property (nonatomic, assign) ReceiptTransationType transationType;
@property (nonatomic, strong) NSString *senderCellPhone;
@property (nonatomic, strong) NSString *senderAccount;
@property (nonatomic, assign) CardType cardType;
@property (nonatomic, strong) NSString *rrn;
@property (nonatomic, strong) NSString *approvalCode;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *recToken;
@property (nonatomic, strong) NSDate *recTokenLifeTime;
@property (nonatomic, assign) NSInteger reversalAmount;
@property (nonatomic, assign) NSInteger settlementAmount;
@property (nonatomic, assign) Currency settlementCurrency;
@property (nonatomic, strong) NSDate *settlementDate;
@property (nonatomic, assign) NSInteger eci;
@property (nonatomic, assign) NSInteger fee;
@property (nonatomic, assign) NSInteger actualAmount;
@property (nonatomic, assign) Currency actualCurrency;
@property (nonatomic, strong) NSString *paymentSystem;
@property (nonatomic, assign) ReceiptVerificationStatus verificationStatus;

@end

@implementation Receipt

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
        aVerificationStatus:(ReceiptVerificationStatus)verificationStatus
{
    self = [super init];
    if (self) {
        self.maskedCard = maskedCard;
        self.cardBin = cardBin;
        self.amount = amount;
        self.paymentId = paymentId;
        self.currency = currency;
        self.status = status;
        self.transationType = transationType;
        self.senderCellPhone = senderCellPhone;
        self.senderAccount = senderAccount;
        self.cardType = cardType;
        self.rrn = rrn;
        self.approvalCode = approvalCode;
        self.responseCode = responseCode;
        self.productId = productId;
        self.recToken = recToken;
        self.recTokenLifeTime = recTokenLifeTime;
        self.reversalAmount = reversalAmount;
        self.settlementAmount = settlementAmount;
        self.settlementCurrency = settlementCurrency;
        self.settlementDate = settlementDate;
        self.eci = eci;
        self.fee = fee;
        self.actualAmount = actualAmount;
        self.actualCurrency = actualCurrency;
        self.paymentSystem = paymentSystem;
        self.verificationStatus = verificationStatus;
    }
    return self;
}

+ (NSString *)getStatusName:(ReceiptStatus)status {
    return stringWithReceiptStatus(status);
}

+ (ReceiptStatus)getStatusSign:(NSString *)statusName {
    return receiptStatusWithString(statusName);
}


+ (NSString *)getTransationTypeName:(ReceiptTransationType)transitionType {
    return stringWithReceiptTransationType(transitionType);
}

+ (ReceiptTransationType)getTransationTypeSign:(NSString *)transitionTypeName {
    return receiptTransationTypeWithString(transitionTypeName);
}


+ (NSString *)getVerificationStatusName:(ReceiptVerificationStatus)verificationStatus {
    return stringWithReceiptVerificationStatus(verificationStatus);
}

+ (ReceiptVerificationStatus)getVerificationStatusSign:(NSString *)verificationStatusName {
    return receiptVerificationStatusWithString(verificationStatusName);
}



@end

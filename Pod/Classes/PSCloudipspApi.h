//
//  PSCloudipspApi.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

@protocol PSCloudipspView;
@class PSReceipt;
@class PSCard;
@class PSOrder;
@class PSLocalization;

typedef enum : NSUInteger {
    PSPayErrorCodeFailure,
    PSPayErrorCodeIllegalServerResponse,
    PSPayErrorCodeNetworkSecurity,
    PSPayErrorCodeNetworkAccess,
    PSPayErrorCodeUnknown
} PSPayErrorCode;

@protocol PSPayCallbackDelegate <NSObject>

- (void)onPaidProcess:(PSReceipt *)receipt;
- (void)onPaidFailure:(NSError *)error;
- (void)onWaitConfirm;

@end

@interface PSCloudipspApi : NSObject

+ (BOOL)supportsApplePay;

+ (instancetype)apiWithMerchant:(NSInteger)merchantId andCloudipspView:(id<PSCloudipspView>)cloudipspView;

- (void)pay:(PSCard *)card
     aOrder:(PSOrder *)order
aPayCallbackDelegate:(id<PSPayCallbackDelegate>)payCallbackDelegate;

- (void)payToken:(PSCard *)card
          aToken:(NSString *)token
aPayCallbackDelegate:(id<PSPayCallbackDelegate>)payCallbackDelegate;

- (UIViewController *)applePay:(NSString *)appleMerchantId
                        aOrder:(PSOrder *)order
          aPayCallbackDelegate:(id<PSPayCallbackDelegate>)payCallbackDelegate;

+ (void)setLocalization:(PSLocalization *)localization;
+ (PSLocalization *)getLocalization;

@end

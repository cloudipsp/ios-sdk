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
    PSPayErrorCodeApplePayUnsupported,
    PSPayErrorCodeUnknown
} PSPayErrorCode;

@protocol PSPayCallbackDelegate <NSObject>

- (void)onPaidProcess:(PSReceipt *)receipt;
- (void)onPaidFailure:(NSError *)error;
- (void)onWaitConfirm;

@end

typedef void(^PSIsPayerEmailRequiredCallback)(BOOL isRequired, NSError *error);

@protocol PSApplePayCallbackDelegate <PSPayCallbackDelegate>

- (void)onApplePayNavigate:(UIViewController *)viewController;

@end

@interface PSCloudipspApi : NSObject

+ (BOOL)supportsApplePay;

+ (instancetype)apiWithMerchant:(NSInteger)merchantId andCloudipspView:(id<PSCloudipspView>)cloudipspView;

- (void)pay:(PSCard *)card
  withOrder:(PSOrder *)order
andDelegate:(id<PSPayCallbackDelegate>)payCallbackDelegate;

- (void)pay:(PSCard *)card
  withToken:(NSString *)token
andDelegate:(id<PSPayCallbackDelegate>)payCallbackDelegate;

- (void)applePay:(PSOrder *)order
     andDelegate:(id<PSApplePayCallbackDelegate>)payCallbackDelegate;

- (void)applePayWithToken:(NSString *)token
              andDelegate:(id<PSApplePayCallbackDelegate>)payCallbackDelegate;

- (void)isPayerEmailRequiredForCurrency:(NSString *)currency
                           withCallback:(PSIsPayerEmailRequiredCallback)callback;

- (void)isPayerEmailRequiredForToken:(NSString *)token
                           withCallback:(PSIsPayerEmailRequiredCallback)callback;

+ (void)setLocalization:(PSLocalization *)localization;
+ (PSLocalization *)getLocalization;

@end

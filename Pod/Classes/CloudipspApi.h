//
//  CloudipspApi.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CloudipspView;
@class Receipt;
@class Card;
@class Order;

typedef enum : NSUInteger {
    PayErrorCodeFailure,
    PayErrorCodeIllegalServerResponse,
    PayErrorCodeNetworkSecurity,
    PayErrorCodeNetworkAccess,
    PayErrorCodeUnknown
} PayErrorCode;

@protocol PayCallbackDelegate <NSObject>

- (void)onPaidProcess:(Receipt *)receipt;
- (void)onPaidFailure:(NSError *)error;
- (void)onWaitConfirm;

@end

@interface CloudipspApi : NSObject

+ (instancetype)apiWithMerchant:(NSInteger)merchantId andCloudipspView:(id<CloudipspView>)cloudipspView;

- (void)pay:(Card *)card aOrder:(Order *)order aPayCallbackDelegate:(id<PayCallbackDelegate>)payCallbackDelegate;


@end

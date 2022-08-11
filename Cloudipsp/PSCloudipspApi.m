//
//  PSCloudipspApi.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <PassKit/PassKit.h>

#import "PSPayConfirmation.h"
#import "PSCloudipspApi.h"
#import "PSLocalization.h"
#import "PSUtils.h"

#import "PSCard.h"
#import "PSCurrency.h"
#import "PSReceipt.h"
#import "PSOrder.h"

#pragma mark - PSPayCallbackDelegateMainWrapper

@interface PSPayCallbackDelegateMainWrapper : NSObject<PSPayCallbackDelegate>

+ (instancetype)wrapperWithOrigin:(id<PSPayCallbackDelegate>)origin;

@property (nonatomic, strong) id<PSPayCallbackDelegate> origin;

@end

@implementation PSPayCallbackDelegateMainWrapper

+ (instancetype)wrapperWithOrigin:(id<PSPayCallbackDelegate>)origin {
    return [[PSPayCallbackDelegateMainWrapper alloc] initWithOrigin:origin];
}

- (instancetype)initWithOrigin:(id<PSPayCallbackDelegate>)origin {
    self = [super init];
    self.origin = origin;
    return self;
}

- (void)onPaidProcess:(PSReceipt *)receipt {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.origin onPaidProcess:receipt];
    });
}

- (void)onPaidFailure:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.origin onPaidFailure:error];
    });
}

- (void)onWaitConfirm {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.origin onWaitConfirm];
    });
}

@end


@interface ApplePayConfig : NSObject

@property (nonatomic, strong) NSDecimalNumber *amount;
@property (nonatomic, strong) NSString *merchantId;
@property (nonatomic, strong) NSString *paymentSystem;
@property (nonatomic, strong) NSString *businessName;
    
@end

@implementation ApplePayConfig

@end

#pragma mark - PSApplePayCallbackDelegateMainWrapper

@interface PSApplePayCallbackDelegateMainWrapper : PSPayCallbackDelegateMainWrapper<PSApplePayCallbackDelegate>

+ (instancetype)wrapperWithOrigin:(id<PSApplePayCallbackDelegate>)origin;

@property (nonatomic, strong) id<PSApplePayCallbackDelegate> originApplePay;

@end

@implementation PSApplePayCallbackDelegateMainWrapper

+ (instancetype)wrapperWithOrigin:(id<PSApplePayCallbackDelegate>)origin {
    PSApplePayCallbackDelegateMainWrapper *wrapper = [[PSApplePayCallbackDelegateMainWrapper alloc] initWithOrigin:origin];
    
    wrapper.originApplePay = origin;
    
    return wrapper;
}

- (void)onApplePayNavigate:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.originApplePay onApplePayNavigate:viewController];
    });
}

@end


#pragma mark - PSPayCallbackDelegateApplePayWrapper

API_AVAILABLE(ios(11.0))
@interface PSPayCallbackDelegateApplePayWrapper : NSObject<PSPayCallbackDelegate>
    
+ (instancetype)wrapperWithOrigin:(id<PSPayCallbackDelegate>)origin
              andApplePayCallback:(void (^)(PKPaymentAuthorizationResult *))applePayCallback;
    
@property (nonatomic, strong) id<PSPayCallbackDelegate> origin;
@property (nonatomic, strong) void (^applePayCallback)(PKPaymentAuthorizationResult *);
    
@end

@implementation PSPayCallbackDelegateApplePayWrapper
    
+ (instancetype)wrapperWithOrigin:(id<PSPayCallbackDelegate>)origin
              andApplePayCallback:(void (^)(PKPaymentAuthorizationResult *))applePayCallback {
    PSPayCallbackDelegateApplePayWrapper *wrapper = [[PSPayCallbackDelegateApplePayWrapper alloc] init];
    
    wrapper.origin = origin;
    wrapper.applePayCallback = applePayCallback;
    
    return wrapper;
}
    
- (void)onPaidProcess:(PSReceipt *)receipt {
    [self.origin onPaidProcess:receipt];
    if (receipt.status == PSReceiptStatusDeclined) {
        self.applePayCallback([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
    } else {
        self.applePayCallback([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
    }
}
    
- (void)onPaidFailure:(NSError *)error {
    [self.origin onPaidFailure:error];

    self.applePayCallback([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:@[error]]);
}
    
- (void)onWaitConfirm {
    [self.origin onWaitConfirm];
}
    
@end

#pragma mark - PSSendData

@interface PSSendData : NSObject

@property (nonatomic, strong) NSString *md;
@property (nonatomic, strong) NSString *paReq;
@property (nonatomic, strong) NSString *termUrl;

@end

@implementation PSSendData

- (instancetype)initSendData:(NSString *)md aPaReq:(NSString *)paReq aTermUrl:(NSString *)termUrl
{
    self = [super init];
    if (self) {
        self.md = md;
        self.paReq = paReq;
        self.termUrl = termUrl;
    }
    return self;
}

@end

#pragma mark - PSCheckout

const NSInteger WITHOUT_3DS = 0;
const NSInteger WITH_3DS = 1;

@interface PSCheckout : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) PSSendData *sendData;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *callbackUrl;
@property (nonatomic, assign) NSInteger action;

@end

@implementation PSCheckout

- (instancetype)initCheckout:(NSString *)token
                   aSendData:(PSSendData *)sendData
                        aUrl:(NSString *)url
                aCallbackUrl:(NSString *)callbackUrl
                     aAction:(NSInteger)action
{
    self = [super init];
    if (self) {
        self.token = token;
        self.sendData = sendData;
        self.url = url;
        self.callbackUrl = callbackUrl;
        self.action = action;
    }
    return self;
}

@end

#pragma mark - PSCard

@interface PSCard (private)

@property (nonatomic, strong, readonly) NSString *cardNumber;

@end

#pragma mark - PSReceipt

@interface PSReceipt (private)

- (instancetype)initReceipt:(NSDictionary *)response
                  aMaskCard:(NSString *)maskedCard
                   aCardBin:(NSInteger)cardBin
                    aAmount:(NSInteger)amount
                 aPaymentId:(NSInteger)paymentId
                  acurrency:(NSString *)currency
                    aStatus:(PSReceiptStatus)status
            aTransationType:(PSReceiptTransationType)transationType
           aSenderCellPhone:(NSString *)senderCellPhone
             aSenderAccount:(NSString *)senderAccount
                  aCardType:(PSCardType)cardType
                       aRrn:(NSString *)rrn
              aApprovalCode:(NSString *)approvalCode
              aResponseCode:(NSString *)responseCode
                 aProductId:(NSString *)productId
                  aRecToken:(NSString *)recToken
          aRecTokenLifeTime:(NSDate *)recTokenLifeTime
            aReversalAmount:(NSInteger)reversalAmount
          aSettlementAmount:(NSInteger)settlementAmount
        aSettlementCurrency:(NSString *)settlementCurrency
            aSettlementDate:(NSDate *)settlementDate
                       aEci:(NSInteger)eci
                       aFee:(NSInteger)fee
              aActualAmount:(NSInteger)actualAmount
            aActualCurrency:(NSString *)actualCurrency
             aPaymentSystem:(NSString *)paymentSystem
        aVerificationStatus:(PSReceiptVerificationStatus)verificationStatus
                 aSignature:(NSString *)signature;

@end

NSString * const HOST = @"https://api.fondy.eu";
NSString * const URL_CALLBACK = @"http://callback";
NSString * const DATE_AND_TIME_FORMAT = @"dd.MM.yyyy HH:mm:ss";
NSString * const DATE_FORMAT = @"dd.MM.yyyy";

PSLocalization *_localization;

@interface PSCloudipspApi () <NSURLSessionDelegate, PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, assign) NSInteger merchantId;
@property (nonatomic, strong) PSOrder *applePayOrder;
@property (nonatomic, strong) NSString *applePayToken;
@property (nonatomic, strong) NSString *applePayPaymentSystem;
@property (nonatomic, strong) id<PSApplePayCallbackDelegate> applePayPayCallbackDelegate;
@property (nonatomic, weak) id<PSCloudipspView> cloudipspView;

@end

@implementation PSCloudipspApi

+ (BOOL)supportsApplePay {
    return [PKPaymentAuthorizationViewController canMakePayments];
}

+ (instancetype)apiWithMerchant:(NSInteger)merchantId andCloudipspView:(id<PSCloudipspView>)cloudipspView;
{
    PSCloudipspApi *api = [[PSCloudipspApi alloc] init];
    api.merchantId = merchantId;
    api.cloudipspView = cloudipspView;
    return api;
}

#pragma mark - API

+ (void)assertCard:(PSCard *)card {
    if (![card isValidCard]) {
        @throw [NSException exceptionWithName:@"PSIllegalArgumentException"
                                       reason:@"Card should be valid"
                                     userInfo:nil];
    }
}

- (void)pay:(PSCard *)card withOrder:(PSOrder *)order andDelegate:(id<PSPayCallbackDelegate>)delegate {
    [PSCloudipspApi assertCard:card];

    PSPayCallbackDelegateMainWrapper *wrapper = [PSPayCallbackDelegateMainWrapper wrapperWithOrigin:delegate];
    [self getToken:order onSuccess:^(NSString *token) {
        [self checkout:card aToken:token aEmail:order.email callbackUrl: URL_CALLBACK onSuccess:^(PSCheckout *checkout) {
            [self payContinue:checkout aWrapper:wrapper];
        } payDelegate:wrapper];
    } payDelegate:wrapper];
}

- (void)pay:(PSCard *)card withToken:(NSString *)token andDelegate:(id<PSPayCallbackDelegate>)delegate {
    [PSCloudipspApi assertCard:card];

    PSPayCallbackDelegateMainWrapper *wrapper = [PSPayCallbackDelegateMainWrapper wrapperWithOrigin:delegate];
    [self callbackUrl:token onSuccess:^(NSString *callbackUrl) {
        [self checkout:card aToken:token aEmail:nil callbackUrl:callbackUrl onSuccess:^(PSCheckout *checkout) {
            [self payContinue:checkout aWrapper:wrapper];
        } payDelegate:wrapper];
    } payDelegate:wrapper];
}

- (void)assertApplePay {
    if (![NSThread.currentThread isMainThread]) {
        @throw [NSException exceptionWithName:@"PSIllegalAccessException"
                                       reason:@"ApplePay flow must launched only from main thread"
                                     userInfo:nil];
    }
}

- (void)applePay:(PSOrder *)order
     andDelegate:(id<PSApplePayCallbackDelegate>)delegate {
    [self assertApplePay];

    PSApplePayCallbackDelegateMainWrapper *wrapper = [PSApplePayCallbackDelegateMainWrapper wrapperWithOrigin:delegate];
    [self applePayConfig:order.currency aAmount:order.amount aToken:nil aSuccess:^(ApplePayConfig *config) {
        self.applePayOrder = order;
        [self applePay:config
             aCurrency:order.currency
                aAbout:order.about
                 aInfo:order.applePayInfo
             aDelegate:wrapper
        ];
    } aPayDelegate:wrapper];
}

- (void)applePayWithToken:(NSString *)token
              andDelegate:(id<PSApplePayCallbackDelegate>)delegate {
    [self assertApplePay];
    
    PSApplePayCallbackDelegateMainWrapper *wrapper = [PSApplePayCallbackDelegateMainWrapper wrapperWithOrigin:delegate];
    [self order:token onSuccess:^(PSReceipt *receipt) {
        self.applePayToken = token;
        [self applePayConfig:nil aAmount:receipt.amount aToken:token aSuccess:^(ApplePayConfig *config) {
            [self applePay:config
                 aCurrency:receipt.currency
                    aAbout:@" "
                    aInfo:nil
                 aDelegate:wrapper
             ];
        } aPayDelegate:wrapper];
    } payDelegate:wrapper];
}

- (void)applePay:(ApplePayConfig *)config
       aCurrency:(NSString *)currency
          aAbout:(NSString *)about
           aInfo:(NSString *)info
       aDelegate:(id<PSApplePayCallbackDelegate>)delegate
{
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.countryCode = @"US";
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.merchantIdentifier = config.merchantId;
    paymentRequest.currencyCode = currency;
    
    NSMutableArray *items = [NSMutableArray new];
    
    NSString *label = info == nil ? about : info;
    PKPaymentSummaryItem *infoItem = [PKPaymentSummaryItem summaryItemWithLabel: label amount:config.amount];
    [items addObject:infoItem];

    PKPaymentSummaryItem *mainItem = [PKPaymentSummaryItem summaryItemWithLabel: config.businessName amount:config.amount];
    [items addObject:mainItem];
    
    paymentRequest.paymentSummaryItems = items;

    self.applePayPaymentSystem = config.paymentSystem;
    self.applePayPayCallbackDelegate = delegate;
    
    PKPaymentAuthorizationViewController *controller = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    controller.delegate = self;
    [delegate onApplePayNavigate:controller];
}

- (void)isPayerEmailRequiredForCurrency:(NSString *)currency
                           withCallback:(PSIsPayerEmailRequiredCallback)callback
{
    NSDictionary *const params = @{
        @"currency": currency,
        @"merchant_id": @(self.merchantId),
    };

    [self jsonNetworkRequestByPath:@"/api/checkout/merchant/info"
                          jsonBody:[PSCloudipspApi requestJson:params]
                        onComplete:^(NSDictionary *json, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(NO, error);
            });
        }
        if ([json objectForKey:@"error_message"] != nil) {
            [self handleResponseError:json];
        }
        BOOL required = [[json objectForKey:@"checkout_email_required"] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(required, nil);
        });
    }];
}

- (void)isPayerEmailRequiredForToken:(NSString *)token
                        withCallback:(PSIsPayerEmailRequiredCallback)callback {
    [self jsonNetworkRequestByPath:@"/api/checkout/ajax/mobile_pay"
                          jsonBody:[PSCloudipspApi requestJson:@{@"token":token}]
                        onComplete:^(NSDictionary *json, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(NO, error);
            });
        } else {
            BOOL required = [[[json objectForKey:@"options"] objectForKey:@"requestPayerEmail"] boolValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(required, nil);
            });
        }
    }];
}

#pragma mark - Localization

+ (void)setLocalization:(PSLocalization *)localization {
    _localization = localization;
}

+ (PSLocalization *)getLocalization {
    if (_localization == nil) {
        NSString *language = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        if ([language isEqualToString:@"uk"]) {
            return [PSLocalization uk];
        } else if ([language isEqualToString:@"ru"]) {
            return [PSLocalization ru];
        } else {
            return [PSLocalization en];
        }
    } else {
        return _localization;
    }
}

#pragma mark - InternalApi

- (void)getToken:(PSOrder *)order
       onSuccess:(void (^)(NSString *token))success
     payDelegate:(id<PSPayCallbackDelegate>)delegate {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:
                                       @{
                                         @"order_id" : order.identifier,
                                         @"merchant_id" : [NSString stringWithFormat:@"%ld", (long)self.merchantId],
                                         @"order_desc" : order.about,
                                         @"delayed" : @"n",
                                         @"amount" : [NSString stringWithFormat:@"%ld", (long)order.amount],
                                         @"currency" : order.currency,
                                         @"merchant_data" : @"[]"
                                         }];
    
    if (![PSUtils isEmpty:order.productId]) {
        [dictionary setObject:order.productId forKey:@"product_id"];
    }
    if (![PSUtils isEmpty:order.paymentSystems]) {
        [dictionary setObject:order.paymentSystems forKey:@"payment_systems"];
    }
    if (![PSUtils isEmpty:order.defaultPaymentSystem]) {
        [dictionary setObject:order.defaultPaymentSystem forKey:@"default_payment_system"];
    }
    if (order.lifetime != -1) {
        [dictionary setObject:[NSNumber numberWithInteger:order.lifetime] forKey:@"lifetime"];
    }
    if (![PSUtils isEmpty:order.merchantData]) {
        [dictionary setObject:order.merchantData forKey:@"merchant_data"];
    }
    if (![PSUtils isEmpty:order.version]) {
        [dictionary setObject:order.version forKey:@"version"];
    }
    if (![PSUtils isEmpty:order.serverCallbackUrl]) {
        [dictionary setObject:order.serverCallbackUrl forKey:@"server_callback_url"];
    }
    
    if (![PSUtils isEmpty:order.reservationData]) {
        [dictionary setObject:order.reservationData forKey:@"reservation_data"];
    }
    
    if (order.lang != 0) {
        [dictionary setObject:[PSOrder getLangName:order.lang] forKey:@"lang"];
    }
    [dictionary setObject:order.preauth ? @"Y" : @"N" forKey:@"preauth"];
    [dictionary setObject:order.delayed ? @"Y" : @"N" forKey:@"delayed"];
    [dictionary setObject:order.requiredRecToken ? @"Y" : @"N" forKey:@"required_rectoken"];
    [dictionary setObject:order.verification ? @"Y" : @"N" forKey:@"verification"];
    if (order.verificationType != 0) {
        [dictionary setObject:[PSOrder getVerificationName:order.verificationType] forKey:@"verification_type"];
    }
    [dictionary addEntriesFromDictionary:order.arguments];
    [dictionary setObject:URL_CALLBACK forKey:@"response_url"];
    [self payJsonNetworkRequestByPath:@"/api/checkout/token"
                             jsonBody:[PSCloudipspApi requestJson:dictionary]
                            onSuccess:^(NSDictionary *response) {
        NSString *token = [response objectForKey:@"token"];
        success(token);
    } payDelegate:delegate];
}

- (void)checkout:(PSCard *)card
          aToken:(NSString *)token
          aEmail:(NSString *)email
     callbackUrl:(NSString *)callbackUrl
       onSuccess:(void (^)(PSCheckout *checkout))success
     payDelegate:(id<PSPayCallbackDelegate>)delegate {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       card.cardNumber, @"card_number",
                                       card.cvv, @"cvv2",
                                       [NSString stringWithFormat:@"%02d%02d", card.mm, card.yy], @"expiry_date",
                                       @"card", @"payment_system",
                                       token, @"token", nil];
    if (card.email != nil && card.email.length > 0) {
        [params setObject:card.email forKey:@"email"];
    } else if (email != nil) {
        [params setObject:email forKey:@"email"];
    }
    [self checkoutContinue:params aToken:token callbackUrl:callbackUrl onSuccess:success payDelegate:delegate];
}

- (void)applePayConfig:(NSString *)currency
               aAmount:(NSInteger)amount
                aToken:(NSString *)token
              aSuccess:(void (^)(ApplePayConfig *config))success
          aPayDelegate:(id<PSPayCallbackDelegate>) delegate {
    NSDictionary *params;
    if (token == nil) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSNumber numberWithDouble: amount], @"amount",
                  [NSNumber numberWithLong:self.merchantId], @"merchant_id",
                  currency, @"currency", nil];
    } else {
        params = [NSDictionary dictionaryWithObjectsAndKeys: token, @"token", nil];
    }
    
    [self payJsonNetworkRequestByPath:@"/api/checkout/ajax/mobile_pay"
                             jsonBody:[PSCloudipspApi requestJson:params]
                            onSuccess:^(NSDictionary *json) {
        if ([json objectForKey:@"error_message"] != nil) {
            [self handleResponseError:json];
        }
        NSArray *methods = [json objectForKey:@"methods"];
        NSDictionary *data = nil;
        for (NSDictionary *method in methods) {
            if ([[method objectForKey:@"supportedMethods"] isEqualToString:@"https://apple.com/apple-pay"]) {
                data = [method objectForKey:@"data"];
                break;
            }
        }
        if (data == nil) {
            [delegate onPaidFailure:[NSError errorWithDomain:@"CloudipspApi" code:PSPayErrorCodeApplePayUnsupported userInfo:nil]];
        } else {
            NSDictionary *totalDetails = [[json objectForKey:@"details"] objectForKey:@"total"];
            NSNumber* rawAmount = [[totalDetails objectForKey:@"amount"] objectForKey:@"value"];

            ApplePayConfig *config = [[ApplePayConfig alloc] init];
            config.amount = [[NSDecimalNumber alloc] initWithDouble:rawAmount.doubleValue];
            config.merchantId = [data objectForKey:@"merchantIdentifier"];
            config.paymentSystem = [json objectForKey:@"payment_system"];
            config.businessName =  [totalDetails objectForKey:@"label"];
            
            success(config);
        }
    } payDelegate:delegate];
}

- (void)checkoutApplePay:(NSDictionary *)paymentData
                  aToken:(NSString *)token
                  aEmail:(NSString *)email
          aPaymentSystem:(NSString *)paymentSystem
             callbackUrl:(NSString *)callbackUrl
               onSuccess:(void (^)(PSCheckout *checkout))success
             payDelegate:(id<PSPayCallbackDelegate>)delegate {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                paymentData, @"data",
                                paymentSystem, @"payment_system",
                                token, @"token",
                                email, @"email", nil];
    
    [self checkoutContinue:params aToken:token callbackUrl:callbackUrl onSuccess:success payDelegate:delegate];
}

- (void)checkoutContinue:(NSDictionary *)params
                  aToken:(NSString *)token
             callbackUrl:(NSString *)callbackUrl
               onSuccess:(void (^)(PSCheckout *checkout))success
             payDelegate:(id<PSPayCallbackDelegate>)delegate {
    [self payJsonNetworkRequestByPath:@"/api/checkout/ajax"
                             jsonBody:[PSCloudipspApi requestJson:params]
                            onSuccess:^(NSDictionary *response) {
        NSString *url = [response objectForKey:@"url"];
        if ([url hasPrefix:callbackUrl]) {
            PSCheckout *checkout = [[PSCheckout alloc] initCheckout:token aSendData:nil aUrl:url aCallbackUrl:callbackUrl aAction:WITHOUT_3DS];
            success(checkout);
        } else {
            NSDictionary *sendData = [response objectForKey:@"send_data"];
            NSString *md = [NSString stringWithFormat:@"%@",[sendData objectForKey:@"MD"]];
            PSCheckout *checkout = [[PSCheckout alloc] initCheckout:token aSendData:[[PSSendData alloc] initSendData:md aPaReq:[sendData objectForKey:@"PaReq"] aTermUrl:[sendData objectForKey:@"TermUrl"]] aUrl:url aCallbackUrl:callbackUrl aAction:WITH_3DS];
            success(checkout);
        }
    } payDelegate:delegate];
}

- (void)order:(NSString *)token
    onSuccess:(void (^)(PSReceipt *receipt))success
  payDelegate:(id<PSPayCallbackDelegate>)delegate {
    [self payJsonNetworkRequestByPath:@"/api/checkout/merchant/order"
                             jsonBody:[PSCloudipspApi requestJson:@{@"token" : token}]
                            onSuccess:^(NSDictionary *response) {
        success([self parseOrder:[response objectForKey:@"order_data"]]);
    } payDelegate:delegate];
}

- (void)callbackUrl:(NSString *)token
    onSuccess:(void (^)(NSString *callbackUrl))success
  payDelegate:(id<PSPayCallbackDelegate>)delegate {
    [self payJsonNetworkRequestByPath:@"/api/checkout/merchant/order"
                             jsonBody:[PSCloudipspApi requestJson:@{@"token" : token}]
                            onSuccess:^(NSDictionary *response) {
        success([response objectForKey:@"response_url"]);
    } payDelegate:delegate];
}

- (void)payContinue:(PSCheckout *)checkout
           aWrapper:(PSPayCallbackDelegateMainWrapper *)wrapper {
    if (checkout.action == WITHOUT_3DS) {
        [self order:checkout.token onSuccess:^(PSReceipt *receipt) {
            [wrapper onPaidProcess:receipt];
        } payDelegate:wrapper];
    } else {
        [self url3ds:checkout aPayCallbackDelegate:wrapper];
    }
}

- (void)url3ds:(PSCheckout *)checkout aPayCallbackDelegate:(id<PSPayCallbackDelegate>)delegate {
    void (^successCallback)(NSData * data) = ^(NSData *data) {
        NSString *htmlPageContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        PSPayConfirmation *confirmation = [[PSPayConfirmation alloc] initPayConfirmation:htmlPageContent
                                                                                    aUrl:checkout.url
                                                                            aCallbackUrl:checkout.callbackUrl
                                                                                   aHost:HOST
                                                                             onConfirmed:^(NSString *jsonOfConfirmation)
                                           {
                                               if (jsonOfConfirmation) {
                                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonOfConfirmation dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                                                   NSString *url = [json objectForKey:@"url"];
                                                   if (![checkout.callbackUrl hasPrefix:url]) {
                                                       @throw [NSException exceptionWithName:@"" reason:nil userInfo:nil];
                                                   }
                                                   NSDictionary *orderData = [json objectForKey:@"params"];
                                                   [self checkResponse:orderData];
                                                   [delegate onPaidProcess:[self parseOrder:orderData]];
                                               } else {
                                                   [self order:checkout.token onSuccess:^(PSReceipt *receipt) {
                                                       [delegate onPaidProcess:receipt];
                                                   } payDelegate:delegate];
                                               }
                                           }];
        [self.cloudipspView confirm:confirmation];
        [delegate onWaitConfirm];
    };
    if (checkout.sendData.paReq == nil) {
        NSDictionary *dictionary = @{@"MD" : checkout.sendData.md,
                                     @"TermUrl" : checkout.sendData.termUrl};
        
        
        [self payJsonNetworkRequestByURL:[NSURL URLWithString:checkout.url]
                                jsonBody:dictionary
                               onSuccess:successCallback
                             payDelegate:delegate
        ];
    } else {
        [self payNetworkRequestByURL:[NSURL URLWithString:checkout.url]
              onSuccess:successCallback
            payDelegate:delegate
            onIntercept:^(NSMutableURLRequest *request) {
                NSString *post = [NSString stringWithFormat:@"MD=%@&PaReq=%@&TermUrl=%@", [PSCloudipspApi encodeToPercentEscapeString:checkout.sendData.md], [PSCloudipspApi encodeToPercentEscapeString:checkout.sendData.paReq], [PSCloudipspApi encodeToPercentEscapeString:checkout.sendData.termUrl]];
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:postData];
            }];
    }
}

- (void)processApplePay:(PKPayment *)payment payDelegate:(id<PSPayCallbackDelegate>)delegate
API_AVAILABLE(ios(11.0))
{
    NSError *jsonError;
    
    NSDictionary *paymentData = [NSJSONSerialization JSONObjectWithData:payment.token.paymentData options:NSJSONReadingMutableContainers error:&jsonError];
    NSDictionary *paymentMethod = @{
                                    @"displayName":payment.token.paymentMethod.displayName,
                                    @"network":payment.token.paymentMethod.network,
                                    @"type": [PSCloudipspApi paymentMethodName: payment.token.paymentMethod.type],
                                    };
    NSDictionary *paymentToken = @{
                                   @"paymentData": paymentData,
                                   @"paymentMethod": paymentMethod,
                                   @"transactionIdentifier": payment.token.transactionIdentifier
                                   };
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:paymentToken forKey:@"token"];
    if (payment.shippingContact != nil) {
        NSDictionary *shipingContact = @{
                                         @"emailAddress": payment.shippingContact.emailAddress,
                                         @"familyName": payment.shippingContact.name.familyName,
                                         @"givenName": payment.shippingContact.name.givenName,
                                         @"phoneNumber": payment.shippingContact.phoneNumber.stringValue,
                                         };
        [data setObject:shipingContact forKey:@"shippingContact"];
    }
    
    if (self.applePayOrder != nil) {
        PSOrder *order = self.applePayOrder;
        self.applePayOrder = nil;
        [self getToken:order onSuccess:^(NSString *token) {
            [self checkoutApplePay:data
                            aToken:token
                            aEmail:order.email
                    aPaymentSystem:self.applePayPaymentSystem
                       callbackUrl:URL_CALLBACK
                         onSuccess:^(PSCheckout *checkout) {
                             [self payContinue:checkout aWrapper:delegate];
                         }
                       payDelegate:delegate
             ];
        } payDelegate:delegate];
    } else if (self.applePayToken) {
        NSString *token = self.applePayToken;
        self.applePayToken = nil;
        [self callbackUrl:token onSuccess:^(NSString *callbackUrl) {
            [self checkoutApplePay:data
                            aToken:token
                            aEmail:nil
                    aPaymentSystem: self.applePayPaymentSystem
                       callbackUrl:callbackUrl
                         onSuccess:^(PSCheckout *checkout) {
                             [self payContinue:checkout aWrapper:delegate];
                         }
                       payDelegate:delegate
             ];
        } payDelegate:delegate];
    }
}

#pragma mark - Calls

- (void)payJsonNetworkRequestByPath:(NSString *)path
                           jsonBody:(NSDictionary *)jsonBody
                          onSuccess:(void (^)(NSDictionary *json))success
                        payDelegate:(id<PSPayCallbackDelegate>)delegate {
    [self payJsonNetworkRequestByURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, path]]
                            jsonBody:jsonBody
                           onSuccess:^(NSData *data) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [self parseResponse:json];
        NSDictionary *response = [json objectForKey:@"response"];
        success(response);
    } payDelegate:delegate];
}

- (void)jsonNetworkRequestByPath:(NSString *)path
                        jsonBody:(NSDictionary *)jsonBody
                      onComplete:(void (^)(NSDictionary *json, NSError *error))complete {
    [self networkRequest:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, path]]
          onComplete:^(NSData *data, NSError *error) {
        if (error != nil) {
            complete(nil, error);
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *response = [json objectForKey:@"response"];
            complete(response, nil);
        }
    } onIntercept:^(NSMutableURLRequest *request) {
        [PSCloudipspApi setRequestJsonBody:request jsonBody:jsonBody];
    }];
}

- (void)payJsonNetworkRequestByURL:(NSURL *)url
                          jsonBody:(NSDictionary *)jsonBody
                         onSuccess:(void (^)(NSData *data))success
                       payDelegate:(id<PSPayCallbackDelegate>)delegate {
    [self networkRequest:url onComplete:^(NSData *data, NSError *error) {
        if (error == nil) {
            success(data);
        } else {
            [delegate onPaidFailure:error];
        }
    } onIntercept:^(NSMutableURLRequest *request) {
        [PSCloudipspApi setRequestJsonBody:request jsonBody:jsonBody];
    }];
}

- (void)payNetworkRequestByURL:(NSURL *)url
                     onSuccess:(void (^)(NSData *data))success
                   payDelegate:(id<PSPayCallbackDelegate>)delegate
                   onIntercept:(void (^)(NSMutableURLRequest *request))interceptor
{
    [self networkRequest:url onComplete:^(NSData *data, NSError *error) {
        if (error == nil) {
            success(data);
        } else {
            [delegate onPaidFailure:error];
        }
    } onIntercept:interceptor];
}

- (void)networkRequest:(NSURL *)url
            onComplete:(void (^)(NSData *data, NSError *error))complete
           onIntercept:(void (^)(NSMutableURLRequest *request))interceptor {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"iOS-SDK" forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"ios" forHTTPHeaderField:@"SDK-OS"];
    [request addValue:@"0.10.0" forHTTPHeaderField:@"SDK-Version"];
    interceptor(request);
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              if (error) {
                                                  error = [NSError errorWithDomain:@"CloudipspApi" code:PSPayErrorCodeNetworkAccess userInfo:nil];
                                                  complete(nil, error);
                                              } else {
                                                  @try {
                                                      complete(data, nil);
                                                  }
                                                  @catch (NSException *exception) {
                                                      NSError *error;
                                                      if (exception.userInfo == nil) {
                                                          error = [NSError errorWithDomain:@"CloudipspApi" code:PSPayErrorCodeUnknown userInfo:nil];
                                                      } else {
                                                          error = [NSError errorWithDomain:@"CloudipspApi" code:PSPayErrorCodeFailure userInfo:exception.userInfo];
                                                      }
                                                      complete(nil, error);
                                                      
                                                  }
                                              }}];
    
    [postDataTask resume];
}

- (NSDictionary *)parseResponse:(NSDictionary *)response {
    @try {
        [self checkResponse:response];
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:@"RuntimeException" reason:exception.reason userInfo:exception.userInfo];
    }
    return response;
}

- (void)checkResponse:(NSDictionary *)response {
    NSString *str = [response objectForKey:@"response_status"];
    if (str != nil && ![str isEqualToString:@"success"]) {
        [self handleResponseError:response];
    }
}

- (void)handleResponseError:(NSDictionary *)response {
    NSString *reason = [NSString stringWithFormat:@"%@, %@",[response objectForKey:@"error_message"], [response objectForKey:@"error_code"]];
    NSDictionary *userInfo = @{@"error_code" : [response objectForKey:@"error_code"],
                               @"error_message" : [response objectForKey:@"error_message"],
                               @"request_id" : [response objectForKey:@"request_id"],
                               @"response_status" : [response objectForKey:@"response_status"]};
    @throw [NSException exceptionWithName: @"PSIllegalResponseException" reason: reason userInfo: userInfo];
}

- (PSReceipt *)parseOrder:(NSDictionary *)orderData {
    NSDate *recTokenLifeTime;
    
    @try {
        recTokenLifeTime = [PSUtils dateFromString:[orderData objectForKey:@"rectoken_lifetime"] withFormat:DATE_AND_TIME_FORMAT];
    }
    @catch (NSException *exception) {
        recTokenLifeTime = nil;
    }
    
    NSDate *settlementDate;
    
    @try {
        settlementDate = [PSUtils dateFromString:[orderData objectForKey:@"settlement_date"] withFormat:DATE_FORMAT];
    }
    @catch (NSException *exception) {
        settlementDate = nil;
    }
    
    NSString *verificationStatus = [orderData objectForKey:@"verification_status"];
    PSReceiptVerificationStatus verificationStatusEnum;
    if (!verificationStatus) {
        verificationStatusEnum = PSReceiptVerificationStatusUnknown;
    } else {
        verificationStatusEnum = [PSReceipt getVerificationStatusSign:verificationStatus];
    }
    
    NSString *status = [orderData objectForKey:@"order_status"];
    PSReceiptStatus statusEnum;
    if (!status) {
        statusEnum = PSReceiptStatusUnknown;
    } else {
        statusEnum = [PSReceipt getStatusSign:status];
    }
    
    NSString *transitionType = [orderData objectForKey:@"tran_type"];
    PSReceiptTransationType transitionTypeEnum;
    if (!transitionType) {
        transitionTypeEnum = PSReceiptTransationTypeUnknown;
    } else {
        transitionTypeEnum = [PSReceipt getTransationTypeSign:transitionType];
    }
    
    NSString *cardType = [orderData objectForKey:@"card_type"];
    PSCardType cardTypeEnum;
    if (!cardType) {
        cardTypeEnum = PSCardTypeUnknown;
    } else {
        cardTypeEnum = [PSCard getCardType:[transitionType uppercaseString]];
    }
    
    NSInteger reversalAmount = [orderData objectForKey:@"reversal_amount"] ? [[orderData objectForKey:@"reversal_amount"] integerValue] : -1;
    
    NSInteger settlementAmount = [orderData objectForKey:@"settlement_amount"] ? [[orderData objectForKey:@"settlement_amount"] integerValue] : -1;
    
    NSInteger eci = [orderData objectForKey:@"eci"] ? [[orderData objectForKey:@"eci"] integerValue] : -1;
    
    NSInteger fee = [orderData objectForKey:@"fee"] ? [[orderData objectForKey:@"fee"] integerValue] : -1;
    
    NSInteger actualAmount = [orderData objectForKey:@"actual_amount"] ? [[orderData objectForKey:@"actual_amount"] integerValue] : -1;
    
    return [[PSReceipt alloc] initReceipt:orderData
                                aMaskCard:[orderData objectForKey:@"masked_card"]
                                 aCardBin:[[orderData objectForKey:@"card_bin"] integerValue]
                                  aAmount:[[orderData objectForKey:@"amount"] integerValue]
                               aPaymentId:[[orderData objectForKey:@"payment_id"] integerValue]
                                acurrency:[orderData objectForKey:@"currency"]
                                  aStatus:statusEnum
                          aTransationType:transitionTypeEnum
                         aSenderCellPhone:[orderData objectForKey:@"sender_cell_phone"]
                           aSenderAccount:[orderData objectForKey:@"sender_account"]
                                aCardType:cardTypeEnum aRrn:[orderData objectForKey:@"rrn"]
                            aApprovalCode:[orderData objectForKey:@"approval_code"]
                            aResponseCode:[orderData objectForKey:@"response_code"]
                               aProductId:[orderData objectForKey:@"product_id"]
                                aRecToken:[orderData objectForKey:@"rectoken"]
                        aRecTokenLifeTime:recTokenLifeTime
                          aReversalAmount:reversalAmount
                        aSettlementAmount:settlementAmount
                      aSettlementCurrency:[orderData objectForKey:@"settlement_currency"]
                          aSettlementDate:settlementDate
                                     aEci:eci
                                     aFee:fee
                            aActualAmount:actualAmount
                          aActualCurrency:[orderData objectForKey:@"actual_currency"]
                           aPaymentSystem:[orderData objectForKey:@"payment_system"]
                      aVerificationStatus:verificationStatusEnum
                               aSignature:[orderData objectForKey:@"signature"]];
}

+ (NSString *)encodeToPercentEscapeString:(NSString *)string {
    CFStringRef strRef = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                 (CFStringRef) string,
                                                                 NULL,
                                                                 (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                 kCFStringEncodingUTF8);
    
    
    NSString* result = [NSString stringWithString: (__bridge NSString*)strRef];
    
    CFRelease(strRef);
    
    return result;
}

# pragma mark - ApplePay
    
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
    
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult *result))completion
    API_AVAILABLE(ios(11.0))
{
    PSPayCallbackDelegateApplePayWrapper *applePayWrapper = [PSPayCallbackDelegateApplePayWrapper wrapperWithOrigin:self.applePayPayCallbackDelegate andApplePayCallback:completion];
    
    [self processApplePay:payment payDelegate:applePayWrapper];
}

+ (NSString *)paymentMethodName:(PKPaymentMethodType)type API_AVAILABLE(ios(9.0)){
    switch (type) {
        case PKPaymentMethodTypeDebit:
            return @"debit";
        case PKPaymentMethodTypeCredit:
            return @"credit";
        case PKPaymentMethodTypePrepaid:
            return @"prepaid";
        case PKPaymentMethodTypeStore:
            return @"store";
        default:
            return @"unknown";
    }
}

+ (NSDictionary *)requestJson:(NSDictionary *)request {
    return @{
        @"request": request
    };
}

+ (void)setRequestJsonBody:(NSMutableURLRequest *)request
                  jsonBody:(NSDictionary *)jsonBody {
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];

    NSData *const serializedJsonBody = [NSJSONSerialization dataWithJSONObject:jsonBody options:0 error:nil];
    [request setHTTPBody:serializedJsonBody];
}

@end

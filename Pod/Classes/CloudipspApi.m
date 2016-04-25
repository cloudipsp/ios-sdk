//
//  CloudipspApi.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "CloudipspApi.h"
#import "Order.h"
#import "Currency.h"
#import "Utils.h"
#import "Card.h"
#import "Receipt.h"
#import "PayConfirmation.h"

@interface PayCallbackDelegateMainWrapper : NSObject<PayCallbackDelegate>

+ (instancetype)wrapperWithOrigin:(id<PayCallbackDelegate>)origin;

@property (nonatomic, strong) id<PayCallbackDelegate> origin;

@end

@implementation PayCallbackDelegateMainWrapper

+ (instancetype)wrapperWithOrigin:(id<PayCallbackDelegate>)origin {
    PayCallbackDelegateMainWrapper *wrapper = [[PayCallbackDelegateMainWrapper alloc] init];
    
    wrapper.origin = origin;
    
    return wrapper;
}

- (void)onPaidSuccess:(Receipt *)receipt {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.origin onPaidSuccess:receipt];
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

@interface SendData : NSObject

@property (nonatomic, strong) NSString *md;
@property (nonatomic, strong) NSString *paReq;
@property (nonatomic, strong) NSString *termUrl;

@end

@implementation SendData

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

const NSInteger WITHOUT_3DS = 0;
const NSInteger WITH_3DS = 1;

@interface Checkout : NSObject

@property (nonatomic, strong) SendData *sendData;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSInteger action;

@end

@implementation Checkout

- (instancetype)initCheckout:(SendData *)sendData aUrl:(NSString *)url aAction:(NSInteger)action
{
    self = [super init];
    if (self) {
        self.sendData = sendData;
        self.url = url;
        self.action = action;
    }
    return self;
}

@end


@interface Card (private)

@property (nonatomic, strong, readonly) NSString *cardNumber;

@end

NSString * const HOST = @"https://api.oplata.com";
NSString * const URL_CALLBACK = @"http://callback";
NSString * const DATE_AND_TIME_FORMAT = @"dd.MM.yyyy HH:mm:ss";
NSString * const DATE_FORMAT = @"dd.MM.yyyy";

@interface CloudipspApi () <NSURLSessionDelegate>

@property (nonatomic, assign) NSInteger merchantId;


@end

@implementation CloudipspApi

+ (instancetype)apiWithMerchant:(NSInteger)merchantId andCloudipspView:(id<CloudipspView>)cloudipspView;
{
    CloudipspApi *api = [[CloudipspApi alloc] init];
    api.merchantId = merchantId;
    api.cloudipspView = cloudipspView;
    return api;
}

- (void)call:(NSString *)path
     aParams:(NSDictionary *)params
   onSuccess:(void (^)(NSDictionary *response))success
 payDelegate:(id<PayCallbackDelegate>)delegate {
    
    [self callByUrl:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, path]] aParams:@{@"request" : params} onSuccess:^(NSData *data) {
        success([self parseResponse:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]]);
    } payDelegate:delegate];
}

- (void)callByUrl:(NSURL *)url
          aParams:(NSDictionary *)params
        onSuccess:(void (^)(NSData *data))success
      payDelegate:(id<PayCallbackDelegate>)delegate {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *body = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [request setHTTPBody:body];
    
    NSLog(@"Send: %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              if (error) {
                                                  error = [NSError errorWithDomain:@"CloudipspApi" code:PayErrorCodeNetworkAccess userInfo:nil];
                                                  [delegate onPaidFailure:error];
                                              } else {
                                                  @try {
                                                      success(data);
                                                  }
                                                  @catch (NSException *exception) {
                                                      NSError *error = [NSError errorWithDomain:@"CloudipspApi" code:PayErrorCodeUnknown userInfo:nil];
                                                      [delegate onPaidFailure:error];
                                                  }
                                              }}];
    
    [postDataTask resume];
}

- (NSDictionary *)parseResponse:(NSDictionary *)response {
    @try {
        NSDictionary *dict = [response objectForKey:@"response"];
        [self checkResponse:dict];
        NSLog(@"Receive: %@", dict);
        return dict;
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:@"RuntimeException" reason:exception.reason userInfo:nil];
    }
}

- (void)checkResponse:(NSDictionary *)response {
    NSString *str = [response objectForKey:@"response_status"];
    if (![str isEqualToString:@"success"]) {
        @throw [NSException exceptionWithName:@"IllegalResponseException" reason:[NSString stringWithFormat:@"%@, %@",[response objectForKey:@"error_message"], [response objectForKey:@"error_code"]] userInfo:nil];
    }
}

- (void)getToken:(Order *)order
       onSuccess:(void (^)(NSString *token))success
     payDelegate:(id<PayCallbackDelegate>)delegate {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:
                                       @{
                                         @"order_id" : order.identifier,
                                         @"merchant_id" : [NSString stringWithFormat:@"%ld", (long)self.merchantId],
                                         @"order_desc" : order.about,
                                         @"amount" : [NSString stringWithFormat:@"%ld", (long)order.amount],
                                         @"currency" : getCurrencyName(order.currency),
                                         @"merchant_data" : @"[]",
                                         @"signature" : @"button"
                                         }];
    
    if (![Utils isEmpty:order.productId]) {
        [dictionary setObject:order.productId forKey:@"product_id"];
    }
    if (![Utils isEmpty:order.paymentSystems]) {
        [dictionary setObject:order.paymentSystems forKey:@"payment_systems"];
    }
    if (![Utils isEmpty:order.defaultPaymentSystem]) {
        [dictionary setObject:order.defaultPaymentSystem forKey:@"default_payment_system"];
    }
    if (order.lifetime != -1) {
        [dictionary setObject:[NSNumber numberWithInteger:order.lifetime] forKey:@"lifetime"];
    }
    if (![Utils isEmpty:order.merchantData]) {
        [dictionary setObject:order.merchantData forKey:@"merchant_data"];
    }
    if (![Utils isEmpty:order.version]) {
        [dictionary setObject:order.version forKey:@"version"];
    }
    if (![Utils isEmpty:order.serverCallbackUrl]) {
        NSLog(order.serverCallbackUrl);
        [dictionary setObject:order.serverCallbackUrl forKey:@"server_callback_url"];
    }
    if (order.lang != 0) {
        [dictionary setObject:[Order getLangName:order.lang] forKey:@"lang"];
    }
    [dictionary setObject:order.preauth ? @"Y" : @"N" forKey:@"preauth"];
    [dictionary setObject:order.delayed ? @"Y" : @"N" forKey:@"delayed"];
    [dictionary setObject:order.requiredRecToken ? @"Y" : @"N" forKey:@"required_rectoken"];
    [dictionary setObject:order.verification ? @"Y" : @"N" forKey:@"verification"];
    if (order.verificationType != 0) {
        [dictionary setObject:[Order getVerificationName:order.verificationType] forKey:@"verification_type"];
    }
    [dictionary addEntriesFromDictionary:order.arguments];
    [dictionary setObject:URL_CALLBACK forKey:@"response_url"];
    [self call:@"/api/button" aParams:dictionary onSuccess:^(NSDictionary *response) {
        NSString *url = [response objectForKey:@"checkout_url"];
        NSString *token = [[url componentsSeparatedByString:@"token="] objectAtIndex:1];
        success(token);
    } payDelegate:delegate];
}

- (void)checkout:(Card *)card
          aToken:(NSString *)token
          aEmail:(NSString *)email
       onSuccess:(void (^)(Checkout *checkout))success
     payDelegate:(id<PayCallbackDelegate>)delegate {
    NSDictionary *dictionary = @{@"card_number" : card.cardNumber,
                                 @"cvv2" : card.cvv,
                                 @"expiry_date" : [NSString stringWithFormat:@"%02d%02d", card.mm, card.yy],
                                 @"payment_system" : @"card",
                                 @"token" : token,
                                 @"email" : email};
    [self call:@"/api/checkout/ajax" aParams:dictionary onSuccess:^(NSDictionary *response) {
        NSString *url = [response objectForKey:@"url"];
        if ([URL_CALLBACK isEqualToString:url]) {
            Checkout *checkout = [[Checkout alloc] initCheckout:nil aUrl:url aAction:WITHOUT_3DS];
            success(checkout);
        } else {
            NSDictionary *sendData = [response objectForKey:@"send_data"];
            Checkout *checkout = [[Checkout alloc] initCheckout:[[SendData alloc] initSendData:[sendData objectForKey:@"MD"] aPaReq:[sendData objectForKey:@"PaReq"] aTermUrl:[sendData objectForKey:@"TermUrl"]] aUrl:url aAction:WITH_3DS];
            success(checkout);
        }
    } payDelegate:delegate];
}

- (void)order:(NSString *)token
    onSuccess:(void (^)(Receipt *receipt))success
  payDelegate:(id<PayCallbackDelegate>)delegate {
    [self call:@"/api/checkout/merchant/order" aParams:@{@"token" : token} onSuccess:^(NSDictionary *response) {
        success([self parseOrder:[response objectForKey:@"order_data"]]);
    } payDelegate:delegate];
}

- (Receipt *)parseOrder:(NSDictionary *)orderData {
    NSDate *recTokenLifeTime;
    
    @try {
        recTokenLifeTime = [Utils dateFromString:[orderData objectForKey:@"rectoken_lifetime"] withFormat:DATE_AND_TIME_FORMAT];
    }
    @catch (NSException *exception) {
        recTokenLifeTime = nil;
    }
    
    NSDate *settlementDate;
    
    @try {
        settlementDate = [Utils dateFromString:[orderData objectForKey:@"settlement_date"] withFormat:DATE_FORMAT];
    }
    @catch (NSException *exception) {
        settlementDate = nil;
    }
    
    NSString *settlementCcy = [orderData objectForKey:@"settlement_currency"];
    Currency settlementCcyEnum = getCurrency(settlementCcy);
    
    NSString *actualCcy = [orderData objectForKey:@"actual_currency"];
    Currency actualCcyEnum = getCurrency(actualCcy);
    
    NSString *currency = [orderData objectForKey:@"currency"];
    Currency currencyEnum = getCurrency(currency);
    
    NSString *verificationStatus = [orderData objectForKey:@"verification_status"];
    ReceiptVerificationStatus verificationStatusEnum;
    if (!verificationStatus) {
        verificationStatusEnum = ReceiptVerificationStatusUnknown;
    } else {
        verificationStatusEnum = [Receipt getVerificationStatusSign:verificationStatus];
    }
    
    NSString *status = [orderData objectForKey:@"order_status"];
    ReceiptStatus statusEnum;
    if (!status) {
        statusEnum = ReceiptStatusUnknown;
    } else {
        statusEnum = [Receipt getStatusSign:status];
    }
    
    NSString *transitionType = [orderData objectForKey:@"tran_type"];
    ReceiptTransationType transitionTypeEnum;
    if (!transitionType) {
        transitionTypeEnum = ReceiptTransationTypeUnknown;
    } else {
        transitionTypeEnum = [Receipt getTransationTypeSign:transitionType];
    }
    
    NSString *cardType = [orderData objectForKey:@"card_type"];
    CardType cardTypeEnum;
    if (!cardType) {
        cardTypeEnum = CardTypeUnknown;
    } else {
        cardTypeEnum = [Card getCardType:[transitionType uppercaseString]];
    }
    
    NSInteger reversalAmount = [orderData objectForKey:@"reversal_amount"] ? [[orderData objectForKey:@"reversal_amount"] integerValue] : -1;
    
    NSInteger settlementAmount = [orderData objectForKey:@"settlement_amount"] ? [[orderData objectForKey:@"settlement_amount"] integerValue] : -1;
    
    NSInteger eci = [orderData objectForKey:@"eci"] ? [[orderData objectForKey:@"eci"] integerValue] : -1;
    
    NSInteger fee = [orderData objectForKey:@"fee"] ? [[orderData objectForKey:@"fee"] integerValue] : -1;
    
    NSInteger actualAmount = [orderData objectForKey:@"actual_amount"] ? [[orderData objectForKey:@"actual_amount"] integerValue] : -1;
    
    return [[Receipt alloc] initReceipt:[orderData objectForKey:@"masked_card"]
                               aCardBin:[[orderData objectForKey:@"card_bin"] integerValue]
                                aAmount:[[orderData objectForKey:@"amount"] integerValue]
                             aPaymentId:[[orderData objectForKey:@"payment_id"] integerValue]
                              acurrency:currencyEnum aStatus:statusEnum
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
                    aSettlementCurrency:settlementCcyEnum
                        aSettlementDate:settlementDate
                                   aEci:eci
                                   aFee:fee
                          aActualAmount:actualAmount
                        aActualCurrency:actualCcyEnum
                         aPaymentSystem:[orderData objectForKey:@"payment_system"]
                    aVerificationStatus:verificationStatusEnum];
}

- (void)url3ds:(Checkout *)checkout aPayCallbackDelegate:(id<PayCallbackDelegate>)delegate {
    NSDictionary *dictionary = @{@"MD" : checkout.sendData.md,
                                 @"PaReq" : checkout.sendData.paReq,
                                 @"TermUrl" : checkout.sendData.termUrl};
    [self callByUrl:[NSURL URLWithString:checkout.url] aParams:dictionary onSuccess:^(NSData *data) {
        NSString *htmlPageContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        PayConfirmation *confirmation = [[PayConfirmation alloc] initPayConfirmation:htmlPageContent
                                                                                aUrl:checkout.sendData.termUrl
                                                                         onConfirmed:^(NSString *jsonOfConfirmation)
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonOfConfirmation dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSString *url = [json objectForKey:@"url"];
            if (![url isEqualToString:URL_CALLBACK]) {
               @throw [NSException exceptionWithName:@"" reason:nil userInfo:nil];
            }
            NSDictionary *orderData = [json objectForKey:@"params"];
            [self checkResponse:orderData];
            [delegate onPaidSuccess:[self parseOrder:orderData]];
        }];
        [delegate onWaitConfirm];
        
        // Delay execution of my block for 10 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.cloudipspView confirm:confirmation];
        });
        
        
    } payDelegate:delegate];
}


- (void)pay:(Card *)card aOrder:(Order *)order aPayCallbackDelegate:(id<PayCallbackDelegate>)payCallbackDelegate {
    if (![card isValidCard]) {
        @throw [NSException exceptionWithName:@"IllegalArgumentException"
                                       reason:@"Card should be valid"
                                     userInfo:nil];
    }
    
    PayCallbackDelegateMainWrapper *wrapper = [PayCallbackDelegateMainWrapper wrapperWithOrigin:payCallbackDelegate];
    
    [self getToken:order onSuccess:^(NSString *token) {
        [self checkout:card aToken:token aEmail:order.email onSuccess:^(Checkout *checkout) {
            if (checkout.action == WITHOUT_3DS) {
                [self order:token onSuccess:^(Receipt *receipt) {
                    [wrapper onPaidSuccess:receipt];
                } payDelegate:wrapper];
            } else {
                [self url3ds:checkout aPayCallbackDelegate:wrapper];
            }
        } payDelegate:wrapper];
    } payDelegate:wrapper];
}

@end

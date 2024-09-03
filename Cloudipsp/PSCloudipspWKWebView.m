//
//  PSCloudipspWKWebView.m
//  Pods
//
//  Created by Nadiia Dovbysh on 5/16/16.
//
//

#import "PSCloudipspWKWebView.h"

NSString * const URL_START_PATTERN = @"http://secure-redirect.cloudipsp.com/submit/#";

@interface PSPayConfirmation (private)

@property (nonatomic, strong, readonly) NSString *htmlPageContent;
@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSString *callbackUrl;
@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, copy, readonly) OnConfirmed onConfirmed;

@end

@interface PSCloudipspWKWebView () <WKNavigationDelegate>

@property (nonatomic, strong) PSPayConfirmation *confirmation;

@end

@implementation PSCloudipspWKWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(nonnull WKWebViewConfiguration *)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.hidden = YES;
    }
    return self;
}

#pragma mark - PSCloudipspView

- (void)confirm:(PSPayConfirmation *)confirmation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = NO;
    });
    if (confirmation == nil) {
        @throw [NSException exceptionWithName:@"NullPointerException" reason:@"confirmation should be not null" userInfo:nil];
    }
    self.confirmation = confirmation;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationDelegate = self;
        [self loadHTMLString:confirmation.htmlPageContent baseURL:[NSURL URLWithString:confirmation.url]];
    });
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = [navigationAction.request.URL absoluteString];
    BOOL detectsStartPattern = [url hasPrefix:URL_START_PATTERN];
    BOOL detectsCallbackUrl = NO;
    BOOL detectsApiToken = NO;
    if (!detectsStartPattern) {
        detectsCallbackUrl = [url hasPrefix:self.confirmation.callbackUrl];
        
        if (!detectsCallbackUrl) {
            detectsApiToken = [url hasPrefix:[NSString stringWithFormat:@"%@/api/checkout?token=", self.confirmation.host]];
        }
    }
    
    if (detectsStartPattern || detectsCallbackUrl || detectsApiToken) {
        NSString *jsonContent = nil;
        if (detectsStartPattern) {
            jsonContent = [url substringFromIndex:[URL_START_PATTERN length]];
            jsonContent = [jsonContent stringByRemovingPercentEncoding];
        }
        self.confirmation.onConfirmed(jsonContent);
        self.hidden = YES;
        self.confirmation = nil;
        self.navigationDelegate = nil;
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences * _Nonnull))decisionHandler  API_AVAILABLE(ios(13.0)){
    [self webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:^void(WKNavigationActionPolicy policy) {
        decisionHandler(policy, preferences);
    }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if(!webView.isLoading) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end

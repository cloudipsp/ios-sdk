//
//  CloudipspWebView.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "CloudipspWebView.h"

NSString * const URL_START_PATTERN = @"http://secure-redirect.cloudipsp.com/submit/#";


@interface PayConfirmation (private)

@property (nonatomic, strong, readonly) NSString *htmlPageContent;
@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, copy, readonly) OnConfirmed onConfirmed;

@end

@interface CloudipspWebView () <UIWebViewDelegate>

@property (nonatomic, strong) PayConfirmation *confirmation;

@end

@implementation CloudipspWebView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
//        self.hidden = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.hidden = YES;
    }
    return self;
}

#pragma mark - CloudipspView

- (void)confirm:(PayConfirmation *)confirmation {
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.hidden = NO;
    });
    if (confirmation == nil) {
        @throw [NSException exceptionWithName:@"NullPointerException" reason:@"confirmation should be not null" userInfo:nil];
    }
    self.delegate = self;
    self.confirmation = confirmation;
    [self loadHTMLString:confirmation.htmlPageContent baseURL:[NSURL URLWithString:confirmation.url]];
    NSLog(@"htmlPageContent - %@", confirmation.htmlPageContent);
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [request.URL absoluteString];
    if ([url hasPrefix:URL_START_PATTERN]) {
        NSString *jsonContent = [url substringFromIndex:[URL_START_PATTERN length]];
        jsonContent = [jsonContent stringByRemovingPercentEncoding];
        self.confirmation.onConfirmed(jsonContent);
//        self.hidden = YES;
        self.confirmation = nil;
        NSLog(@"JSON: %@", jsonContent);
        self.delegate = nil;
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if(!webView.isLoading) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end

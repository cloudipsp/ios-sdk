//
//  PayConfirmation.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "PayConfirmation.h"

@interface PayConfirmation ()

@property (nonatomic, strong) NSString *htmlPageContent;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, copy) OnConfirmed onConfirmed;

@end

@implementation PayConfirmation

- (instancetype)initPayConfirmation:(NSString *)htmlPageContent
                               aUrl:(NSString *)url
                        onConfirmed:(OnConfirmed)onConfirmed
{
    self = [super init];
    if (self) {
        self.htmlPageContent = htmlPageContent;
        self.url = url;
        self.onConfirmed = onConfirmed;
    }
    return self;
}


@end

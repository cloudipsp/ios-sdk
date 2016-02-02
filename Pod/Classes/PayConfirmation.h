//
//  PayConfirmation.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/26/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OnConfirmed)(NSString *jsonOfConfirmation);

@interface PayConfirmation : NSObject

- (instancetype)initPayConfirmation:(NSString *)htmlPageContent
                               aUrl:(NSString *)url
                        onConfirmed:(OnConfirmed)onConfirmed;

@end

@protocol CloudipspView <NSObject>

- (void)confirm:(PayConfirmation *)confirmation;

@end

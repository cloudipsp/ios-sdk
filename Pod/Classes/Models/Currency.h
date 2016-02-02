//
//  Currency.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CurrencyUnknown,
    CurrencyUAH,
    CurrencyRUB,
    CurrencyUSD,
    CurrencyEUR,
    CurrencyGBP
} Currency;

NSString *getCurrencyName(Currency сurrency);
Currency getCurrency(NSString *name);

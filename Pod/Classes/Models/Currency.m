//
//  Currency.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "Currency.h"

NSString *stringWithCurrency(Currency sign) {
    NSArray *arr = @[
                     @"UNKNOWN",
                     @"UAH",
                     @"RUB",
                     @"USD",
                     @"EUR",
                     @"GBP"
                     ];
    return (NSString *)[arr objectAtIndex:sign];
}

Currency currencyWithString(NSString *str) {
    NSArray *arr = @[
                     @"UNKNOWN",
                     @"UAH",
                     @"RUB",
                     @"USD",
                     @"EUR",
                     @"GBP"
                     ];
    return (Currency)[arr indexOfObject:str];
}

NSString *getCurrencyName(Currency сurrency) {
    return stringWithCurrency(сurrency);
}

Currency getCurrency(NSString *currencyName) {
    if (currencyName == nil) {
        return CurrencyUnknown;
    }
    
    return currencyWithString(currencyName);
}

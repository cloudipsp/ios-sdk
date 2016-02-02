//
//  Utils.h
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 1/24/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (BOOL)isValidatEmail:(NSString *)candidate;
+ (BOOL)isEmpty:(NSString *)candidate;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

@end

//
//  Utility.h
//  Autism
//
//  Created by Neuron-iPhone on 3/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (BOOL)isValidateUrl: (NSString *)url;
+ (BOOL)isValidString:(NSString *)string;

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;
+ (BOOL) NSStringIsValidName:(NSString *)checkString;
+ (NSString*)getValidString:(NSString *)string;
+ (NSString *)getUrlStringWithHttpVerb:(NSString *)url;
+ (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title;
+ (void)showNetWorkAlert;

+ (void)setTitleColor:(UINavigationItem *)navigationItem;
+ (NSDate *)getUTCFormateDate:(double)timeInSeconds;
extern id ObjectOrNull(id object);

+ (NSString *)appVersion;
+ (NSString *)build;
@end

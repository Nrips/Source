//
//  Utility.m
//  Autism
//
//  Created by Neuron-iPhone on 3/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "Utility.h"
#import "Constants.h"

@implementation Utility

#pragma mark - Validation

+ (BOOL)isValidateUrl:(NSString *)url {
    
    /*NSString *urlRegEx =
     
     @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
     
     NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
     
     return [urlTest evaluateWithObject:url];*/
    
    NSURL *candidateURL = [NSURL URLWithString:url];
    
    // WARNING > "test" is an URL according to RFCs, being just a path
    
    // so you still should check scheme and all other NSURL attributes you need
    if (candidateURL && candidateURL.scheme && candidateURL.host) {
        
        // candidate is a well-formed url with:
        
        //  - a scheme (like http://)
        
        //  - a host (like stackoverflow.com)
        
        return YES;
    }
    return NO;
}

+ (NSString *)getUrlStringWithHttpVerb:(NSString *)url {
    
    [self getValidString:url];
    if (!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])) {
        
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    return url;
}

+ (BOOL)isValidString:(NSString *)string

{
    if (string == (id)[NSNull null] || string.length == 0 || [string isEqualToString:@"null"] )
        
        return NO;
    return YES;
}


+ (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


+ (BOOL)NSStringIsValidName:(NSString *)checkString
{
    NSString *nameRegex = @"[A-Za-z]+";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    return [nameTest evaluateWithObject:checkString];
}

+ (NSString*)getValidString:(NSString *)string
{
    if ([string isKindOfClass:[NSNull class]] || [string isEqualToString:@"<null>"])
        string = @"";

    if (string.length > 0) {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    } else {
        string = @"";
    }
    return string;
}


#pragma mark - Show Alert 

// Show an alert message
+ (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    [appDelegate showAlertMessage:message withTitle:title];
}

// Show an Network alert message

+ (void)showNetWorkAlert
{
    [appDelegate showNetWorkAlert];
}




// Set Applications green title color of View controller
+ (void)setTitleColor:(UINavigationItem *)navigationItem
{
		DLog(@"navigationItem.title: %@", navigationItem.title);
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.text = navigationItem.title;
		label.backgroundColor = [UIColor clearColor];
        //label.font = [UIFont boldSystemFontOfSize:15.0];
      //label.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:15];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.textColor = appUIGreenColor;
		navigationItem.titleView = label;
		[label sizeToFit];
}

+ (NSDate *)getUTCFormateDate:(double)timeInSeconds
{
    
    NSTimeInterval mytime = timeInSeconds;
    DLog(@"mytime:%f",mytime);
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:mytime];
    DLog(@"localDate:%@",localDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    //return dateString;
    return [dateFormatter dateFromString:dateString];
}

//Method for passing null values when intented values are not available.
extern id ObjectOrNull(id object)
{
    return object ?: @"";
}


+ (NSString *) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

@end

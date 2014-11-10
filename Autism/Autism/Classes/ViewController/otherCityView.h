//
//  otherCityView.h
//  Autism
//
//  Created by Vikrant Jain on 2/1/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface otherCityView : UITableViewController
<NSURLConnectionDataDelegate>

{
    NSMutableData *responseData;
    NSMutableArray *arrData;
    NSMutableArray *arrCityHeader;
    
    NSDictionary *jsonDict;
}

@end

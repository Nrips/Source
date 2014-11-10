//
//  AppSharedData.h
//  Autism
//
//  Created by Haider on 01/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSharedData : NSObject
+ (AppSharedData*)sharedInstance;

-(void) removeLoadingView ;
- (void)showCustomLoaderWithTitle:(NSString*)title message:(NSString*)message;


@property (nonatomic, strong) NSMutableDictionary *imageCacheDictionary;

@end

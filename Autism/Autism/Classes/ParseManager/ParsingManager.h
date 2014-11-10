//
//  ParsingManager.h
//  Autism
//
//  Created by Haider on 03/02/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingManager : NSObject
+ (ParsingManager*)sharedManager;
- (id)parseResponse:(id)response forTask:(TaskType)task;

@property(nonatomic,strong) NSArray *providerService;

@end

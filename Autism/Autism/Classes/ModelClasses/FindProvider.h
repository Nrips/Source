//
//  FindProvider.h
//  Autism
//
//  Created by Neuron Solutions on 5/13/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FindProvider : NSObject

@property (nonatomic, strong) NSString *providerName;
@property (nonatomic, strong) NSString *providerDescription;
@property (nonatomic, strong) NSString *providerRating;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *providerCategory;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *providerId;
@property (nonatomic, strong) NSMutableArray *providerServices;
@property (nonatomic) BOOL checkInCircle;
@property (nonatomic) BOOL isSelfProvider;

@end

//
//  ProviderInCircle.h
//  Autism
//
//  Created by Neuron-iPhone on 5/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProviderInCircle : NSObject

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *services;
@property (strong, nonatomic) NSString *rating;
@property (strong, nonatomic) NSString *zipcode;
@property (strong, nonatomic) NSString *providerId;
@property (nonatomic) BOOL isProviderInCircle;


@end

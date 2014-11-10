//
//  PersonInFinder.h
//  Autism
//
//  Created by Neuron-iPhone on 2/22/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonInFinder : NSObject



@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *role;
@property (nonatomic,strong) NSString  *UserID;
@property (nonatomic,strong) NSString  *localAuthority;
@property (nonatomic) BOOL isInCircle;
@property (nonatomic) BOOL isMemeberBlocked;

@end

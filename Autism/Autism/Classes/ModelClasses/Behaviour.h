//
//  Behaviour.h
//  Autism
//
//  Created by Dipak on 6/3/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Behaviour : NSObject
@property (nonatomic, strong) NSString *behaviourCategoryName;
@property (nonatomic, strong) NSString *behaviourID;
@property (nonatomic, strong) NSMutableArray *behaviourArray;

@end

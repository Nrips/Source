//
//  MemberInFamily.h
//  Autism
//
//  Created by Neuron-iPhone on 5/31/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberInFamily : NSObject

@property (nonatomic,strong) NSString *kidId;
@property (nonatomic,strong) NSString *age;
@property (nonatomic,strong) NSString *detail;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *image;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *month;
@property (nonatomic,strong) NSString *year;
@property (nonatomic,strong) NSString *bdaydate;
@property (nonatomic) BOOL isAlreadyReported;
@property (nonatomic) BOOL isSelf;
@property (nonatomic,strong) NSArray *behaviourArray;
@property (nonatomic,strong) NSArray *relationArray;
@property (nonatomic,strong) NSArray *diagnosisArray;
@property (nonatomic,strong) NSArray *treatmentArray;




@end

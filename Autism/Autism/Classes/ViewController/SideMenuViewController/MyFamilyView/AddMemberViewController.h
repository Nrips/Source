//
//  AddMemberViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/13/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AddMemberViewController : UIViewController

@property (nonatomic) NSInteger editFamilyId;
@property (nonatomic,strong) NSString *kidIdPass;
@property (nonatomic,strong) NSString *agePass;
@property (nonatomic,strong) NSString *namePass;
@property (nonatomic,strong) NSString *monthPass;
@property (nonatomic,strong) NSString *yearPass;
@property (nonatomic,strong) NSString *bdayPass;
@property (nonatomic,strong) NSString *genderPassValue;
@property (nonatomic,strong) NSString *diagnoseIdPass;
@property (nonatomic,strong) NSString *diagnoseTextPass;
@property (nonatomic,strong) NSString *relationIdPass;
@property (nonatomic,strong) NSString *relationTextPass;

@property (nonatomic,strong) NSString *callerView;

@property (nonatomic,strong) UIImage *imagMember;

@property (nonatomic,strong) NSArray *beahvIdArray;
@property (nonatomic,strong) NSArray *treatIdArray;

@property (nonatomic,strong) NSArray *behavArray;
@property (nonatomic,strong) NSArray *treatArray;
@property(nonatomic)BOOL isImageRemove;

@end

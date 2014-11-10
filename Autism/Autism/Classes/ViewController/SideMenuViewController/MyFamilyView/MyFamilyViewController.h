//
//  MyFamilyViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/13/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyFamilyViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSString *otherMemberId;
@property(nonatomic,strong) NSString *profileType;

@end

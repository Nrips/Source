//
//  MyEventLeftMenuViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 5/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEventLeftMenuViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *baseImageView;
@property(nonatomic,strong) NSString *otherMemberId;
@property(nonatomic,strong) NSString *profileType;
@property (nonatomic, strong) NSString *parentViewControllerName;

@end

//
//  MyCircleViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 3/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//




#import <UIKit/UIKit.h>

@interface MyCircleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *rootView;
@property (strong, nonatomic) IBOutlet UIImageView *baseImageView;
@property (strong, nonatomic) IBOutlet UIButton *btnFindProvider;
@property (strong, nonatomic) IBOutlet UIButton *btnFindPeople;

@property(nonatomic,strong) NSString *profileType;
@property(nonatomic,strong) NSString *otherMemberId;
@property (nonatomic, strong) NSString *parentViewControllerName;

@end

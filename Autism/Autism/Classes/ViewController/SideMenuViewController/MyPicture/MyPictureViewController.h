//
//  MyPictureViewController.h
//  Autism
//
//  Created by Neuron Solutions on 7/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPictureViewController : UIViewController
@property (nonatomic, strong) NSString *parentViewControllerName;
@property(nonatomic,strong) NSString *otherMemberId;
@property(nonatomic,strong) NSString *profileType;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;

@end

//
//  OtherStoryViewController.h
//  Autism
//
//  Created by Dipak on 6/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherStoryViewController : UIViewController

@property(nonatomic,strong) NSString *otherUserId;
@property (nonatomic, strong) NSString *parentViewControllerName;
@property(nonatomic,strong) NSString *profileType;
@property (strong, nonatomic) NSArray *arrID;
@property (strong, nonatomic) NSArray *arrQuestionID;
@property (weak, nonatomic) IBOutlet UITableView *otherStoryTableView;
@end

//
//  HelpfulDetailViewController.h
//  Autism
//
//  Created by Vikrant Jain on 4/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpfulDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tblHelpfulView;
@property (strong, nonatomic) IBOutlet UITextView *txtViewQuestion;

@property (nonatomic,strong)NSString *strgetQuestion;
@property(strong,nonatomic)NSString *helpfulQuestionId;
@property(nonatomic,strong)NSString *viewType;
@property (nonatomic, strong) NSString *parentViewControllerName;
@property (nonatomic,strong) NSString  *replyCount;


@end

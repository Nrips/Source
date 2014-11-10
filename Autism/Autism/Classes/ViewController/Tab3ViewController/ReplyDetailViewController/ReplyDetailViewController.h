//
//  ReplyDetailViewController.h
//  Autism
//
//  Created by Vikrant Jain on 4/10/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface ReplyDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblReplyView;
@property (strong, nonatomic) IBOutlet CustomLabel *lblQuestion;

//@property (nonatomic,strong) NSString *strgetQuestion;
@property(strong,nonatomic) NSString *replyQuestionId;
@property(nonatomic,strong) NSString *viewType;
@property(nonatomic) BOOL isCheckHelpful;

@property (nonatomic,strong) NSString  *strGetQuestionId;
@property (nonatomic,strong) NSString  *strgetQuestion;
@property (nonatomic,strong) NSString  *QADetails;
@property (nonatomic,strong) NSString  *imageURL;
@property (nonatomic,strong) NSString  *userName;
@property (nonatomic,strong) NSString  *helpfulCount;
@property (nonatomic,strong) NSString  *replyCount;


@property (nonatomic, strong) NSString *parentViewControllerName;

@end

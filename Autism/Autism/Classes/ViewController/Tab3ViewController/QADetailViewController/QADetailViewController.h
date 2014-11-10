//
//  QADetailViewController.h
//  Autism
//
//  Created by Vikrant Jain on 4/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"
#import "STTweetLabel.h"
#import "GetAllQuestion.h"

@protocol QADetailViewDelegate<NSObject>
- (void)updateQASection;
@end

@interface QADetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSString  *strGetQuestionId;
@property (nonatomic,strong) NSString  *strgetQuestion;
@property (nonatomic,strong) NSString  *QADetails;
@property (nonatomic,strong) NSString  *imageURL;
@property (nonatomic,strong) NSString  *userName;
@property (nonatomic,strong) NSString  *helpfulCount;
@property (nonatomic,strong) NSString  *replyCount;
@property (nonatomic,strong) NSArray   *qaTagArray;
@property (nonatomic,strong) NSString  *memberQuestionId;
@property (nonatomic,strong) NSString  *questionMemberId;

@property (nonatomic, strong) NSString  *isSelfQuestion;
@property (nonatomic, strong) NSString  *isReportAWM;
@property (nonatomic, strong) NSString  *isBlockedMember;
@property (nonatomic, strong) NSString  *isCircleStatus;



@property (nonatomic)BOOL checkHelpfull;
@property (nonatomic)float qaDetailHeight;


@property(strong,nonatomic)IBOutlet CustomLabel  *lblQuestion;
@property(strong,nonatomic)IBOutlet STTweetLabel  *lblQuestionDetail;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;

@property(nonatomic) BOOL isCheckHelpful;
@property(nonatomic,weak) id<QADetailViewDelegate>delegate;
@property (nonatomic, strong) NSString *parentViewControllerName;
@property (nonatomic, strong) NSString *profileType;;

@property (nonatomic, strong) GetAllQuestion *question;


@property (strong, nonatomic) IBOutlet UILabel *lblName;

@end

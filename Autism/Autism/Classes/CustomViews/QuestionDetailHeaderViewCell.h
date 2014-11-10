//
//  QuestionDetailHeaderViewCell.h
//  Autism
//
//  Created by Neuron Solutions on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTweetLabel.h"
#import "MyImageView.h"

@protocol QuestionDetailHeaderViewCellDelegate <NSObject>

@optional

- (void)replyButtonPressed :(NSString *)questionID buttonState:(BOOL)selected;
- (void)clickOnHelpfulButton:(NSString*)questionID ;
- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType;
- (void)clickOnMemeberName:(NSString*)memeberID;
- (void)clickOnHelpfulCircle;
- (void)clickOnReplyCircle;
- (void)memberSuccessfullyAddedInCircle;
- (void)memberSuccessfullyBlocked;
- (void)showReportToAWMViewWithReportID:(NSString*)reportID;
- (void)helpfulSuccessfully;


@end

@interface QuestionDetailHeaderViewCell : UITableViewCell<UIActionSheetDelegate>
{
    CGRect topViewFrame;
}

-(void)passHeaderValue:(NSString*)strName question:(NSString *)strQuestion questionDetail:(NSString *)strQuestionDetail
           helpfulCount:(NSString *)btnHelpfulCount  replyCount:(NSString *)btnReplyCount   profileImage:(NSString *)imageUrl questionID:(NSString *)strQuestionId questionTagArray:(NSArray *)tagArray headerHeight:(float)height helpfulCheck:(BOOL)checkSelected  memberID:(NSString *)strMemberId questionDetailHeight:(float)qaDetailHeight questionAddedMemberID:(NSString *)questionAddedMemberID memberBlocked:(NSString*)Blocked isSelfQuestion:(NSString*)selfQuestion isMemberReport:(NSString*)repoted isMemberInCircle:(NSString*)circleStatus;

+ (QuestionDetailHeaderViewCell *)cellFromNibNamed:(NSString *)nibName;


@property (nonatomic,weak) id <QuestionDetailHeaderViewCellDelegate>delegate;

@property(nonatomic) BOOL isCheckHelpful;
@property (nonatomic,strong) UIFont*questionFont;
@property(nonatomic, strong) UIActionSheet *actionSheet;

@property(strong,nonatomic)IBOutlet UILabel *lblQuestion;
@property(strong,nonatomic)IBOutlet UILabel *lblName;
@property(strong,nonatomic)IBOutlet STTweetLabel *lblQuestionDetail;

@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIImageView *detailHeaderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *qaIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (strong, nonatomic) IBOutlet UIButton *btnHelpful;
@property (strong, nonatomic) IBOutlet UIButton *btnHelpfulCircle;
@property (strong, nonatomic) IBOutlet UIButton *btnReplyCircle;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property(strong,nonatomic)IBOutlet MyImageView* profileimage;
@property (strong, nonatomic) IBOutlet UIButton *btnReportToAwm;



@property (strong, nonatomic)NSString *questionID;
@property (strong, nonatomic)NSString *strhelpful;
@property (strong, nonatomic)NSString *memberId;
@property (nonatomic, strong)NSString *parentViewControllerName;
@property (nonatomic, strong)NSString *profileType;;




@property (nonatomic) BOOL isSelfQuestion;
@property (nonatomic) BOOL isQuestionReported;
@property (nonatomic, strong) NSString *addedQuestionMemberID;
@property (nonatomic) BOOL isMemberAlreadyInCircle;




@end

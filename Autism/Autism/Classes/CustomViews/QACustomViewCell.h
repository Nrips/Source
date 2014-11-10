//
//  Q+ACustomViewCell.h
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetAllQuestion.h"
#import "GetMyQuestion.h"
#import "MyImageView.h"
#import "CustomLabel.h"
#import "STTweetLabel.h"


@protocol QACustomViewCellDelegate <NSObject>

@optional
- (void)questionDeletedAction;
- (void)questionUpdatedAction;
- (void)helpfulSuccessfully;
- (void)memberSuccessfullyAddedInCircle:(BOOL)circleStatus:(NSString*)circleMemberID;
- (void)memberSuccessfullyBlocked:(BOOL)blockStatus:(NSString*)blockMemberId;
- (void)replyButtonPressedAtRow :(long)row withQuestionID:(NSString *)questionID buttonState:(BOOL)selected;
- (void)showReportToAWMViewWithReportID:(NSString*)reportID;
- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(GetAllQuestion *)question;
- (void)clickOnHashTagForMyQA:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(GetMyQuestion *)question;
- (void)clickOnMemeberName:(NSString*)memeberID;

@end

@interface QACustomViewCell : UITableViewCell

+ (QACustomViewCell *)cellFromNibNamed:(NSString *)nibName;

-(void)configureMyCell:(GetMyQuestion *)MyQuestion qaLabelHeight:(float)labelHeight qaDetailLabelHeight:(float)detailLabelHeight andCellHeight:(float)cellHeight;

-(void)configureCell:(GetAllQuestion *)question qaLabelHeight:(float)labelHeight qaDetailLabelHeight:(float)detailLabelHeight andCellHeight:(float)cellHeight;

@property (nonatomic,weak) id <QACustomViewCellDelegate>delegate;

@property(strong,nonatomic)IBOutlet UILabel  *lblQuestion;
@property(strong,nonatomic)IBOutlet STTweetLabel *lblQuestionDetail;
//@property(strong,nonatomic)IBOutlet UILabel *lblQuestionDetail;
@property(strong,nonatomic)IBOutlet UILabel *lblTags;
@property(strong,nonatomic)IBOutlet CustomLabel  *lblReplies;
@property(strong,nonatomic)IBOutlet CustomLabel  *lblName;
@property(strong,nonatomic)NSArray *tagsArray;

@property (strong, nonatomic)IBOutlet UILabel *lblRepliesCount;
@property (strong, nonatomic)IBOutlet MyImageView *customImageView;
@property (strong, nonatomic)IBOutlet UILabel *lblHelpfulCount;
@property (nonatomic, strong)IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong)IBOutlet UIImageView *mainBGImageView;
@property (nonatomic, strong)IBOutlet UIImageView *arrowImageView;

@property (nonatomic,strong) NSString *questionId;
@property (strong,nonatomic) NSString *strQuestion;
@property (strong,nonatomic) NSString *strQuestionDetails;
@property (strong,nonatomic) NSString *imageURL;
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *strReplyCount;
@property (strong,nonatomic) NSArray *passQATagArray;
@property (strong,nonatomic) NSArray *qaTagArray;

@property (nonatomic) BOOL isSelfQuestion;
@property (nonatomic) BOOL checkHelpful;
@property (nonatomic) float qaDetailLabelHeight;

@property (nonatomic) BOOL isQuestionReported;
@property (nonatomic, strong) NSString *addedQuestionMemberID;
@property(nonatomic,strong) NSString *profileType;

@property (nonatomic) BOOL isMemberAlreadyInCircle;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *btnReportToAwm;
@property (strong, nonatomic) IBOutlet UIButton *btnHelpfulCircle;
@property (strong, nonatomic) IBOutlet UIButton *btnReplyCircle;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteQuestion;
@property (strong, nonatomic) IBOutlet UIButton *btnEditQuestion;

@property (strong, nonatomic)IBOutlet UIView *tagView;
@property (strong, nonatomic)IBOutlet UIView *buttonView;





-(IBAction)replyCircleAction:(id)sender;
-(IBAction)helpfulCircleAction:(id)sender;
-(IBAction)helpfulAction:(id)sender;
- (IBAction)replyButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnHelpful;

-(IBAction)readMore:(id)sender;

- (IBAction)deleteQuestionAction:(id)sender;
- (IBAction)EditQuestionAction:(id)sender;

@end

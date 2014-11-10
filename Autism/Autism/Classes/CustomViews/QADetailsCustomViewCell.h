//
//  QADetailsCustomViewCell.h
//  Autism
//
//  Created by Vikrant Jain on 4/14/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionDetail.h"
#import "HelpfulAnswer.h"
#import "ReplyQuestion.h"
#import "STTweetLabel.h"
#import "CommentViewController.h"

@protocol QADetailsCustomViewCelllDelegate <NSObject>

@optional
-(void)questionDetailDeleted;
-(void)questionDetailUpdated;
-(void)helpulAnswer;
-(void)likeAnswer;
- (void)replyButtonPressedAtRow :(long)row withQuestionID:(NSString *)questionID buttonState:(BOOL)selected;
- (void)showReportToAWMViewWithReportID:(NSString*)reportID;
- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(QuestionDetail *)question;
- (void)clickOnMemeberName:(NSString*)memeberID;

- (void)replyButtonPressedAtRow :(long)row withAnswerID:(NSString *)answerID answerText:(NSString *)answerText  andanswerTagArray:(NSArray *)answerTagArray buttonState:(BOOL)selected;


@end

@interface QADetailsCustomViewCell : UITableViewCell

-(void)configureDetailCell:(QuestionDetail *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;

+(QADetailsCustomViewCell *)cellFromNibNamed:(NSString *)nibName;
@property (nonatomic,weak) id <QADetailsCustomViewCelllDelegate>delegate;

@property (strong, nonatomic)IBOutlet UIImageView *imgLine;
@property (strong, nonatomic)IBOutlet UIImageView *imgLine1;
@property (strong, nonatomic)IBOutlet UIImageView *imgLine2;
@property (strong, nonatomic)IBOutlet UIImageView *imgclock;
@property (nonatomic, strong)IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong)IBOutlet UIImageView *mainBGImageView;
//@property (strong, nonatomic)IBOutlet UILabel *lblViewAnswer;

@property (strong, nonatomic)IBOutlet STTweetLabel *lblViewAnswer;

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblTags;
@property (strong, nonatomic) IBOutlet UILabel *lblclock;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;

@property(nonatomic,assign) BOOL isLike;
@property (nonatomic)BOOL checkHelpfull;
@property (nonatomic)BOOL checkLike;
@property (nonatomic) BOOL isSelfQuestion;
@property (nonatomic) BOOL isQuestionReported;


@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIButton *btnHelpful;
@property (strong, nonatomic) IBOutlet UIButton *btnReportToAwm;
@property (strong, nonatomic) IBOutlet UIButton *btnEditButton;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteButton;

@property (strong, nonatomic) IBOutlet UIButton *btnHug;
@property (nonatomic) BOOL isQuestionReplyReported;
@property (nonatomic, strong) NSString *questionReplyID;
@property (nonatomic, strong) NSString *questionID;
@property(strong,nonatomic)NSString *strhelpful;
@property (nonatomic, strong)NSString *questionReplyMemberID;
@property (nonatomic, strong)NSString *replyText;
@property (nonatomic, strong)NSArray *replyTagArray;


@property (strong, nonatomic)IBOutlet UIView *tagView;
@property (strong, nonatomic)IBOutlet UIView *buttonView;


- (IBAction)helpfullAction:(id)sender;
- (IBAction)LikeAction:(id)sender;
- (IBAction)deleteAnswer:(id)sender;
- (IBAction)editAnswer:(id)sender;

@end

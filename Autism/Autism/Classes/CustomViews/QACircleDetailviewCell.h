//
//  QACircleDetailviewCell.h
//  Autism
//
//  Created by Neuron Solutions on 5/19/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionDetail.h"
#import "HelpfulAnswer.h"
#import "ReplyQuestion.h"
#import "MyImageView.h"
#import "STTweetLabel.h"

@protocol QACircleDetailviewCellDelegate <NSObject>

@optional
- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(ReplyQuestion*)question;
- (void)clickOnHashTagForHelpful:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(HelpfulAnswer *)question;
- (void)clickOnMemeberName:(NSString*)memeberID;

@end

@interface QACircleDetailviewCell : UITableViewCell
+(QACircleDetailviewCell *)cellFromNibNamed:(NSString *)nibName;

-(void)configureCell:(ReplyQuestion *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;
-(void)configureHelpfulCell:(HelpfulAnswer *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;

@property (nonatomic,weak) id <QACircleDetailviewCellDelegate>delegate;

@property (nonatomic, strong) MyImageView *imageView;
@property (strong, nonatomic) IBOutlet STTweetLabel *lblViewAnswer;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (nonatomic, strong)IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) NSString *questionReplyID;
@end

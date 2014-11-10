//
//  QACircleDetailviewCell.m
//  Autism
//
//  Created by Neuron Solutions on 5/19/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "QACircleDetailviewCell.h"
#import "MyImageView.h"
#import "Utility.h"

@implementation QACircleDetailviewCell
@synthesize imageView;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (QACircleDetailviewCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    QACircleDetailviewCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[QACircleDetailviewCell class]]) {
            customCell = (QACircleDetailviewCell *)nibItem;
            break; // we have a winner
        }
    }
    customCell.imageView = [[MyImageView alloc]initWithFrame:CGRectMake(25,3,35,35)];
    [customCell.imageView setImage:[UIImage imageNamed:@"avatar-140.png"]];
    [customCell addSubview:customCell.imageView];
    return customCell;
}

-(void)configureHelpfulCell:(HelpfulAnswer *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    CGRect frame = self.lblViewAnswer.frame;
    frame.size.height = labelHeight + 5;
    self.lblViewAnswer.frame = frame;
    
    CGRect frame1 = self.bgImageView.frame;
    frame1.size.height = cellHeight;
    self.bgImageView.frame = frame1;
    
    [self.bgImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.bgImageView.layer setBorderWidth: 2.0];
     self.bgImageView.layer.cornerRadius = 0.7;

    [self.imageView configureImageForUrl:question.imageUrl];

    
    //For Hash Tagging
    ///////
     self.lblViewAnswer.callerView = kCallerViewHelpful;
    [self.lblViewAnswer setupFontColorOfHashTag];
     self.lblViewAnswer.helpfulQuestion = question;
    [self.lblViewAnswer setText:question.answer];
    self.questionReplyID = question.addedQuestionMemberID;
    
    __weak typeof(self) weakSelf = self;
    
    [self.lblViewAnswer setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[kHotWordHandle, kHotWordHashtag,kHotWordLink, kHotWordNotification];
        NSString *selectedString = [NSString stringWithFormat:@"%@ [%d,%d]: hotWorld: %@, hotWorldID:%@, %@", hotWords[hotWord], (int)range.location, (int)range.length, hotString, hotWorldID,(protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
        
        if (hotWord == 2 && ([Utility getValidString:hotString].length > 0))
        {
            NSString *lowercaseUrl = [hotString lowercaseString];
            if ([lowercaseUrl rangeOfString:@"http"].location == NSNotFound) {
                NSString *string = [NSString stringWithFormat:@"http://%@",hotString];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:hotString]];
            }
        }
          DLog(@"Clickeded UserID String:%@",selectedString);
        
        if ([weakSelf.delegate respondsToSelector:@selector(clickOnHashTagForHelpful:hashType:forQA:)]) {
            [weakSelf.delegate clickOnHashTagForHelpful:hotWorldID hashType:hotWords[hotWord] forQA:question];
        }
    }];
    ////

    [self.lblName setText:question.name];
}

- (void)configureCell:(ReplyQuestion *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    CGRect frame = self.lblViewAnswer.frame;
    frame.size.height = labelHeight + 5;
    self.lblViewAnswer.frame = frame;
    
    CGRect frame1 = self.bgImageView.frame;
    frame1.size.height = cellHeight;
    self.bgImageView.frame = frame1;
    
    [self.bgImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.bgImageView.layer setBorderWidth: 2.0];
    self.bgImageView.layer.cornerRadius = 0.7;

   [self.imageView configureImageForUrl:question.imageUrl];
    

    //For Hash Tagging
    ///////
    self.lblViewAnswer.callerView = kCallerViewReply;
    [self.lblViewAnswer setupFontColorOfHashTag];
    self.lblViewAnswer.replyQuestion = question;
    [self.lblViewAnswer setText:question.answer];
    self.questionReplyID = question.addedQuestionMemberID;
    
    __weak typeof(self) weakSelf = self;
    
    [self.lblViewAnswer setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[kHotWordHandle, kHotWordHashtag,kHotWordLink, kHotWordNotification];
        NSString *selectedString = [NSString stringWithFormat:@"%@ [%d,%d]: hotWorld: %@, hotWorldID:%@, %@", hotWords[hotWord], (int)range.location, (int)range.length, hotString, hotWorldID,(protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
        
        if (hotWord == 2 && ([Utility getValidString:hotString].length > 0))
        {
            NSString *lowercaseUrl = [hotString lowercaseString];
            if ([lowercaseUrl rangeOfString:@"http"].location == NSNotFound) {
                NSString *string = [NSString stringWithFormat:@"http://%@",hotString];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:hotString]];
            }
        }

        DLog(@"Clickeded UserID String:%@",selectedString);
        
        if ([weakSelf.delegate respondsToSelector:@selector(clickOnHashTag:hashType:forQA:)]) {
            [weakSelf.delegate clickOnHashTag:hotWorldID hashType:hotWords[hotWord] forQA:question];
            
            DLog(@"hot word id %@",hotWorldID);
        }
    }];
    
    [self.lblName setText:question.name];
 }

-(IBAction)memberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.questionReplyID);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.questionReplyID];
    }
}



@end

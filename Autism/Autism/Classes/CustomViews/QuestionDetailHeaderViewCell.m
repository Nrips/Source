//
//  QuestionDetailHeaderViewCell.m
//  Autism
//
//  Created by Neuron Solutions on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "QuestionDetailHeaderViewCell.h"
#import "MyImageView.h"
#import "ProfileShowViewController.h"
#import "Utility.h"
@implementation QuestionDetailHeaderViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.btnReportToAwm.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (QuestionDetailHeaderViewCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    QuestionDetailHeaderViewCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[QuestionDetailHeaderViewCell class]]) {
            customCell = (QuestionDetailHeaderViewCell*)nibItem;
            break; // we have a winner
        }
    }
    customCell.profileimage = [[MyImageView alloc]initWithFrame:CGRectMake(2, 2, 35,35)];
    [customCell.imageView setImage:[UIImage imageNamed:@"avatar-140.png"]];
    [customCell addSubview:customCell.imageView];
    return customCell;
}


-(void)passHeaderValue:(NSString *)strName question:(NSString *)strQuestion questionDetail:(NSString *)strQuestionDetail helpfulCount:(NSString *)btnHelpfulCount replyCount:(NSString *)btnReplyCount profileImage:(NSString *)imageUrl questionID:(NSString *)strQuestionId questionTagArray:(NSArray *)tagArray headerHeight:(float)height helpfulCheck:(BOOL)checkSelected memberID:(NSString *)strMemberId questionDetailHeight:(float)qaDetailHeight questionAddedMemberID:(NSString *)questionAddedMemberID memberBlocked:(NSString *)Blocked isSelfQuestion:(NSString *)selfQuestion isMemberReport:(NSString *)repoted isMemberInCircle:(NSString *)circleStatus

{
    
    self.questionFont = [UIFont systemFontOfSize:13.5];
    
  float  nameLabelHeight = [self calculateMessageStringHeight:strName];
  float questionLabelHeight = [self calculateMessageStringHeight:strQuestion];
  float questionDetailLabelHeight = qaDetailHeight;
    
    
    CGRect nameFrame = self.lblName.frame;
    nameFrame.size.height = nameLabelHeight;
    self.lblName.frame = nameFrame;
    
    CGRect frame = self.lblQuestion.frame;
    frame.origin.y = self.lblName.frame.origin.y + nameLabelHeight + QACELL_CONTENT_MARGIN;
    frame.size.height = questionLabelHeight;
    self.lblQuestion.frame = frame;
    

    CGRect QAImageFrame = self.qaIconImageView.frame;
    frame.origin.y = self.lblQuestion.frame.origin.y;
    self.qaIconImageView.frame = QAImageFrame;
    
    CGRect qaDetailLabelFrame = self.lblQuestionDetail.frame;
    qaDetailLabelFrame.origin.y = self.lblQuestion.frame.origin.y + questionLabelHeight + QACELL_CONTENT_MARGIN;
    
    qaDetailLabelFrame.size.height = questionDetailLabelHeight;
    self.lblQuestionDetail.frame = qaDetailLabelFrame;
    
    CGRect buttonViewFrame = self.buttonView.frame;
    buttonViewFrame.origin.y = self.lblQuestionDetail.frame.origin.y + questionDetailLabelHeight + QACELL_CONTENT_MARGIN + BUTTON_VIEW_MERGIN;
    self.buttonView.frame= buttonViewFrame;
    
    
    CGRect bgImageFrame = self.bgImageView.frame;
    bgImageFrame.size.height = self.lblName.frame.origin.y + questionLabelHeight + questionDetailLabelHeight + QADETAILBUTTON_VIEW_HEIGHT+ NAMELABEL_HEIGHT + 40;
    self.bgImageView.frame = bgImageFrame;
    
    
    [self.lblName setText:strName];
    [self.lblQuestion setText:strQuestion];
    [self.lblQuestionDetail setText:strQuestionDetail];
    
    //For Hash Tagging
    ///////
    
    self.lblQuestionDetail.callerView = kCallerViewQADetailHeader;
    [self.lblQuestionDetail setupFontColorOfHashTag];
    self.lblQuestionDetail.QATagArray = [[NSArray alloc] initWithArray:tagArray];
    //self.lblQuestionDetail.qaDetail = [[NSString alloc]initWithString:strQuestionDetail];;
    self.lblQuestionDetail.text = strQuestionDetail;
    
      __weak typeof(self) weakSelf = self;
    
    [self.lblQuestionDetail setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[kHotWordHandle, kHotWordHashtag,kHotWordLink, kHotWordNotification];
        NSString *selectedString = [NSString stringWithFormat:@"%@ [%d,%d]: hotWorld: %@, hotWorldID:%@, %@", hotWords[hotWord], (int)range.location, (int)range.length, hotString, hotWorldID,(protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
        

        if ([weakSelf.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
            [weakSelf.delegate clickOnMemeberName:hotWorldID];
          }
    }];

    
   
  
    
    self.isSelfQuestion = [selfQuestion boolValue];
    self.isQuestionReported = [repoted boolValue];
    self.isMemberAlreadyInCircle = [circleStatus boolValue];
    self.addedQuestionMemberID = questionAddedMemberID;
    
    self.btnHelpful.selected = checkSelected;
    self.questionID = strQuestionId;
    [self.profileimage configureImageForUrl:imageUrl];
     self.memberId = strMemberId;
    
     [self.btnHelpfulCircle setTitle:btnHelpfulCount forState:UIControlStateNormal];
    [self.btnReplyCircle setTitle:btnReplyCount forState:UIControlStateNormal];
    
    
if ([self.parentViewControllerName isEqualToString:kCallerViewMyQA]) {
        
    
     self.btnReportToAwm.hidden = YES;
    }
    else{
        if (self.isSelfQuestion){
            self.btnReportToAwm.hidden = YES;
            
            //self.btnDeleteQuestion.hidden = NO;
            //self.btnEditQuestion.hidden = NO;
            //DLog(@"%hhd",self.isSelfQuestion);
           }
        else{
            self.btnReportToAwm.hidden = NO;
        }
     }
 }

-(float)calculateMessageStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(244, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.questionFont} context:nil];
    return textRect.size.height;
}


- (IBAction)memberNameBtnPressed:(id)sender {
    
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.memberId);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.memberId];
    }
}

- (IBAction)HelpfulCirclePressed:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(clickOnHelpfulCircle)])
        [self.delegate clickOnHelpfulCircle];
}

- (IBAction)replyCirclePressed:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(clickOnReplyCircle)])
        [self.delegate clickOnReplyCircle];
}


- (IBAction)replyButtonPressed:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(replyButtonPressed:buttonState:)])
        [self.delegate replyButtonPressed:self.questionID buttonState:self.replyButton.selected];
}


- (IBAction)helpfullAction:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.questionID)
    {
        DLog(@"likeActivity api call not perform because ActivityId is not exist");
        return;
    }
    
    self.btnHelpful.selected = !self.btnHelpful.selected;
    
    DLog(@"memeberID:%@, questionID:%@",[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],self.questionID);
    
    NSDictionary *askQuestionParameters = @{  @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"question_id" : self.questionID,
                                              
                                              };
    
    
    DLog(@"Performing HelpFullQuestion api with parameter :%@",askQuestionParameters);
    
    NSString *getQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_HelpfulCount];
    
    [serviceManager executeServiceWithURL:getQuestionUrl andParameters:askQuestionParameters forTask:kTaskPostQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"HelpFullQuestion api response :%@",response);
        
        NSDictionary *dict = (NSDictionary *)response;
        NSArray *dataArray = [dict valueForKey:@"data"];
        self.strhelpful = [[dataArray valueForKey:@"usefulCount"]stringValue];
        [self.btnHelpfulCircle setTitle:self.strhelpful forState:UIControlStateNormal];
    }];
}


- (IBAction)reportToAWMButtonPressed:(id)sender {
    
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
       self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kTitleReportToAWM, nil];
      }
    else{
    
    NSString *inCircleButtonTitle = self.isMemberAlreadyInCircle ? kTitleInCircle : kTitleAddToCircle;
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:inCircleButtonTitle, kTitleBlockUserFromQA, kTitleReportToAWM, nil];
    }
    self.actionSheet.delegate = self;
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [self.actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqual: kTitleInCircle] || [title isEqual:kTitleAddToCircle])
    {
        [self addToCircleApiCall];
    }else if([title isEqual: kTitleBlockUserFromQA])
    {
        [self blockUserFromQAApiCall];
    }
    else if([title isEqual:kTitleReportToAWM])
    {
        if (self.isQuestionReported) {
            [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Already Reported"];
            return;
        }
        if([self.delegate respondsToSelector:@selector(showReportToAWMViewWithReportID:)])
        {
            [self.delegate showReportToAWMViewWithReportID:self.questionID];
        }
    }
    [self.actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}



-(void)addToCircleApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.addedQuestionMemberID) {
        DLog(@"Person id whom you want to add does not exist");
        return;
    }
    NSDictionary *addToCircleParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"add_member_id" : self.addedQuestionMemberID,
                                            };
    NSString *addToCircleUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_AddMemberInTeam];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,addToCircleUrl, addToCircleParameters);
    
    [serviceManager executeServiceWithURL:addToCircleUrl andParameters:addToCircleParameters forTask:kTaskAddMemberInTeam completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,addToCircleUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if([[dict objectForKey:@"is_memmber_added_incircle"] boolValue]){
                    [Utility showAlertMessage:@"" withTitle:@"Member added successfully in your circle."];
                } else {
                    [Utility showAlertMessage:@"" withTitle:@"Member successfully removed from your circle."];
                }
                
                if([self.delegate respondsToSelector:@selector(memberSuccessfullyAddedInCircle)])
                    [self.delegate memberSuccessfullyAddedInCircle];
                
            } else if ([[dict valueForKey:@"is_blocked"] boolValue]){
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else {
                [Utility showAlertMessage:@"Member could not be added in your cirlce. Please try again." withTitle:@""];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}


-(void)blockUserFromQAApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.addedQuestionMemberID) {
        DLog(@"Person id whom you want to block does not exist");
        return;
    }
    
    NSDictionary *blockMemberParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           @"block_member_id" : self.addedQuestionMemberID,
                                           };
    
    NSString *blockMemberUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_BlockUserFromQA];
    DLog(@"Performing %@ api \n with parameter:%@",blockMemberUrl,blockMemberParameters);
    
    [serviceManager executeServiceWithURL:blockMemberUrl andParameters:blockMemberParameters forTask:kTaskBlockUserFromQA completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"blockMemberUrl api response :%@",response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"" withTitle:[dict valueForKey:@"message"]];
                if([self.delegate respondsToSelector:@selector(memberSuccessfullyBlocked)]){
                    [self.delegate memberSuccessfullyBlocked];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else {
                if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                    [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
                } else {
                    [Utility showAlertMessage:@"Member could not be added in your cirlce. Please try again." withTitle:@""];
                }
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}



@end

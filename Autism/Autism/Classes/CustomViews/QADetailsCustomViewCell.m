
//  QADetailsCustomViewCell.m
//  Autism
//
//  Created by Vikrant Jain on 4/14/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "QADetailsCustomViewCell.h"
#import "MyImageView.h"
#import "Utility.h"

@interface QADetailsCustomViewCell()<UIActionSheetDelegate>

@property (nonatomic, strong) MyImageView *imageView;
@property(nonatomic, strong) UIActionSheet *actionSheet;

- (IBAction)reportToAWMButtonPressed:(id)sender;
@end


@implementation QADetailsCustomViewCell
@synthesize  imageView;



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
    }
 return self;
    
}
+(QADetailsCustomViewCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    QADetailsCustomViewCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[QADetailsCustomViewCell class]]) {
            customCell = (QADetailsCustomViewCell*)nibItem;
            break; // we have a winner
        }
    }
    customCell.imageView = [[MyImageView alloc]initWithFrame:CGRectMake(18,1,35,35)];
    [customCell.imageView setImage:[UIImage imageNamed:@"avatar-140.png"]];
    [customCell addSubview:customCell.imageView];
    return customCell;
}

-(void)configureDetailCell:(QuestionDetail *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    CGRect frame = self.lblViewAnswer.frame;
    frame.origin.y = self.lblName.frame.origin.y +25;
    frame.size.height = labelHeight;
    self.lblViewAnswer.frame = frame;
    
    
   
    CGRect buttonViewFrame = self.buttonView.frame;
    buttonViewFrame.origin.y = self.lblViewAnswer.frame.origin.y + labelHeight + QACELL_CONTENT_MARGIN;
    self.buttonView.frame= buttonViewFrame;

    
    CGRect frame1 = self.bgImageView.frame;
    frame1.size.height = cellHeight;
    self.bgImageView.frame = frame1;
    
    [self.bgImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.bgImageView.layer setBorderWidth: 2.0];
    self.bgImageView.layer.cornerRadius = 0.7;


    
    CGRect frame2 = self.mainBGImageView.frame;
    frame2.size.height = cellHeight;
    self.mainBGImageView.frame = frame2;

    
    
    [self.imageView configureImageForUrl:question.imageUrl];
       
    
    //For Hash Tagging
    ///////
    
    self.lblViewAnswer.callerView = kCallerViewQADetail;
    [self.lblViewAnswer setupFontColorOfHashTag];
    self.lblViewAnswer.questionDetail = question;
    [self.lblViewAnswer setText:question.answer];
    self.questionReplyMemberID = question.answerMemberID;
    
    DLog(@"lbl detail %@",question.answer);
    
    
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
            [weakSelf.delegate clickOnHashTag:hotWorldID hashType:hotWords[hotWord]forQA:question];
        }
    }];
    ////
    
    [self.lblName setText:question.name];
    [self.lblTime setText:question.answerTime];
    self.isQuestionReplyReported = question.isQuestionReplyReported;
    self.questionReplyID = question.questionReplyID;
    self.checkHelpfull = question.checkReplyHelpfull;
    self.checkLike = question.checkReplyLike;
    self.isSelfQuestion = question.isSelfQuestion;
    self.questionID = question.getQuestionId;
    self.replyText = question.answer;
    self.replyTagArray = question.memberTagsArray;
    
    DLog(@"self question %hhd",self.isSelfQuestion);
    
    if (self.isSelfQuestion)
    {
        self.btnReportToAwm.hidden = YES;
        self.btnEditButton.hidden = NO;
        self.btnDeleteButton.hidden = NO;
     }
    
    
    if (self.checkHelpfull) {
        
        [self.btnHelpful setImage:[UIImage imageNamed:@"reply-helpful-active.png"] forState:UIControlStateNormal];
         self.btnHelpful.selected = YES;
        
    }
    else{
        
        [self.btnHelpful setImage:[UIImage imageNamed:@"reply-helpful.png"] forState:UIControlStateNormal];
        self.btnHelpful.selected = NO;
    }
    
    if (self.checkLike) {
        
        [self.btnLike setImage:[UIImage imageNamed:@"reply-like-active.png"] forState:UIControlStateNormal];
        self.btnLike.selected = YES;
        
    }
    
    else{
        
        [self.btnLike setImage:[UIImage imageNamed:@"reply-like.png" ] forState:UIControlStateNormal];
        self.btnLike.selected = NO;
        
    }
    
}




- (IBAction)memberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.questionReplyMemberID);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.questionReplyMemberID];
    }
}

-(IBAction)deleteAnswer:(id)sender
{
    [self removeAnswerApiCall];
}


-(void)removeAnswerApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.questionID) {
        DLog(@"Edit Activity Comment api call not perform because ActivityId is not exist");
        return;
    }
    
    NSDictionary *deleteAnswerParameter = @{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"question_answer_id":self.questionReplyID,
                                                };
    
    NSString *deleteAnswerUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_DeleteAnswer];
    
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,deleteAnswerParameter, deleteAnswerUrl);
    
    [serviceManager executeServiceWithURL:deleteAnswerUrl andParameters:deleteAnswerParameter forTask:kTaskDeleteActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n response : %@",__FUNCTION__,deleteAnswerParameter,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(questionDetailDeleted)]) {
                    [self.delegate questionDetailDeleted];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

-(IBAction)editAnswer:(id)sender
{
   if([self.delegate respondsToSelector:@selector(replyButtonPressedAtRow:withAnswerID:answerText:andanswerTagArray:buttonState:)])
  [self.delegate replyButtonPressedAtRow:self.tag withAnswerID:self.questionReplyID answerText:self.replyText andanswerTagArray:self.replyTagArray buttonState:self.btnEditButton.selected];
}




- (IBAction)helpfullAction:(id)sender {

    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.questionReplyID) {
        DLog(@"Helpful api call not perform because AnswerId is not exist");
        return;
    }
   
    NSDictionary *askQuestionParameters = @{  @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"question_answer_id": self.questionReplyID,
                                              };
    
    
    DLog(@"Performing HelpFullQuestion api with parameter :%@",askQuestionParameters);
    
    NSString *getQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_QADetailHelpfull];
    
    [serviceManager executeServiceWithURL:getQuestionUrl andParameters:askQuestionParameters forTask:kTaskPostQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            DLog(@"Response of auth/login api:%@",dict);
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                _checkHelpfull = [[response objectForKey:@"is_helpful"] boolValue];
                    
                    DLog(@"helpfull value: %d",self.checkHelpfull);
                    
                    if (self.checkHelpfull) {
                        
                        [self.btnHelpful setImage:[UIImage imageNamed:@"reply-helpful-active.png"] forState:UIControlStateNormal];
                        self.btnHelpful.selected = YES;
                        
                        if ([self.delegate performSelector:@selector(helpulAnswer)]) {
                            [self.delegate helpulAnswer];
                         }
                    }
                    else{
                        
                        [self.btnHelpful setImage:[UIImage imageNamed:@"reply-helpful.png"] forState:UIControlStateNormal];
                        self.btnHelpful.selected = NO;
                    }

                    
                   });
            }
            else{
                DLog(@"Error:%@",error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
            
    }];
}



- (IBAction)LikeAction:(id)sender {
 
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.questionReplyID) {
        DLog(@"like api call not perform because AnswerId is not exist");
        return;
    }
    
    
    NSDictionary *likeParameter =@{   @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                      @"question_answer_id":self.questionReplyID,
                                              
                                        };
    
    DLog(@"Performing auth/question like with parameter:%@",likeParameter);
    
    
    NSString *likeUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_QADetailLike];
    
    [serviceManager executeServiceWithURL:likeUrl andParameters:likeParameter forTask:kTaskQADetailLike completionHandler:^(id response, NSError *error, TaskType task) {
        
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            DLog(@"Response of auth/login api:%@",dict);

        if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _isLike = [[response objectForKey:@"is_like"] boolValue];
                
                if (self.isLike) {
                    
                    [self.btnLike setImage:[UIImage imageNamed:@"reply-like-active.png"] forState:UIControlStateNormal];
                    self.btnLike.selected = YES;
                    
                    if ([self.delegate performSelector:@selector(likeAnswer)]) {
                        [self.delegate likeAnswer];
                    }
                 }
                else{
                    [self.btnLike setImage:[UIImage imageNamed:@"reply-like.png" ] forState:UIControlStateNormal];
                    self.btnLike.selected = NO;
                }
            });
          }
           else{
                 DLog(@"Error:%@",error);
                 [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
                }
        }
    }];
    
}

- (IBAction)reportToAWMButtonPressed:(id)sender {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kTitleReportToAWM, nil];
    self.actionSheet.delegate = self;
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [self.actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == 0) {
     if([title isEqual: @"Report to AWM"])
        {
            if (self.isQuestionReplyReported) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Already Reported"];
                
                return;
            } else if([self.delegate respondsToSelector:@selector(showReportToAWMViewWithReportID:)])
            {
                [self.delegate showReportToAWMViewWithReportID:self.questionReplyID];
            }
        }
    }
    [self.actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = appUIGreenColor;
        }
    }
}

@end

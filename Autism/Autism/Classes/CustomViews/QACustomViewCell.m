

//
//  Q+ACustomViewCell.m
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Neuron Solutions. All rights reserved.
//

#import "QACustomViewCell.h"
#import "HelpfulDetailViewController.h"
#import "QADetailViewController.h"
#import "ReportToAWMView.h"
#import "Utility.h"
#import "WYPopoverController.h"
#import "TagListViewController.h"
#import "ReplyDetailViewController.h"
#import "AskNowViewController.h"

@interface QACustomViewCell()<UIActionSheetDelegate, WYPopoverControllerDelegate,AskNowViewDelegate>
{
    BOOL isCheckHelpful;
    BOOL isSelected;
    WYPopoverController* tagListPopoverController;
}

@property(nonatomic, strong) UIActionSheet *actionSheet;

@property (nonatomic, strong) MyImageView *imageView;
@property (nonatomic, strong) MyImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIButton *btnReportToAWM;
@property (weak, nonatomic) IBOutlet UIButton *moreTagButton;


- (IBAction)reportToAWMButtonPressed:(id)sender;
- (IBAction)moreTagButtonPressed:(id)sender;


@property(strong,nonatomic)NSString *strhelpful;


@end


@implementation QACustomViewCell
@synthesize imageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (QACustomViewCell *)cellFromNibNamed:(NSString *)nibName{

    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    QACustomViewCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[QACustomViewCell class]]) {
            customCell = (QACustomViewCell*)nibItem;
            break; // we have a winner
        }
    }
    customCell.imageView = [[MyImageView alloc]initWithFrame:CGRectMake(2, 2, 35,35)];
    [customCell.imageView setImage:[UIImage imageNamed:@"avatar-140.png"]];
    [customCell addSubview:customCell.imageView];
    return customCell;
}



-(void)configureCell:(GetAllQuestion *)question qaLabelHeight:(float)labelHeight qaDetailLabelHeight:(float)detailLabelHeight andCellHeight:(float)cellHeight
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    CGRect frame = self.lblQuestion.frame;
    frame.size.height = labelHeight;
    self.lblQuestion.frame = frame;
   
    CGRect qaDetailLabelFrame = self.lblQuestionDetail.frame;
    qaDetailLabelFrame.origin.y = self.lblQuestion.frame.origin.y + labelHeight + QACELL_CONTENT_MARGIN;
    qaDetailLabelFrame.size.height = detailLabelHeight + 5;
    self.lblQuestionDetail.frame = qaDetailLabelFrame;
    
    CGRect tagViewFrame = self.tagView.frame;
    tagViewFrame.origin.y = self.lblQuestionDetail.frame.origin.y + detailLabelHeight + QACELL_CONTENT_MARGIN;
    self.tagView.frame= tagViewFrame;
    
    CGRect buttonViewFrame = self.buttonView.frame;
    buttonViewFrame.origin.y = self.tagView.frame.origin.y + TAG_VIEW_HEIGHT + QACELL_CONTENT_MARGIN ;
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
    
    CGRect frame3 = self.arrowImageView.frame;
    frame3.origin.y = cellHeight/2 - 10;
    self.arrowImageView.frame = frame3;
 
    [self.imageView configureImageForUrl:question.imageUrl];
    [self.lblQuestion setText:question.getQuestion];
    self.qaDetailLabelHeight = detailLabelHeight + 5;
    
    
    //For Hash Tagging
    ///////
    self.lblQuestionDetail.callerView = kCallerViewQA;
    [self.lblQuestionDetail setupFontColorOfHashTag];
    self.lblQuestionDetail.question = question;
    [self.lblQuestionDetail setText:question.quetionDetails];
    
    __weak typeof(self) weakSelf = self;
    
    [self.lblQuestionDetail setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
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

      if ([weakSelf.delegate respondsToSelector:@selector(clickOnHashTag:hashType:forQA:)]) {
            [weakSelf.delegate clickOnHashTag:hotWorldID hashType:hotWords[hotWord] forQA:question];
        }
    }];
    ////
    
    [self.lblRepliesCount setText:question.repliesCount];
    [self.lblName setText:question.userName];
    
    self.questionId = question.questionId;
    self.strQuestion = question.getQuestion;
    self.isSelfQuestion = question.isSelfQuestion;
    self.isQuestionReported = [question.isQuestionReported boolValue];
    self.isMemberAlreadyInCircle = question.isMemberAlreadyInCircle;
    self.addedQuestionMemberID = question.addedQuestionMemberID;
    self.strQuestionDetails = question.quetionDetails;
    self.imageURL = question.imageUrl;
    self.userName = question.userName;
    self.strReplyCount = question.repliesCount;
    self.qaTagArray = question.memberTagsArray;
    self.passQATagArray = question.tagsArray;;
    
    DLog(@"tag %@",self.qaTagArray);
    
    DLog(@"Cell UserID String:%@",self.addedQuestionMemberID );
    
    [self.btnHelpfulCircle setTitle:question.helpfulCount forState:UIControlStateNormal];
    [self.btnReplyCircle setTitle:question.repliesCount forState:UIControlStateNormal];
    
    NSString *tagString = @"";
    if (question.tagsArray.count > 0) {
        if (question.tagsArray.count == 1) {
            tagString = [question.tagsArray objectAtIndex:0];
        } else if (question.tagsArray.count >= 2 ) {
            tagString = [question.tagsArray objectAtIndex:0];
            tagString = [tagString stringByAppendingString:@", "];
            tagString = [tagString stringByAppendingString:[question.tagsArray objectAtIndex:1]];
        }
        if (question.tagsArray.count > 2) {
            self.moreTagButton.hidden = NO;
            [self.moreTagButton setTitle:[NSString stringWithFormat:@"+%uMore",question.tagsArray.count-2] forState:UIControlStateNormal];
            self.tagsArray = question.tagsArray;
        }
        [self.lblTags setText:tagString];
    }
    
    if (self.isSelfQuestion){
        self.btnReportToAWM.hidden = YES;
        self.btnDeleteQuestion.hidden = NO;
        self.btnEditQuestion.hidden = NO;
    }
    
    self.btnHelpful.selected = question.isHelpful;
    self.checkHelpful = question.isHelpful;
    [self.lblQuestion sizeToFit];
   
}

-(void)configureMyCell:(GetMyQuestion *)myQuestion qaLabelHeight:(float)labelHeight qaDetailLabelHeight:(float)detailLabelHeight andCellHeight:(float)cellHeight
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    CGRect frame = self.lblQuestion.frame;
    frame.size.height = labelHeight;
    self.lblQuestion.frame = frame;
   
    
    CGRect qaDetailLabelFrame = self.lblQuestionDetail.frame;
    qaDetailLabelFrame.origin.y = self.lblQuestion.frame.origin.y + labelHeight + QACELL_CONTENT_MARGIN;
    qaDetailLabelFrame.size.height = detailLabelHeight;
    self.lblQuestionDetail.frame = qaDetailLabelFrame;
    
    
    CGRect tagViewFrame = self.tagView.frame;
    tagViewFrame.origin.y = self.lblQuestionDetail.frame.origin.y + detailLabelHeight + QACELL_CONTENT_MARGIN;
    self.tagView.frame= tagViewFrame;
    
    CGRect buttonViewFrame = self.buttonView.frame;
    buttonViewFrame.origin.y = self.tagView.frame.origin.y + TAG_VIEW_HEIGHT + QACELL_CONTENT_MARGIN ;
    self.buttonView.frame= buttonViewFrame;
    
    CGRect frame1 = self.bgImageView.frame;
    frame1.size.height = cellHeight;
    self.bgImageView.frame = frame1;
    
    CGRect frame2 = self.mainBGImageView.frame;
    frame2.size.height = cellHeight;
    self.mainBGImageView.frame = frame2;
    
    CGRect frame3 = self.arrowImageView.frame;
    frame3.origin.y = cellHeight/2 - 10;
    self.arrowImageView.frame = frame3;

    
    
    [self.imageView configureImageForUrl:myQuestion.imageUrl];
    [self.lblQuestion setText:myQuestion.getQuestion];
    
    //For Hash Tagging
    ///////
    self.lblQuestionDetail.callerView = kCallerViewMyQA;
    [self.lblQuestionDetail setupFontColorOfHashTag];
    self.lblQuestionDetail.myQuestion = myQuestion;
    [self.lblQuestionDetail setText:myQuestion.quetionDetails];
    
    
    __weak typeof(self) weakSelf = self;
    
    [self.lblQuestionDetail setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
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

      if ([weakSelf.delegate respondsToSelector:@selector(clickOnHashTagForMyQA:hashType:forQA:)]) {
          [weakSelf.delegate clickOnHashTagForMyQA:hotWorldID hashType:hotWords[hotWord] forQA:myQuestion];
         }
    }];
    ////

    
    [self.lblRepliesCount setText:myQuestion.repliesCount];
    [self.lblName setText:myQuestion.userName];
    self.questionId = myQuestion.questionId;
    self.strQuestion = myQuestion.getQuestion;
    self.isSelfQuestion = myQuestion.isSelfQuestion;
    self.isQuestionReported = myQuestion.isQuestionReported;
    self.isMemberAlreadyInCircle = myQuestion.isMemberAlreadyInCircle;
    self.addedQuestionMemberID = myQuestion.addedQuestionMemberID;
    
    [self.btnHelpfulCircle setTitle:myQuestion.helpfulCount forState:UIControlStateNormal];
    [self.btnReplyCircle setTitle:myQuestion.repliesCount forState:UIControlStateNormal];
    
    self.strQuestionDetails = myQuestion.quetionDetails;
    self.imageURL = myQuestion.imageUrl;
    self.userName = myQuestion.userName;
    self.passQATagArray = myQuestion.tagsArray;
    self.strReplyCount = myQuestion.repliesCount;
    
    NSString *tagString = @"";
    if (myQuestion.tagsArray.count > 0) {
        if (myQuestion.tagsArray.count == 1) {
            tagString = [myQuestion.tagsArray objectAtIndex:0];
        } else if (myQuestion.tagsArray.count >= 2 ) {
            tagString = [myQuestion.tagsArray objectAtIndex:0];
            tagString = [tagString stringByAppendingString:@", "];
            tagString = [tagString stringByAppendingString:[myQuestion.tagsArray objectAtIndex:1]];
        }
        if (myQuestion.tagsArray.count > 2) {
            self.moreTagButton.hidden = NO;
            [self.moreTagButton setTitle:[NSString stringWithFormat:@"+%uMore",myQuestion.tagsArray.count-2] forState:UIControlStateNormal];
            self.tagsArray = myQuestion.tagsArray;
        }
        [self.lblTags setText:tagString];
    }
    
    if (self.isSelfQuestion){
    self.btnDeleteQuestion.hidden = NO;
    self.btnEditQuestion.hidden = NO;
        
    }
    self.btnReportToAWM.hidden = YES;
    
    self.btnHelpful.selected = myQuestion.isHelpful;
    [self.lblQuestion sizeToFit];
    
}

- (IBAction)memberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.addedQuestionMemberID);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.addedQuestionMemberID];
    }
}



-(IBAction)helpfulAction:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.questionId)
    {
        DLog(@"likeActivity api call not perform because ActivityId is not exist");
        return;
    }
    
    self.btnHelpful.selected = !self.btnHelpful.selected;

    DLog(@"memeberID:%@, questionID:%@",[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],self.questionId);
    
    NSDictionary *askQuestionParameters = @{  @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"question_id" : self.questionId,
                                              
                                             };
    
    
    DLog(@"Performing HelpFullQuestion api with parameter :%@",askQuestionParameters);
    
    NSString *getQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_HelpfulCount];
    
    [serviceManager executeServiceWithURL:getQuestionUrl andParameters:askQuestionParameters forTask:kTaskPostQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"HelpFullQuestion api response :%@",response);

        NSDictionary *dict = (NSDictionary *)response;
        NSArray *dataArray = [dict valueForKey:@"data"];
        self.strhelpful = [[dataArray valueForKey:@"usefulCount"]stringValue];
        [self.btnHelpfulCircle setTitle:self.strhelpful forState:UIControlStateNormal];
        if ([self.delegate performSelector:@selector(helpfulSuccessfully)]) {
            [self.delegate helpfulSuccessfully];
        }

    }];
}

- (IBAction)replyButtonPressed:(id)sender {
    //self.replyButton.selected = !self.replyButton.selected;
    if([self.delegate respondsToSelector:@selector(replyButtonPressedAtRow:withQuestionID:buttonState:)])
        [self.delegate replyButtonPressedAtRow:self.tag withQuestionID:self.questionId buttonState:self.replyButton.selected];
}


- (IBAction)helpfulCircleAction:(id)sender {
    
    HelpfulDetailViewController *detail = [[HelpfulDetailViewController alloc]initWithNibName:@"HelpfulDetailViewController" bundle:nil];
    
    detail.helpfulQuestionId = self.questionId;
    detail.strgetQuestion = self.strQuestion;
    detail.replyCount = self.strReplyCount;
    
    DLog(@"reply count value %@",detail.replyCount);
  
    //*> Navigations Issue
    /*UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:detail];
    
     [[appDelegate rootNavigationController] presentViewController:nav animated:YES completion:nil];*/
    
    [[appDelegate rootNavigationController] pushViewController:detail animated:YES];
}


-(IBAction)replyCircleAction:(id)sender
{
    ReplyDetailViewController *detail = [[ReplyDetailViewController alloc]initWithNibName:@"ReplyDetailViewController" bundle:nil];
    
    DLog(@"Question id %@",self.questionId);
    
    detail.replyQuestionId = self.questionId;
    detail.strgetQuestion = self.strQuestion;
    detail.replyCount = self.strReplyCount;
    
  //*> Navigations Issue
    [[appDelegate rootNavigationController] pushViewController:detail animated:YES];
    /*UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:detail];
    
    [[appDelegate rootNavigationController] presentViewController:nav animated:YES completion:nil];*/
    
    
   

}

-(IBAction)readMore:(id)sender
{
        QADetailViewController *detail = [[QADetailViewController alloc]initWithNibName:@"QADetailViewController" bundle:nil];
        detail.strGetQuestionId = self.questionId;
        detail.strgetQuestion   = self.strQuestion;
    
        [[appDelegate rootNavigationController] presentViewController:detail animated:YES completion:nil];
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
            [self.delegate showReportToAWMViewWithReportID:self.questionId];
        }
    }
    [self.actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - TagListPopoverMethods

- (IBAction)moreTagButtonPressed:(id)sender {
    
    if (tagListPopoverController == nil)
    {
        UIView *btn = (UIView *)sender;
        UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];

        TagListViewController *tagListViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"TagListViewController"];
        tagListViewController.preferredContentSize = CGSizeMake(280, 150);
        
        tagListViewController.title = @"Tags";
        [Utility setTitleColor:tagListViewController.navigationItem];

        tagListViewController.tagsArray = self.tagsArray;
        tagListViewController.modalInPopover = NO;
        
        UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController:tagListViewController];
        tagListPopoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
        tagListPopoverController.delegate = self;
        tagListPopoverController.passthroughViews = @[btn];
        tagListPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        tagListPopoverController.wantsDefaultContentAppearance = NO;
        [tagListPopoverController presentPopoverAsDialogAnimated:YES
                                                         options:WYPopoverAnimationOptionFadeWithScale];
    }
    else
    {
        [self close:nil];
    }
}

- (void)close:(id)sender
{
    [tagListPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:tagListPopoverController];
    }];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    tagListPopoverController.delegate = nil;
    tagListPopoverController = nil;
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

- (IBAction)deleteQuestionAction:(id)sender {
    
    [self removeQuestionDetailApiCall];
}



-(void)removeQuestionDetailApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.questionId) {
        DLog(@"Delete question api call not perform because QuestionId is not exist");
        return;
    }
    
    NSDictionary *deleteActivityParameter = @{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                @"question_id":self.questionId
                                                };
    
    NSString *deleteActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_DeleteQuestion];
    
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,deleteActivityUrl, deleteActivityParameter);
    
    [serviceManager executeServiceWithURL:deleteActivityUrl andParameters:deleteActivityParameter forTask:kTaskDeleteActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response : %@",__FUNCTION__,deleteActivityUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(questionDeletedAction)]) {
                    [self.delegate questionDeletedAction];
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


-(IBAction)EditQuestionAction:(id)sender
{
   UIStoryboard* mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    
 AskNowViewController *show = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AskNowViewController"];
    show.delegate = self;
    show.strQuestionId = self.questionId;
    show.passQuestion = self.strQuestion;
    show.passQuestionDetail = self.strQuestionDetails;
    show.passQuestionTag = self.passQATagArray;
    show.memberTagArray  = self.qaTagArray;
    
    DLog(@"tags %@",show.passQuestionTag);
    DLog(@"tags %@",self.tagsArray);
    show.eventType = kEventType;
   //[[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
   [[appDelegate rootNavigationController] pushViewController:show animated:YES];

}

-(void)reloadQATable
{
     if ([self.delegate respondsToSelector:@selector(questionDeletedAction)]) {
         
        [self.delegate questionDeletedAction];
      }
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
                BOOL circleStatus;
                if([[dict objectForKey:@"is_memmber_added_incircle"] boolValue]){
                    [Utility showAlertMessage:@"" withTitle:@"Member added successfully in your circle."];
                    circleStatus = YES;
                } else {
                    [Utility showAlertMessage:@"" withTitle:@"Member successfully removed from your circle."];
                    circleStatus = NO;
                 }
                
                if([self.delegate respondsToSelector:@selector(memberSuccessfullyAddedInCircle::)])
                    [self.delegate memberSuccessfullyAddedInCircle:circleStatus :self.addedQuestionMemberID];

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
                BOOL circleStatus = [[dict valueForKey:@"is_blocked"]boolValue];
              [Utility showAlertMessage:@"" withTitle:[dict valueForKey:@"message"]];
                
                if (circleStatus) {
                    circleStatus = YES;
                  }
            else{
                  circleStatus = NO;
                 }
                
            if([self.delegate respondsToSelector:@selector(memberSuccessfullyBlocked::)])
                    [self.delegate memberSuccessfullyBlocked:circleStatus :self.addedQuestionMemberID];
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

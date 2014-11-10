//
//  MDViewController.m
//  MJAutoCompleteDemo
//
//  Created by Mazyad Alabduljaleel on 2/18/14.
//  Copyright (c) 2014 ArabianDevs. All rights reserved.
//

#import "CommentViewController.h"
#import "MemebersListAutoCompleteCell.h"
#import "NSDictionary+HasValueForKey.h"
#import "STTweetTextStorage.h"
#import  "Utility.h"

@interface CommentViewController ()

@property (nonatomic) BOOL didStartDownload;

@property (strong, nonatomic) MJAutoCompleteManager *autoCompleteMgr;
@property (weak, nonatomic) IBOutlet UIView *autoCompleteContainer;
@property (nonatomic, strong) AppDelegate *appDel;
@property (nonatomic, strong) NSMutableArray *memberList;
@property (nonatomic, strong) NSDictionary *attributesText;
@property (strong) STTweetTextStorage *textStorage;

@property (nonatomic, strong) NSDictionary *attributesHandle;
@property (nonatomic, strong) NSDictionary *attributesHashtag;
@property (nonatomic, strong) NSDictionary *attributesLink;
@property (nonatomic, strong) NSDictionary *attributesNotification;

@end

@implementation CommentViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.memberList = [NSMutableArray array];
        self.appDel = [[UIApplication sharedApplication] delegate];
        [self getMembersList];
        DLog(@"memberList Count:%lu",(unsigned long)self.appDel.memberListArray.count);
        
        self.autoCompleteMgr = [[MJAutoCompleteManager alloc] init];
        self.autoCompleteMgr.dataSource = self;
        self.autoCompleteMgr.delegate = self;
        
        // For the @ trigger, it is much more complex, with lots of async thingies */
        MJAutoCompleteTrigger *atTrigger = [[MJAutoCompleteTrigger alloc] initWithDelimiter:@"@"];
        atTrigger.cell = @"MemebersListAutoCompleteCell";
        [self.autoCompleteMgr addAutoCompleteTrigger:atTrigger];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.parentViewControllerName isEqualToString:kCallerViewActivityDetail]) {
        
        [self.btnPost setTitle:@"Update" forState:UIControlStateNormal];
        _cleanText = self.activityCommentText;

        [self determineHotWordsInString:self.activityCommentText replaceWithTagID:self.tagArray];
        
    }
    
    if ([self.parentViewControllerName isEqualToString:kCallerViewQADetailAnswerEdit]) {
        
        [self.btnPost setTitle:@"Update" forState:UIControlStateNormal];
 
        _cleanText = self.answerText;
        
        [self determineHotWordsInString:self.answerText replaceWithTagID:self.tagArray];
        
    }
    
    self.commentView.layer.borderColor = [UIColor grayColor].CGColor;
    self.commentView.layer.borderWidth = 2.0f;
    self.textView.layer.borderColor = [UIColor colorWithRed:0/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f].CGColor;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.placeholder = @"Your comment here";

    self.commentView.layer.cornerRadius = 5;
    self.commentView.layer.masksToBounds = YES;

    // hook up the container with the manager
    self.autoCompleteMgr.container = self.autoCompleteContainer;
    // and hook up the textView delegate
    self.textView.delegate = self;
}





-(void)determineHotWordsInString:(NSString *)commnentString replaceWithTagID:(NSArray *)tagArray{
    
    STTweetCommentHotWord hotWord;
    hotWord = STTweetCommentHashtag;
    NSRange range;
    NSString *userId;
    NSString *userIdWithAt;
    NSString *userName;
    
  //  DLog(@"-------commnentString with @ID:%@",commnentString);
    
   // DLog(@"============member_tagged:%@",tagArray);
    for (NSDictionary *tagDict in tagArray) {
        if ([tagDict hasValueForKey:@"id"] && [tagDict hasValueForKey:@"name"]) {
            userId = [tagDict valueForKey:@"id"];
            userIdWithAt = [NSString stringWithFormat:@"@%@",userId];
            userName = [tagDict valueForKey:@"name"];
            
            _cleanText = [_cleanText stringByReplacingOccurrencesOfString:userIdWithAt
                                                               withString:userName];
            range = [_cleanText rangeOfString:userName];
            [_rangesOfHotWords addObject:@{@"hotWord": @(hotWord), @"hotWordID": userId, @"range": [NSValue valueWithRange:range]}];
            
            Member *member = [[Member alloc] init];
            member.name = userName;
            member.memberId = userId;
            MJAutoCompleteItem *item = [[MJAutoCompleteItem alloc] init];
            item.autoCompleteString = userName;
            item.member = member;

           // MJAutoCompleteItem
            [self.autoCompleteMgr.rangesOfSelectedHotWords addObject:@{@"taggedMember": item, @"range": [NSValue valueWithRange: range]}];
        }
        
        DLog(@"-------commnentString after replacingwith Id:%@",_cleanText);
    }
    
    self.textView.text = _cleanText;
    [self highlightHotWordsInTextView:self.textView];
}


#pragma mark - UITextView Delegate methods

/*
 ** Update Hotwords range if user do editing before to hotword and remove hotword from dictionary if editing between hotwords.
 */
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   // DLog(@"textView.text:%@ \n range:%@, \n text:%@ \n selectedRange.location:%@",textView.text, NSStringFromRange(range), text, NSStringFromRange(textView.selectedRange));
    
    if (range.length == 0 && text.length==0)
    {
        [self highlightHotWordsInTextView:textView];
        return NO;
    }
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        self.autoCompleteContainer.hidden = YES;
        return NO;
    }
    BOOL isMovingBackword = (range.length > 0 && text.length == 0) ? YES : NO;
    
    NSRange hotWordRange;
    NSMutableDictionary *dict;
    
    for (NSUInteger i = 0; i< self.autoCompleteMgr.rangesOfSelectedHotWords.count; i++) {
        dict = (NSMutableDictionary*)[self.autoCompleteMgr.rangesOfSelectedHotWords objectAtIndex:i];
        hotWordRange = [[dict objectForKey:@"range"] rangeValue];
        
        //Check if current position is tuching to Hotword end location then put space between these two.
        if (text.length && (range.location == (hotWordRange.location + hotWordRange.length)))
        {
            textView.text  = [textView.text stringByReplacingCharactersInRange:range withString: [NSString stringWithFormat: @" "]];
            NSRange updatedRange = range;
            updatedRange.location += 1;
            textView.selectedRange = updatedRange;
            [self highlightHotWordsInTextView:textView];
            textView.selectedRange = updatedRange;
        }
        
        //Check cursor postion is behind hotword if
        if (range.location <= hotWordRange.location) {
            //Then change hotword location
            if (isMovingBackword) {         // user deleting text
                hotWordRange.location -= range.length;
            }
            else // user updating/typing text
            {
                if (text.length) {
                    hotWordRange.location += text.length;
                } else
                {
                    hotWordRange.location += 1;
                }
            }
            NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [newDict removeObjectForKey:@"range"];
            [newDict setObject:[NSValue valueWithRange: hotWordRange] forKey:@"range"];
            [self.autoCompleteMgr.rangesOfSelectedHotWords replaceObjectAtIndex:i withObject:newDict];
            
        }
        
        DLog(@"Start------ \n range :%@ \n hotWordRange :%@ \n selectedRange:%@",NSStringFromRange(range), NSStringFromRange(hotWordRange), NSStringFromRange(textView.selectedRange));
        
        DLog(@"range.location :%d \n (hotWordRange.location + hotWordRange.length) :%d \n------End",range.location, (hotWordRange.location + hotWordRange.length));
        
        //Check cursor postion is in middle of hotword then make it normal word and remove form hodword dict
        
        if ((range.location > hotWordRange.location) && (range.location < (hotWordRange.location + hotWordRange.length)))
        {
            
            DLog(@"Rang intersect");
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:textView.text];
            [attributedString removeAttribute:NSBackgroundColorAttributeName range:hotWordRange];
            [attributedString removeAttribute:NSForegroundColorAttributeName range:hotWordRange];
            textView.attributedText = attributedString;
            
            [self.autoCompleteMgr.rangesOfSelectedHotWords removeObject:dict];
            [self highlightHotWordsInTextView:textView];
            textView.selectedRange = range;
            
            if ([dict hasValueForKey:@"taggedMember"])
            {
                MJAutoCompleteItem *aCompleteItem = [dict valueForKey:@"taggedMember"];
                [self.memberList addObject:aCompleteItem];
            }
        }
        
    }
    return YES;
}


- (void)highlightHotWordsInTextView:(UITextView *)textView
{
    NSRange range;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:textView.text];
    for (NSDictionary *dict in self.autoCompleteMgr.rangesOfSelectedHotWords) {
        range = [[dict objectForKey:@"range"] rangeValue];
        
        @try {
            
            [attributedString addAttribute:NSBackgroundColorAttributeName
                                     value:[UIColor colorWithRed:44/255.0f green:173/255.0f blue:182/255.0f alpha:1.0f]
                                     range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor whiteColor]
                                     range:range];
        }
        @catch (NSException *e ) {
            DLog(@"Exeption:%@ \n Exception Reson:%@",e.userInfo, e.reason);
        }
        
    }
    textView.attributedText = attributedString;
}


- (void)textViewDidChange:(UITextView *)textView
{
    [self.autoCompleteMgr processString:textView.text];
}

#pragma mark - MJAutoCompleteMgr DataSource Methods

- (void)autoCompleteManager:(MJAutoCompleteManager *)acManager
         itemListForTrigger:(MJAutoCompleteTrigger *)trigger
                 withString:(NSString *)string
                   callback:(MJAutoCompleteListCallback)callback
{
   if ([trigger.delimiter isEqual:@"@"])
   {
       if (!self.didStartDownload)
       {
           self.didStartDownload = YES;
           for (Member *member in self.appDel.memberListArray)
           {
               NSString * acString = member.name;
               
               MJAutoCompleteItem *item = [[MJAutoCompleteItem alloc] init];
               item.autoCompleteString = acString;
               item.member = member;
               
               [self.memberList addObject:item];
           }
           dispatch_async(dispatch_get_main_queue(), ^
                          {
                              trigger.autoCompleteItemList = self.memberList;
                              callback(self.memberList);
                          });
       }
       else
       {
           callback(self.memberList);
       }
   }
}

#pragma mark - MJAutoCompleteMgr Delegate methods

- (void)autoCompleteManager:(MJAutoCompleteManager *)acManager shouldUpdateToText:(NSString *)newText
{
    self.textView.text = newText;
    [self highlightHotWordsInTextView:self.textView];

    for (MJAutoCompleteItem *item in self.memberList) {
        if([item isEqual:acManager.selectedItem]) {
            DLog(@"correct.........., self.memberListCoutn:%lu",(unsigned long)self.memberList.count);
            DLog(@"name:%@ \n memberId:%@",item.member.name, item.member.memberId);
            [self.memberList removeObject:item];
            DLog(@"memberListCoutn:%lu",(unsigned long)self.memberList.count);

            break;
        }
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

- (IBAction)postButtonPressed:(id)sender {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *commentString = [self getCommentTextAfterReplacingHashTagToMemberID];

    /*if ([Utility getValidString:commentString].length < 1) {
        
        [Utility showAlertMessage:@"You can not comment with blank message." withTitle:@"Comment is blank."];
        return;
    }*/

    if (self.commentType == CommentTypeReplyOnQuestion) {
        
        if ([Utility getValidString:commentString].length < 1) {
            
            [Utility showAlertMessage:@"You can not Reply with blank message." withTitle:@"Message."];
            return;
         }

        [self replyOnQuestiuon];
    }
    else if (self.commentType == CommentTypeActivity)
    {
        if ([Utility getValidString:commentString].length < 1) {
            
            [Utility showAlertMessage:@"You can not comment with blank message." withTitle:@"Comment is blank."];
            return;
        }

        [self postCommentUpdateApiCall];
        
    }else if (self.commentType == CommentTypeProfile)
    {
        [self postCommentUpdateApiCall];
    }
    
    else if (self.commentType == CommentTypeActivityDetail)
    {
        if ([Utility getValidString:commentString].length < 1) {
            
            [Utility showAlertMessage:@"You can not comment with blank message." withTitle:@"Comment is blank."];
            return;
        }
      [self editActivityAction];
 }
    
    else if (self.commentType == CommentTypeEditAnswerInQADetail)
    {
        if ([Utility getValidString:commentString].length < 1) {
            
            [Utility showAlertMessage:@"You can not Reply with blank message." withTitle:@"Message."];
            return;
          }
        [self editAnswerAction];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
   
}



-(void)editActivityAction
{
     NSString *commentString = @"";

    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.activityDetailId) {
        DLog(@"Edit Activity Comment api call not perform because ActivityId is not exist");
        return;
    }
      commentString = [self getCommentTextAfterReplacingHashTagToMemberID];
    
    
    if ([Utility getValidString:commentString].length < 1) {
        DLog(@"likeActivity api call not perform because ActivityId is not exist");
        return;
    }
    
    
    NSDictionary *editActivityParameter = @{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"activity_comment_id" : self.activityDetailId,
                                              @"activity_comment_text": commentString,
                                              };
    
    NSString *editActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_EditActivityComment];
   
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,editActivityUrl,editActivityParameter);
    
    [serviceManager executeServiceWithURL:editActivityUrl andParameters:editActivityParameter forTask:kTaskEditActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,editActivityUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(updateRecordByPost)]) {
                    [self.delegate updateRecordByPost];
                    [Utility showAlertMessage:@"Your comment has been successfully updated." withTitle:@"Message"];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];

}




-(void)editAnswerAction
{
    NSString *commentString = @"";
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.answerId) {
        DLog(@"Edit Answer Comment api call not perform because AnswerId is not exist");
        return;
    }
    commentString = [self getCommentTextAfterReplacingHashTagToMemberID];
    
    
    if ([Utility getValidString:commentString].length < 1) {
        DLog(@"Edit Answer api call not perform because AnswerId is not exist");
        return;
    }
    
    
    NSDictionary *editAnswerParameter = @{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"question_answer_id" : self.answerId,
                                              @"answer_text": commentString,
                                              };
    
    NSString *editAnswerUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_EditAnswer];
    
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,editAnswerUrl,editAnswerParameter);
    
    [serviceManager executeServiceWithURL:editAnswerUrl andParameters:editAnswerParameter forTask:kTaskEditActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,editAnswerUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(updateRecordByPost)]) {
                    [self.delegate updateRecordByPost];
                [Utility showAlertMessage:@"Your Reply has been successfully updated." withTitle:@"Message"];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];
    
}



- (NSString*)getCommentTextAfterReplacingHashTagToMemberID
{
    NSMutableString *commentString = [[NSMutableString alloc] initWithString: self.textView.text];
    if([Utility getValidString:commentString].length < 1)
        return @"";
    
    DLog(@"commentString:%@",commentString);
    
    NSRange range;
    NSDictionary *dict;
    NSInteger hotwordCount = self.autoCompleteMgr.rangesOfSelectedHotWords.count -1;
    if(hotwordCount < 0)
        return commentString;
    
    for (NSInteger i = hotwordCount;  i >= 0; i--) {
        
        dict = [self.autoCompleteMgr.rangesOfSelectedHotWords objectAtIndex:i];
        range = [[dict objectForKey:@"range"] rangeValue];
        if ([dict hasValueForKey:@"taggedMember"])
        {
            MJAutoCompleteItem *aCompleteItem = [dict valueForKey:@"taggedMember"];
            [self.memberList addObject:aCompleteItem];
           
            @try {
                
                [commentString replaceCharactersInRange:range withString:[NSString stringWithFormat:@"@%@",aCompleteItem.member.memberId]];
            }
            @catch (NSException *e ) {
                
                DLog(@"Exeption:%@ \n Exception Reson:%@",e.userInfo, e.reason);
                return commentString;
            }
            DLog(@"Tagged Member name:%@",aCompleteItem.member.name);
        }
    }
    DLog(@"commentString replaceing with id:%@",commentString);
    
    return commentString;
}

#pragma mark - Api Call

-(void)replyOnQuestiuon {
    NSString *commentString = @"";
    if (!self.questionID) {
        DLog(@"Question id not exist");
        return;
    }else {
        commentString = [self getCommentTextAfterReplacingHashTagToMemberID];
         if ([Utility getValidString:commentString].length < 1)
        {
            //TODO ask for message.
            [Utility showAlertMessage:@"You could not post with blank message." withTitle:@"Reply message is blank."];
            return;
        }
    }

    NSDictionary *postQuestionCommentParameters = @{@"member_id" :[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                    @"question_id" : self.questionID,
                                                    @"comment": commentString,
                                                    };
    
    NSString *strSignUpUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_PostQuestionComment];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,strSignUpUrl,postQuestionCommentParameters);
    
    [serviceManager executeServiceWithURL:strSignUpUrl andParameters:postQuestionCommentParameters forTask:kTaskPostQuestionComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api response :%@",__FUNCTION__,strSignUpUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"responce_code"] isEqualToString:@"RC0000"]) {
                
                if ([self.delegate respondsToSelector:@selector(commentSuccessfullySubmitted)])
                {   [self.delegate commentSuccessfullySubmitted];
                    [Utility showAlertMessage:@"Your Reply has been successfully posted." withTitle:@"Message"];
                }
                
            } else if ([[dict valueForKey:@"responce_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];
}


- (void)postCommentUpdateApiCall
{
   
    if (!self.selectedActivityId) {
        DLog(@"Activity id does not exist");
        return;
    }
    NSString *commentString = [self getCommentTextAfterReplacingHashTagToMemberID];

    NSDictionary *activityCommentParameters =@{    @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"activity_id" : self.selectedActivityId,
                                                   @"comment_text" : commentString
                                                   };
    
    NSString *activityCommentUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_ActivityComment];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,activityCommentUrl, activityCommentParameters);
    [serviceManager executeServiceWithURL:activityCommentUrl andParameters:activityCommentParameters forTask:kTaskActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,activityCommentUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(commentSuccessfullySubmitted)]) {
                    [self.delegate commentSuccessfullySubmitted];
                    [Utility showAlertMessage:@"Comment successfully posted" withTitle:@"Message"];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];
}

-(void)getMembersList
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *requestParameters = @{ @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                        };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMemberList];
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,requestUrl, requestParameters);
    
    [serviceManager executeServiceWithURL:requestUrl andParameters:requestParameters forTask:kTaskGetMemberList completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api \n response:%@",__FUNCTION__,requestUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                    self.appDel.memberListArray = [parsingManager parseResponse:response forTask:task];
                    NSMutableArray *membersList = [NSMutableArray array];

                    for (Member *member in self.appDel.memberListArray)
                    {
                        NSString * acString = member.name;
                        MJAutoCompleteItem *item = [[MJAutoCompleteItem alloc] init];
                        item.autoCompleteString = acString;
                        item.member = member;
                       // DLog(@"----name:%@ \n id:%@, \n avatar:%@",member.name, member.memberId, member.avatar);
                        [membersList addObject:item];
                    }
                self.memberList = nil;
                self.memberList = membersList;
            }
            else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }
        else {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

@end

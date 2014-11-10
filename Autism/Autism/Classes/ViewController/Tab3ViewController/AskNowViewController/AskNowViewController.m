//
//  AskNowViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#define kOFFSET_FOR_KEYBOARD_5 155.0
#define kOFFSET_FOR_KEYBOARD_4 235.0

#import "AskNowViewController.h"
#import "CustomTextField.h"
#import "QuestionKeywordViewController.h"
#import "Utility.h"
#import "MemebersListAutoCompleteCell.h"
#import "NSDictionary+HasValueForKey.h"

@interface AskNowViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UITextViewDelegate,QuestionKeywordDelegate>
{
   UITextView *activeTextField;
}
@property (nonatomic, strong)UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextView *txtViewQuestion;
@property (strong, nonatomic) IBOutlet UITextView *txtViewKeyword;
@property (strong, nonatomic) IBOutlet UITextView *txtVewDetails;

@property (nonatomic, strong) NSMutableArray *arrayKeyword;
@property (strong, nonatomic) NSArray *keywordArray;
@property (strong, nonatomic) NSDictionary *keywordDataDic;
@property (nonatomic, strong) UIView *baseView;
@property (strong, nonatomic) NSMutableString *tags;
@property (strong, nonatomic) NSMutableString *keywordTags;
@property (strong, nonatomic) NSString *qaDetailString;
@property (strong, nonatomic) NSMutableString *qaDetailAppendString;
@property (strong, nonatomic) NSString *strMerge;



@property (nonatomic) BOOL didStartDownload;
@property (strong, nonatomic) MJAutoCompleteManager *autoCompleteMgr;
@property (weak, nonatomic) IBOutlet UIView *autoCompleteContainer;
@property (nonatomic, strong) AppDelegate *appDel;
@property (nonatomic, strong) NSMutableArray *memberList;

@end

@implementation AskNowViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.memberList = [NSMutableArray array];
        self.appDel = [[UIApplication sharedApplication] delegate];
        //[self getMembersList];
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



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.qaDetailAppendString = [NSMutableString new];
    self.strMerge = [[NSString alloc]init];
    
    [[UITextView appearance] setTintColor:[UIColor blackColor]];
    self.title = @"Ask Question";
    self.txtViewQuestion.delegate = self;
    self.txtViewKeyword.delegate  = self;
    self.txtVewDetails.delegate   = self;
    self.txtViewKeyword.editable  = YES;

    //self.textView.layer.borderColor = [UIColor colorWithRed:0/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f].CGColor;
    self.textView.delegate = self;
    //self.textView.layer.borderWidth = 1.0f;
    //self.textView.placeholder = @"Your comment here";
    
    self.autoCompleteMgr.container = self.autoCompleteContainer;
    
    [self getQuestionKeyword];
    
    
    if ([self.eventType isEqualToString:kEventType])
    {
        self.title = @"Update Question";
        self.keywordTags = [[NSMutableString alloc]init];
        self.txtViewQuestion.text = self.passQuestion;
        
        [self.btnAskquestion setTitle:@"Edit Question" forState:UIControlStateNormal];
     for ( NSString *string in self.passQuestionTag )
         {
            [self.keywordTags appendString:[NSString stringWithFormat:@"%@,",string]];
            DLog(@"tags %@",string);
         }
        DLog(@"tags %@",self.keywordTags);
        self.txtViewKeyword.text  = self.keywordTags;
        _cleanText = self.passQuestionDetail;
       [self determineHotWordsInString:self.passQuestionDetail replaceWithTagID:self.memberTagArray];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[appDelegate rootNavigationController ]setNavigationBarHidden:NO];
    [self setScrollView];
 }


-(void)determineHotWordsInString:(NSString *)commnentString replaceWithTagID:(NSArray *)tagArray{
    
    STTweetAskHotWord hotWord;
    hotWord = STTweetAskHashtag;
    NSRange range;
    NSString *userId;
    NSString *userIdWithAt;
    NSString *userName;
    
    //DLog(@"============member_tagged:%@",tagArray);
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
        
        //DLog(@"-------commnentString after replacingwith Id:%@",_cleanText);
    }
    
    self.textView.text = _cleanText;
    [self highlightHotWordsInTextView:self.textView];
}

//// Hash tagging
/*
** Update Hotwords range if user do editing before to hotword and remove hotword from dictionary if editing between hotwords.
*/
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    DLog(@"textView.text:%@ \n range:%@, \n text:%@ \n selectedRange.location:%@",textView.text, NSStringFromRange(range), text, NSStringFromRange(textView.selectedRange));
    
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
  [self.qaDetailAppendString setString:self.txtViewKeyword.text];
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
        self.autoCompleteContainer.hidden = NO;
        
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
            DLog(@"name:%@ \n memberId:%@",item.member.name, item.member.memberId);
            [self.memberList removeObject:item];
            break;
        }
    }
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
            DLog(@"name:%@",aCompleteItem.member.name);
        }
    }
    DLog(@"commentString replaceing with id:%@",commentString);
    
    return commentString;
}

//// Hash tagging


-(void)setScrollView
{
    [self.scrollView addSubview:self.txtVewDetails];
    [self.scrollView addSubview:self.txtViewKeyword];
    [self.scrollView addSubview:self.txtViewQuestion];


 }


-(void)getQuestionKeyword
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *strStoryQuestions = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_QuestionKeywords];
    
    DLog(@"%s Performing %@ api",__FUNCTION__,strStoryQuestions);
    [serviceManager executeServiceWithURL:strStoryQuestions forTask:kTaskQuestionKeywords completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response: %@",__FUNCTION__,strStoryQuestions, response);

        if (!error && response) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.keywordDataDic = parsedData;
            });
        }
    }];
}

-(IBAction)askQuestion:(id)sender
{
  if ([self.eventType isEqualToString:kEventType])
     {
        [self editQuestionApi];
      }
  else{
        [self addQuestionApi];
      }
}

-(void)addQuestionApi
{
    DLog(@"%s",__FUNCTION__);
    DLog(@"%@,  %@",self.txtViewKeyword.text,self.tags);
    NSMutableString *tagString = [[NSMutableString alloc] initWithString:[Utility getValidString:self.tags]];
    DLog(@"%@",self.txtViewKeyword.text);
    
    NSString *commentString = @"";
    
    commentString = [self getCommentTextAfterReplacingHashTagToMemberID];
    
    if ([Utility getValidString:self.txtViewQuestion.text].length <1)
    {
        
        [Utility showAlertMessage:@"Question cannot be blank." withTitle:@"Required field empty"];
        
    }
    else if (![Utility getValidString:self.txtViewKeyword.text].length > 0) {
        if (tagString.length >0) {
            [tagString deleteCharactersInRange:NSMakeRange([tagString length]-1, 1)];
        }else{
            [Utility showAlertMessage:@"Please Type or Select Tag" withTitle:@"Required field empty"];
        }
    }
    
    else{
        
        if (![appDelegate isNetworkAvailable])
        {
            [Utility showNetWorkAlert];
            return;
        }
        
        NSDictionary *askQuestionParameters =@{@"mq_m_id" :[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               @"mq_question":self.txtViewQuestion.text,
                                               @"tags": self.txtViewKeyword.text,
                                               @"mq_details":commentString,
                                               };
        
        NSString *getQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_AddQuestion];
       
        DLog(@"%s Performing %@ api  \n with parameter:%@", __FUNCTION__, getQuestionUrl,askQuestionParameters);
        
        [serviceManager executeServiceWithURL:getQuestionUrl andParameters:askQuestionParameters forTask:kTaskPostQuestion completionHandler:^(id response, NSError *error, TaskType task) {
            DLog(@"%s %@ api  \n Response :%@", __FUNCTION__, getQuestionUrl,response);
            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                
                if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utility showAlertMessage:@"Question Posted Successfully" withTitle:@"Message"];
                        if ([self.delegate respondsToSelector:@selector(reloadQATable)]) {
                            
                            [self.delegate reloadQATable];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        
                    });
                }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
                    [appDelegate userAutismSessionExpire];
                }
            }
            else{
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }];
    }
}

-(void)editQuestionApi
{
  
    DLog(@"%s",__FUNCTION__);
    DLog(@"%@,  %@",self.txtViewKeyword.text,self.tags);
    NSMutableString *tagString = [[NSMutableString alloc] initWithString:[Utility getValidString:self.tags]];
    DLog(@"%@",self.txtViewKeyword.text);
    
    NSString *commentString = @"";
    
    commentString = [self getCommentTextAfterReplacingHashTagToMemberID];
    
    if ([Utility getValidString:self.txtViewQuestion.text].length <1)
    {
        
        [Utility showAlertMessage:@"Question cannot be blank." withTitle:@"Required field empty"];
        
    }
    else if (![Utility getValidString:self.txtViewKeyword.text].length > 0) {
        if (tagString.length >0) {
            [tagString deleteCharactersInRange:NSMakeRange([tagString length]-1, 1)];
        }else{
            [Utility showAlertMessage:@"Please Type or Select Tag" withTitle:@"Required field empty"];
        }
    }
    
    else{
        
        if (![appDelegate isNetworkAvailable])
        {
            [Utility showNetWorkAlert];
            return;
        }
        
        NSDictionary *editQuestionParameters =@{@"member_id" :[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               @"question":self.txtViewQuestion.text,
                                               @"tags": self.txtViewKeyword.text,
                                               @"question_details":commentString,
                                               @"question_id":self.strQuestionId,
                                               };
        
        NSString *getQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_EditQuestion];
        
        DLog(@"%s Performing %@ api  \n with parameter:%@", __FUNCTION__, getQuestionUrl,editQuestionParameters);
        
        [serviceManager executeServiceWithURL:getQuestionUrl andParameters:editQuestionParameters forTask:kTaskPostQuestion completionHandler:^(id response, NSError *error, TaskType task) {
            
            DLog(@"%s %@ api  \n Response :%@", __FUNCTION__, getQuestionUrl,response);
            
            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                
                if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utility showAlertMessage:@"Question Updated Successfully" withTitle:@"Message"];
                        
                        if ([self.delegate respondsToSelector:@selector(reloadQATable)]) {
                            [self.delegate reloadQATable];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    
                  });
                    
                }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
                    [appDelegate userAutismSessionExpire];
                }
            }
            else{
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }];
    }
}




-(IBAction)showQuestionKeyword:(id)sender
{
    UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    
   QuestionKeywordViewController *keywordVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QuestionKeywordViewController"];
    [keywordVC setDelegate:self];
    [keywordVC setDictionary:self.keywordDataDic];
    
    
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:keywordVC];
    
    [self presentViewController:nav animated:YES completion:NULL];

}


#pragma mark - QuestionKeywordDelegate

-(void)didSelectKeyword:(NSMutableArray *)selectKeyword
{
    NSMutableString *string = [NSMutableString string];
    self.tags = [NSMutableString string];
    for(QuestionKeywordViewController *myObject in selectKeyword) {
        [self.tags appendString:[NSString stringWithFormat:@"%@,", myObject]];
        [string appendString:[NSString stringWithFormat:@"%@,", myObject]];
    }
    
    self.strMerge = string;
}

-(void)clickonDone
{
    [self.qaDetailAppendString appendString:self.strMerge];
    self.txtViewKeyword.text = self.qaDetailAppendString;
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    textView.backgroundColor = [UIColor whiteColor];
    if (textView == self.txtVewDetails)
        
    {
        [self setViewMovedUp:YES];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    textView.backgroundColor = [UIColor whiteColor];
    return YES;
}


-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.txtViewQuestion) {
        [self.txtViewKeyword becomeFirstResponder];
    }
   else if (textView == self.txtViewKeyword)
    {
        [self.textView becomeFirstResponder];
    }
  else if (textView == self.textView)
    {
        [self setViewMovedDown:YES];
    }
 }

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
    // 2. increase the size of the view so that the area behind the keyboard is covered up.
    //rect.origin.y -= kOFFSET_FOR_KEYBOARD ;
    //rect.size.height += kOFFSET_FOR_KEYBOARD ;
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
    
    if (IS_IPHONE_5) {
        
        if (self.view.frame.size.height >722) {
            return;
          }
    else{
          rect.origin.y -= kOFFSET_FOR_KEYBOARD_5;
          rect.size.height += kOFFSET_FOR_KEYBOARD_5 ;
          self.view.frame = rect;
          [UIView commitAnimations];
        }
    }
    
  else{
        if (self.view.frame.size.height >714) {
            return;
        }

        rect.origin.y -= kOFFSET_FOR_KEYBOARD_4 ;
        rect.size.height += kOFFSET_FOR_KEYBOARD_4 ;
        self.view.frame = rect;
        [UIView commitAnimations];
    }
}

-(void)setViewMovedDown:(BOOL)movedDown
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    
    
    if (IS_IPHONE_5) {
        
        if (self.view.frame.origin.y >= 0) {
             return;
        }

        rect.origin.y += kOFFSET_FOR_KEYBOARD_5 ;
        rect.size.height -= kOFFSET_FOR_KEYBOARD_5 ;
        
       
        self.view.frame = rect;
        [UIView commitAnimations];
    }
    
    else{
        
        if (self.view.frame.origin.y >= 0) {
            return;
         }

        rect.origin.y += kOFFSET_FOR_KEYBOARD_4 ;
        rect.size.height -= kOFFSET_FOR_KEYBOARD_4 ;
        
        self.view.frame = rect;
        
        [UIView commitAnimations];
    }

}

@end

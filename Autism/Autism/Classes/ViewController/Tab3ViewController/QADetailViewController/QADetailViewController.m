//
//  QADetailViewController.m
//  Autism
//
//  Created by Vikrant Jain on 4/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "QADetailViewController.h"
#import "QADetailsCustomViewCell.h"
#import "MyImageView.h"
#import "ReportToAWMView.h"
#import "Utility.h"
#import "HelpfulDetailViewController.h"
#import "ReplyDetailViewController.h"
#import "NSDictionary+HasValueForKey.h"
#import "QuestionDetail.h"
#import "CommentViewController.h"
#import "ProfileShowViewController.h"
#import "QuestionDetailHeaderViewCell.h"


@interface QADetailViewController () <UITableViewDataSource,UITableViewDelegate, ReportToAWMViewDelegate, QADetailsCustomViewCelllDelegate,CommentViewControllerDelegate,QuestionDetailHeaderViewCellDelegate>
{
    NSArray *itemArray;
    BOOL isSelected;
    
    float questionLabelHeight;
    float questionDetailLabelHeight;
    float nameLabelHeight;
    float rowHeight;
    int tableViewHeight;
    CGRect topViewFrame;
    
    float headerLabelHeight;
    float headerDetailLabelHeight;
    float headerNameLabelHeight;
    
    UIStoryboard *mainStoryBoard;
}
- (IBAction)headerProfileView:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *detailHeaderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *qaIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIView *sepratorView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSArray *answerarr;
@property(strong,nonatomic) NSArray *arrayGetQuestionDetails;
@property(strong,nonatomic)IBOutlet MyImageView* profileimage;
@property (strong,nonatomic) ReportToAWMView *reportToAWMView;
@property (strong, nonatomic) IBOutlet UITextView *txtViewQuestion;
@property (strong, nonatomic) IBOutlet UITextView *txtViewQADetails;
@property (strong, nonatomic) IBOutlet UITableView *tableQADetails;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
- (IBAction)backAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnHelpful;
@property (strong, nonatomic) IBOutlet UIButton *btnHelpfulCircle;
@property (strong, nonatomic) IBOutlet UIButton *btnReplyCircle;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
//@property (strong, nonatomic)CommentViewController *commentView;
@property(strong,nonatomic)NSString *strhelpful;
@property (nonatomic,strong) NSString *questionId;
@property (strong ,nonatomic) UIFont* questonFont;

-(IBAction)replyCircleAction:(id)sender;
-(IBAction)helpfulCircleAction:(id)sender;
-(IBAction)helpfulAction:(id)sender;
- (IBAction)replyButtonPressed:(id)sender;

@end

@implementation QADetailViewController

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
    
    mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    
    if (!IS_IPHONE_5) {
        self.tableQADetails.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }

    [self questionDetail];
    
    DLog(@"%s",__FUNCTION__);
    self.lblNoRecordFound.hidden = YES;
    
    topViewFrame = self.lblQuestion.frame;
    tableViewHeight = self.tableQADetails.frame.size.height;
    self.questonFont = [UIFont systemFontOfSize:13.8];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Question";
    
    self.txtViewQuestion.textColor = appUIGreenColor;
    
    [self resizeViews];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(questionDetail) forControlEvents:UIControlEventValueChanged];
    
    [self.tableQADetails addSubview:self.refreshControl];
    
    /*if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        //TODO Apply better approch
        [self updateViewForNotificationScreen];
    }*/

    if (![self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Back"
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(backAction:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resizeViews
{
    nameLabelHeight = [self calculateMessageStringHeight:self.userName];
    questionLabelHeight = [self calculateQADetailStringHeight:self.strgetQuestion];
    questionDetailLabelHeight = [self calculateQADetailStringHeight:self.QADetails];
    
    CGRect nameFrame = self.lblName.frame;
    nameFrame.size.height = nameLabelHeight;
    self.lblName.frame = nameFrame;
    
    CGRect frame = topViewFrame;
    frame.origin.y = self.lblName.frame.origin.y + nameLabelHeight + QACELL_CONTENT_MARGIN;
    frame.size.height = questionLabelHeight;
    self.lblQuestion.frame = frame;
    
    
    CGRect QAImageFrame = self.qaIconImageView.frame;
    frame.origin.y = self.lblQuestion.frame.origin.y;
    self.qaIconImageView.frame = QAImageFrame;

    
    CGRect qaDetailLabelFrame = self.lblQuestionDetail.frame;
    qaDetailLabelFrame.origin.y = self.lblQuestion.frame.origin.y + questionLabelHeight + QACELL_CONTENT_MARGIN;
    qaDetailLabelFrame.size.height = questionDetailLabelHeight ;
    self.lblQuestionDetail.frame = qaDetailLabelFrame;

    
   CGRect buttonViewFrame = self.buttonView.frame;
   buttonViewFrame.origin.y = self.lblQuestionDetail.frame.origin.y + questionDetailLabelHeight + QACELL_CONTENT_MARGIN + BUTTON_VIEW_MERGIN;
    self.buttonView.frame= buttonViewFrame;
    
    
    CGRect bgImageFrame = self.bgImageView.frame;
    bgImageFrame.size.height = self.lblName.frame.origin.y + questionLabelHeight + questionDetailLabelHeight + QADETAILBUTTON_VIEW_HEIGHT + NAMELABEL_HEIGHT + 40;
    self.bgImageView.frame = bgImageFrame;

    
    CGRect tableFrame = self.tableQADetails.frame;
    tableFrame.origin.y = self.bgImageView.frame.size.height;
    
    
   /* if ([self.replyCount integerValue] == 0) {
        tableFrame.size.height = 0;
    } else {
        tableFrame.size.height = tableViewHeight;
    }*/
    //tableFrame.size.height = tableViewHeight;

    //self.tableQADetails.frame = tableFrame;
    
    [self.scrollView setContentSize:CGSizeMake(320, self.tableQADetails.frame.origin.y + self.tableQADetails.frame.size.height + (IS_IPHONE_5 ? 70 : 155))];
}

//TODO Remove code
-(void)updateViewForNotificationScreen
{
    CGRect frame;
    
    frame = self.detailHeaderImageView.frame;
    frame.origin.y -= 64;
    self.detailHeaderImageView.frame = frame;
    
    frame = self.txtViewQADetails.frame;
    frame.origin.y -= 64;
    self.txtViewQADetails.frame = frame;
    
    frame = self.qaIconImageView.frame;
    frame.origin.y -= 64;
    self.qaIconImageView.frame = frame;
    
    frame = self.txtViewQuestion.frame;
    frame.origin.y -= 64;
    self.txtViewQuestion.frame = frame;
    
    frame = self.profileimage.frame;
    frame.origin.y -= 64;
    self.profileimage.frame = frame;
    
    frame = self.lblName.frame;
    frame.origin.y -= 64;
    self.lblName.frame = frame;
    
    frame = self.sepratorView.frame;
    frame.origin.y -= 64;
    self.sepratorView.frame = frame;
    
    frame = self.btnHelpful.frame;
    frame.origin.y -= 64;
    self.btnHelpful.frame = frame;
    
    frame = self.btnHelpfulCircle.frame;
    frame.origin.y -= 64;
    self.btnHelpfulCircle.frame = frame;

    
    frame = self.replyButton.frame;
    frame.origin.y -= 64;
    self.replyButton.frame = frame;
    
    frame = self.btnReplyCircle.frame;
    frame.origin.y -= 64;
    self.btnReplyCircle.frame = frame;
    
    frame = self.tableQADetails.frame;
    frame.origin.y -= 64;
    self.tableQADetails.frame = frame;
}

-(void)updateQADetailHeader
{
    [self.btnHelpfulCircle setTitle:self.helpfulCount forState:UIControlStateNormal];
    [self.btnReplyCircle setTitle:self.replyCount forState:UIControlStateNormal];
    self.btnHelpful.selected = self.isCheckHelpful;
    self.questionId = self.strGetQuestionId;
    self.lblQuestion.text = self.strgetQuestion;
   
    //For Hash Tagging
    ///////
    self.lblQuestionDetail.callerView = kCallerViewQADetailHeader;
    [self.lblQuestionDetail setupFontColorOfHashTag];
    self.lblQuestionDetail.QATagArray = [[NSArray alloc] initWithArray:self.qaTagArray];
    self.lblQuestionDetail.qaDetail = [[NSString alloc]initWithString:self.QADetails];;
    self.lblQuestionDetail.text = self.QADetails;
    
    DLog(@"tag %@",self.qaTagArray);
    
    __weak typeof(self) weakSelf = self;
    
    [self.lblQuestionDetail setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[kHotWordHandle, kHotWordHashtag,kHotWordLink, kHotWordNotification];
        NSString *selectedString = [NSString stringWithFormat:@"%@ [%d,%d]: hotWorld: %@, hotWorldID:%@, %@", hotWords[hotWord], (int)range.location, (int)range.length, hotString, hotWorldID,(protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
        
        DLog(@"Clickeded UserID String:%@",selectedString);
        
    [weakSelf showMemberProfile:hotWorldID];
        
    DLog(@"Clickeded UserID String:%@",weakSelf.memberQuestionId);
        
    }];
    self.lblName.text = self.userName;
    [self.profileimage configureImageForUrl:self.imageURL];
    
}

-(void)questionDetail
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.strGetQuestionId)
    {
        DLog(@"GetQuestionId does not exist");
        return;
    }
    NSDictionary *getQuestionParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           @"question_id":self.strGetQuestionId,
                                           };
    NSString *strQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_QuestionDetails];
    DLog(@"Performing %@ api \n with Parameter:%@",strQuestionUrl, getQuestionParameters);
    [serviceManager executeServiceWithURL:strQuestionUrl andParameters:getQuestionParameters forTask:kTaskQuestionDetails completionHandler:^(id response, NSError *error, TaskType task) {
       
        DLog(@"%@ api Question Detail data \n response :%@",strQuestionUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                NSDictionary *data;
                
                if ([dict hasValueForKey:@"data"]) {
                   
                    data = [dict valueForKey:@"data"];
                    
                    if ([data hasValueForKey:@"question_helpful_count"]) {
                        self.helpfulCount = [data valueForKey:@"question_helpful_count"];
                    }
                    if ([data hasValueForKey:@"question_reply_count"]) {
                        self.replyCount = [data valueForKey:@"question_reply_count"];
                    }
                    if ([data hasValueForKey:@"is_helpful"]) {
                        self.isCheckHelpful = [[data valueForKey:@"is_helpful"] boolValue];
                    }
                    if ([data hasValueForKey:@"question_id"]) {
                        self.strGetQuestionId = [data valueForKey:@"question_id"];
                    }
                    if ([data hasValueForKey:@"question"]) {
                        self.strgetQuestion = [data valueForKey:@"question"];
                    }
                    if ([data hasValueForKey:@"question_detail"]) {
                        self.QADetails = [data valueForKey:@"question_detail"];
                        DLog(@"detail %@",self.QADetails);
                    }
                    if ([data hasValueForKey:@"member_name"]) {
                        self.userName = [data valueForKey:@"member_name"];
                    }
                    if ([data hasValueForKey:@"member_picture"]) {
                        self.imageURL = [data valueForKey:@"member_picture"];
                    }
                    
                    if ([data hasValueForKey:@"member_tagged"]) {
                        self.qaTagArray = [data valueForKey:@"member_tagged"];
                    }
                    
                    if ([data hasValueForKey:@"question_reply_is_helpful"]) {
                        
                        self.checkHelpfull = [[data valueForKey:@"question_reply_is_helpful"]boolValue];
                    
                    }
                    
                    if ([data hasValueForKey:@"question_added_member_id"]) {
                        self.questionMemberId = [data valueForKey:@"question_added_member_id"];
                    }
                
                    if ([data hasValueForKey:@"already_in_circle"]) {
                        self.isCircleStatus = [data valueForKey:@"already_in_circle"];
                    }
                  
                    if ([data hasValueForKey:@"question_is_reported"]) {
                        self.isReportAWM = [data valueForKey:@"question_is_reported"];
                    }
                    
                    if ([data hasValueForKey:@"question_self"]) {
                        self.isSelfQuestion = [data valueForKey:@"question_self"];
                    }
                    
                    if ([data hasValueForKey:@"question_self"]) {
                        self.isBlockedMember = [data valueForKey:@"question_self"];
                    }
                }
                
                self.arrayGetQuestionDetails = [parsingManager parseResponse:response forTask:task];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.answerarr = [self.arrayGetQuestionDetails valueForKey:@"answer"];
                    [self updateQADetailHeader];
                    [self resizeViews];
                    [self.tableQADetails reloadData];

                });
            }if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.tableQADetails.hidden = YES;
                    
                    [Utility showAlertMessage:@"Question Detail not found" withTitle:@"Message"];
                });
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                    self.lblNoRecordFound.hidden = NO;
                    self.arrayGetQuestionDetails = nil;
                    [self.tableQADetails reloadData];
                });

            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (IBAction)backAction:(id)sender {
    //*> Navigation Isssue
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UItablevie datasource

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrayGetQuestionDetails.count;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return [self calculateRowHeightAtIndexPath:indexPath];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    QADetailsCustomViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [QADetailsCustomViewCell cellFromNibNamed:@"QADetailsCustomViewCell"];
        cell.delegate = self;
        cell.tag = indexPath.row;
    }
    
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];

    [cell configureDetailCell:[self.arrayGetQuestionDetails objectAtIndex:indexPath.row] detailLabelHeight:questionDetailLabelHeight andCellHeight:cellHeight];
   
    
    return cell;
}

#pragma mark - QADetailsCustomDelegate

-(void)replyButtonPressedAtRow:(long)row withAnswerID:(NSString *)answerID answerText:(NSString *)answerText andanswerTagArray:(NSArray *)answerTagArray buttonState:(BOOL)selected
{
    CommentViewController *commentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeEditAnswerInQADetail;
    commentVC.answerId = answerID;
    commentVC.answerText = answerText;
    commentVC.tagArray = answerTagArray;
    commentVC.parentViewControllerName = kCallerViewQADetailAnswerEdit;
    
    [self presentViewController:commentVC animated:YES completion:nil];
    
}

-(void)updateRecordByPost
{
    [self questionDetail];
}


-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
   QuestionDetail *detail = [self.arrayGetQuestionDetails objectAtIndex:[indexPath row]];
    questionDetailLabelHeight = [self calculateMessageStringHeight:detail.answer];
    rowHeight =  questionDetailLabelHeight + MESSAGE_DETAIL_LABEL_YAXIS + BUTTON_VIEW_HEIGHT;
    rowHeight += CELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    if ([Utility getValidString:answer].length < 1)
        return 0;
    
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(244, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.questonFont} context:nil];
    return textRect.size.height;
    
}


-(float)calculateQADetailStringHeight:(NSString *)answer
{
    if ([Utility getValidString:answer].length < 1)
        return 0;

    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(244,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.questonFont} context:nil];
    return textRect.size.height;
    
}


-(void)questionDetailDeleted
{
    [self questionDetail];
  
}
#pragma ReportToAWMViewDelegate

- (void)reportToAWMVDSuccessfullySubmitted {
    [self.reportToAWMView removeFromSuperview];
    [self questionDetail];
}

- (void)showReportToAWMViewWithReportID:(NSString*)reportID
{
    CGRect frame = self.view.frame;
    frame.origin.y -= 130;
    
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:CGRectMake(0,-60, 320,568)];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeQuestionReplies;
    self.reportToAWMView.selectedQuestionId = reportID;
    [self.view addSubview:self.reportToAWMView];
}


-(void)clickOnHashTag:(NSString *)hotWorldID hashType:(NSString *)hashType forQA:(QuestionDetail *)question
{
    if ([hashType isEqualToString:kHotWordHashtag] && [Utility getValidString:hotWorldID].length > 0) {
        [self showMemberProfile:hotWorldID];
    }
}

- (void)showMemberProfile:(NSString*)memeberID {
    DLog(@"%s",__FUNCTION__);
    
    ProfileShowViewController *profileVC = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
    profileVC.otherUserId = memeberID;
    if (![memeberID isEqualToString:[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]])
        profileVC.profileType =  kProfileTypeOther;
    profileVC.parentViewControllerName = kCallerViewQADetail;
    //[[appDelegate rootNavigationController] pushViewController:profileVC animated:YES];
    
    /*UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:profileVC];

    [self presentViewController:nav animated:YES completion:nil];*/
    [self.navigationController pushViewController:profileVC animated:YES];
}


- (void)clickOnMemeberName:(NSString*)memeberID {
    
    if ([Utility getValidString:memeberID].length > 0) {
        [self showMemberProfile:memeberID];
        
        DLog(@"memberid data %@",memeberID);
    }
}



#pragma mark - UI Methods

-(IBAction)replyCircleAction:(id)sender{
    ReplyDetailViewController *detail = [[ReplyDetailViewController alloc]initWithNibName:@"ReplyDetailViewController" bundle:nil];
  
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        detail.parentViewControllerName = kTitleNotifications;
    }

    detail.replyQuestionId = self.questionId;
    detail.strgetQuestion = self.strgetQuestion;
    detail.replyCount = self.replyCount;
    //*> Navigation issue
    /*UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:detail];

    
    //[self.navigationController pushViewController:nav animated:YES];*/
    
    //[self presentViewController:nav animated:YES completion:Nil];
    
    [self.navigationController pushViewController:detail animated:YES];
    
}

-(IBAction)helpfulCircleAction:(id)sender
{
    HelpfulDetailViewController *detail = [[HelpfulDetailViewController alloc]initWithNibName:@"HelpfulDetailViewController" bundle:nil];
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        detail.parentViewControllerName = kTitleNotifications;
    }
    detail.helpfulQuestionId = self.questionId;
    detail.strgetQuestion = self.strgetQuestion;
    detail.replyCount = self.replyCount;
    //*> Navigation issue
    /*UINavigationController *nav = [[UINavigationController alloc]
     
     initWithRootViewController:detail];
     
     
     //[self.navigationController pushViewController:nav animated:YES];*/
    
    //[self presentViewController:nav animated:YES completion:Nil];
    
    [self.navigationController pushViewController:detail animated:YES];
}


-(void)helppfulCircle
{
    HelpfulDetailViewController *detail = [[HelpfulDetailViewController alloc]initWithNibName:@"HelpfulDetailViewController" bundle:nil];
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        detail.parentViewControllerName = kTitleNotifications;
    }
    detail.helpfulQuestionId = self.questionId;
    detail.strgetQuestion = self.strgetQuestion;
    detail.replyCount = self.replyCount;
    //*> Navigation issue
    /*UINavigationController *nav = [[UINavigationController alloc]
     
     initWithRootViewController:detail];
     
     
     //[self.navigationController pushViewController:nav animated:YES];*/
    
    //[self presentViewController:nav animated:YES completion:Nil];
    
    [self.navigationController pushViewController:detail animated:YES];
}


-(void)replyCircle
{
    ReplyDetailViewController *detail = [[ReplyDetailViewController alloc]initWithNibName:@"ReplyDetailViewController" bundle:nil];
    
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        detail.parentViewControllerName = kTitleNotifications;
    }
    
    detail.replyQuestionId = self.questionId;
    detail.strgetQuestion = self.strgetQuestion;
    detail.replyCount = self.replyCount;
    //*> Navigation issue

    /*UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:detail];
    
    
    //[self.navigationController pushViewController:nav animated:YES];
    
    [self presentViewController:nav animated:YES completion:Nil];
     */
    
    [self.navigationController pushViewController:detail animated:YES];
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
        if ([self.delegate respondsToSelector:@selector(updateQASection)]) {
            [self.delegate updateQASection];
        }
        [self.btnHelpfulCircle setTitle:self.strhelpful forState:UIControlStateNormal];
    }];

}

- (IBAction)replyButtonPressed:(id)sender
{
    [self replyButtonPressed:self.questionId buttonState:self.replyButton.selected];
}

- (void)replyButtonPressed :(NSString *)questionID buttonState:(BOOL)selected
{
    CommentViewController *commentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeReplyOnQuestion;
    commentVC.questionID = questionID;
    
    [self presentViewController:commentVC animated:YES completion:nil];
}

- (void)updateRecordsForReplyCountInQA
{
    [self questionDetail];
}

- (void)commentSuccessfullySubmitted {
    [self questionDetail];
}

- (IBAction)headerProfileView:(id)sender {
    
    [self showMemberProfile:self.memberQuestionId];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self calculateHeadetHeightAtIndexPath];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    QuestionDetailHeaderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QuestionDetailHeaderViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
         cell.profileType = self.profileType;
    }
    float headerCellHeight = [self calculateHeadetHeightAtIndexPath];
    
    [cell passHeaderValue:self.userName question:self.strgetQuestion questionDetail:self.QADetails helpfulCount:self.helpfulCount replyCount:self.replyCount profileImage:self.imageURL questionID:self.strGetQuestionId questionTagArray:self.qaTagArray headerHeight:headerCellHeight helpfulCheck:self.checkHelpfull memberID:self.questionMemberId questionDetailHeight:self.qaDetailHeight questionAddedMemberID:self.questionMemberId memberBlocked:self.isBlockedMember isSelfQuestion:self.isSelfQuestion isMemberReport:self.isReportAWM isMemberInCircle:self.isCircleStatus];
    
    if ([self.parentViewControllerName isEqualToString:kCallerViewMyQA]) {
        if ([self.profileType isEqualToString:kProfileTypeOther]) {
            
            cell.btnReportToAwm.hidden = NO;
        }
    else{
          cell.parentViewControllerName = kCallerViewMyQA;
          cell.btnReportToAwm.hidden = YES;
        }
    }
    return  cell;
}


-(float)calculateHeadetHeightAtIndexPath
{
    headerNameLabelHeight = [self calculateMessageStringHeight:self.userName];
    headerLabelHeight = [self calculateMessageStringHeight:self.strgetQuestion];
    //headerDetailLabelHeight = [self calculateMessageStringHeight:self.QADetails];
   rowHeight = headerLabelHeight + self.qaDetailHeight + headerNameLabelHeight + QA_VIEW_HEIGHT + CELL_CONTENT_MARGIN;
    return rowHeight;
}


-(void)clickOnReplyCircle
{
    [self replyCircle];
}

-(void)clickOnHelpfulCircle
{
    [self helppfulCircle];
}

-(void)likeAnswer
{
    [self questionDetail];
}

-(void)helpulAnswer
{
    [self questionDetail];
}

-(void)memberSuccessfullyAddedInCircle
{
    [self questionDetail];
}


- (void)memberSuccessfullyBlocked {
    [self questionDetail];
    [self.navigationController popViewControllerAnimated:YES];
}


@end

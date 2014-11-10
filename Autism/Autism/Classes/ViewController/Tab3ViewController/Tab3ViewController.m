//
//  Tab3ViewController.m
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "Tab3ViewController.h"
#import "AskNowViewController.h"
#import "QACustomViewCell.h"
#import "QADetailViewController.h"
#import "Utility.h"
#import "ReplyFooterView.h"
#import "CustomTextField.h"
#import "NSDictionary+HasValueForKey.h"
#import "ReportToAWMView.h"
#import "GetAllQuestion.h"
#import "ProfileShowViewController.h"
#import "CommentViewController.h"
#import "QuestionDetailHeaderViewCell.h"
#import "SVPullToRefresh.h"

@interface Tab3ViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource, QACustomViewCellDelegate, ReplyFooterViewDelegate, ReportToAWMViewDelegate, CommentViewControllerDelegate,AskNowViewDelegate,QADetailViewDelegate,QuestionDetailHeaderViewCellDelegate>
{
    int selectedReplyButtonSection;
    int tableViewHeight;
    
    float questionLabelHeight;
    float questionDetailLabelHeight;
    float rowHeight;
    
    BOOL         isInitialPageCount;
    BOOL         isApplyfilter;
    NSInteger    currentPageNumber;
    NSInteger    totalPageCount;
    NSInteger    cellIndexpath;

}

@property(strong,nonatomic) ReportToAWMView *reportToAWMView;
@property(nonatomic, strong) UITextView *activeTextView;
@property(nonatomic, strong) UITextField *activeTextField;
@property (weak, nonatomic) IBOutlet UILabel *noRecordLabel;

@property(strong,nonatomic)NSMutableArray *arrayGetQuestion;
@property(strong,nonatomic)NSArray *keyword;
@property(strong,nonatomic)NSArray *arrayPicker;

@property (strong, nonatomic) IBOutlet UITextField *txtDropdownMenu;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong ,nonatomic) UIFont* qaFont;
@property (strong, nonatomic) NSMutableArray *dataSource;


- (IBAction)AskNow:(id)sender;
- (IBAction)searchAction:(id)sender;

@end

@implementation Tab3ViewController

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
	// Do any additional setup after loading the view.

    self.arrayGetQuestion = [NSMutableArray new];
    //Add Observer for reciveing Notification when user tapped on menu button
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(receivedHideKeyboardNotification:) name:kHideKeyboardFromTab3ViewController object:nil];

      //TODO Check Network Status
     [self getAllQuestion];
    
    self.txtSearch.delegate = self;
    self.txtDropdownMenu.delegate =self;
    
    [self.tableview setSeparatorColor:[UIColor grayColor]];
    
    self.qaFont = [UIFont systemFontOfSize:13];
    self.arrayPicker = [[NSArray alloc] initWithObjects: @"All Questions", @"Most Replies",@"Most Helpful",@"Need Replies", nil];
    
    self.txtDropdownMenu.text =[self.arrayPicker objectAtIndex:0];
    
    [self setupPicker];
    [self getAllQuestion];
    self.tableview.delegate = self;
    [self.tableview registerNib:[UINib nibWithNibName:@"ReplyFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"ReplyFooterView"];
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    
    if (IS_IPHONE_5) {
        CGRect frame = self.tableview.frame;
        frame.size.height = frame.size.height + 88;
        self.tableview.frame = frame;
    }
    tableViewHeight = self.tableview.frame.size.height;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getAllQuestion) forControlEvents:UIControlEventValueChanged];
    [self.tableview addSubview:self.refreshControl];
    
    isInitialPageCount = NO;
    __weak Tab3ViewController *weakSelf = self;
    
    // *************setup infinite scrolling***********
    [self.tableview addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    // parent is nil if this view controller was removed
    if ([self.activeTextField isFirstResponder]) {
        [self.activeTextField resignFirstResponder];
    }
    if ([self.activeTextView isFirstResponder]) {
        [self.activeTextView resignFirstResponder];
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
    [self getAllQuestion];
    selectedReplyButtonSection = -1;
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self resignFirstResponders];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideKeyboardFromTab3ViewController object:nil];
}

#pragma svmethods
- (void)insertRowAtBottom {
    __weak Tab3ViewController *weakSelf = self;
    if (currentPageNumber < totalPageCount) {
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.tableview beginUpdates];
            currentPageNumber += 1;
            //[self callFindPeopleService:self.industryId andTopics:self.topicId];
            [self getAllQuestion];
            
            DLog(@"current page %ld",(long)currentPageNumber);
            [weakSelf.tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            
            [weakSelf.tableview endUpdates];
            [weakSelf.tableview.infiniteScrollingView stopAnimating];
        });
    }
    else
    {
        DLog(@"No more pages to load");
        [weakSelf.tableview.infiniteScrollingView stopAnimating];
    }
}


-(void)setupPicker
{

    self.baseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 170+44)];
    UIToolbar *topBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 44)];
    UIBarButtonItem *dontBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneAction:)];
    dontBtn.tintColor = appUIGreenColor;
    topBar.items = [NSArray arrayWithObject:dontBtn];
    [self.baseView addSubview:topBar];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 216)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.baseView addSubview:self.pickerView];
    
    [self.view addSubview:self.baseView];
}


-(IBAction)showPicker:(id)sender{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height - self.baseView.frame.size.height, self.baseView.frame.size.width, self.baseView.frame.size.height)];
        
    }];
    //[self.pickerView reloadAllComponents];
}

-(void) hidePicker {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 170+44)];
    }];
}

-(void)pickerDoneAction:(id)sender {
    if ([self.txtDropdownMenu.text isEqualToString:@""]) {
        self.txtDropdownMenu.text = (self.arrayPicker.count > 0) ?  [self.arrayPicker firstObject] : @"";
        }
    [self hidePicker];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.arrayPicker count];
    
   }

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
            return [self.arrayPicker objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.txtDropdownMenu.text = [self.arrayPicker objectAtIndex:row];
    [self getAllQuestion];
}


-(void)getAllQuestion
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (self.refreshControl.refreshing) {
        isInitialPageCount = NO;
     }
    NSString *strQuestionUrl;
    NSDictionary *getQuestionParameters =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"type":self.txtDropdownMenu.text,
                                           };
    if (!isInitialPageCount) {
        strQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetAllQueston];
        currentPageNumber = 1;
    }
    else
    {
        strQuestionUrl = [NSString stringWithFormat:@"%@%@/page/%ld",BASE_URL,WEB_URL_GetAllQueston,(long)currentPageNumber];
    }
//DLog(@"Performing :%@ api \n with Parameter:%@",strQuestionUrl,getQuestionParameters);
    
    [serviceManager executeServiceWithURL:strQuestionUrl andParameters:getQuestionParameters forTask:KTaskGetAllQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ QA all question api \n response:%@",__FUNCTION__,strQuestionUrl,response);
    if (!error && response) {
        
        self.dataSource = [parsingManager parseResponse:response forTask:task];
        
        if (!isInitialPageCount) {
            [self.arrayGetQuestion removeAllObjects];
            [self.arrayGetQuestion addObjectsFromArray:self.dataSource];
        }
        else
        {
            [self.arrayGetQuestion addObjectsFromArray:self.dataSource];
        }
        DLog(@"DataSource ...... %@",self.dataSource);
        
        NSDictionary *dict = [[NSDictionary alloc]init];
        dict = (NSDictionary *)response;
        
        if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {            
            dispatch_async(dispatch_get_main_queue(), ^{
                isInitialPageCount = YES;
                totalPageCount = [[response objectForKey:@"total_pages"] integerValue];
                [self.tableview reloadData];
            });
        }
        if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.arrayGetQuestion = nil;
                if (!isInitialPageCount) {
                    [self.tableview reloadData];
                }
                else if (isApplyfilter)
                {
                    [self.tableview reloadData];
                }
            });
        }else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
            [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            
        }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
            [appDelegate userAutismSessionExpire];
        }
    }
    else{
        DLog(@"%s Error:%@",__FUNCTION__,error);
        [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
     }
  }];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableview Delegate

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrayGetQuestion count];
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return 1;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId =@"cell";
    QACustomViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        
        cell = [QACustomViewCell cellFromNibNamed:@"QACustomViewCell"];
        
    }
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     cell.delegate = self;
     cell.tag = indexPath.section;
     cellIndexpath = cell.tag;
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
    
    [cell configureCell:[self.arrayGetQuestion objectAtIndex:indexPath.section] qaLabelHeight:questionLabelHeight qaDetailLabelHeight:questionDetailLabelHeight andCellHeight:cellHeight];
    
     return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateRowHeightAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 22;
    }
    return 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QACustomViewCell *cell = (QACustomViewCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    QADetailViewController *detail = [[QADetailViewController alloc]initWithNibName:@"QADetailViewController" bundle:nil];
    [detail setDelegate:self];
    detail.strGetQuestionId = cell.questionId;
    detail.strgetQuestion   = cell.strQuestion;
    detail.QADetails  = cell.strQuestionDetails;
    detail.imageURL   = cell.imageURL;
    detail.userName   = cell.userName;
    detail.isCheckHelpful = cell.btnHelpful.selected;
    detail.helpfulCount = cell.btnHelpfulCircle.titleLabel.text;
    detail.replyCount =  cell.btnReplyCircle.titleLabel.text;
    detail.qaTagArray = cell.qaTagArray;
    detail.memberQuestionId = cell.addedQuestionMemberID;
    detail.checkHelpfull = cell.checkHelpful;
    detail.qaDetailHeight = cell.qaDetailLabelHeight;
    detail.isSelfQuestion = [NSString stringWithFormat:@"%hhd",cell.isSelfQuestion];
    
    //DLog(@"Clickeded UserID String:%@",detail.memberQuestionId);

    //*> Navigation Isssue
    /* UINavigationController *nav = [[UINavigationController alloc]
     
     initWithRootViewController:detail];
     [self.navigationController presentViewController:nav animated:YES completion:nil];*/
    
    [[appDelegate rootNavigationController] pushViewController:detail animated:YES];
    
    
    DLog(@" id value %@",detail.imageURL);

}


-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    GetAllQuestion* question= [self.arrayGetQuestion objectAtIndex:[indexPath section]];
    questionLabelHeight = [self calculateQADetailStringHeight:question.getQuestion];
    questionDetailLabelHeight = [self calculateQADetailStringHeight:question.quetionDetails];
    rowHeight =  questionLabelHeight + questionDetailLabelHeight + MESSAGE_DETAIL_LABEL_YAXIS + QA_VIEW_HEIGHT + 12;
    rowHeight += CELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateQADetailStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(212,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.qaFont} context:nil];
    return textRect.size.height;
    
}


- (IBAction)searchAction:(id)sender
{
    NSDictionary *getQuestionParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           @"txtQuestion": self.txtSearch.text,
                                           @"type": self.txtDropdownMenu.text,
                                           };

    
    NSString *strQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetAllQueston];
    
    [serviceManager executeServiceWithURL:strQuestionUrl andParameters:getQuestionParameters forTask:KTaskGetAllQuestion completionHandler:^(id response, NSError *error, TaskType task) {
            if (!error) {
            self.arrayGetQuestion = [parsingManager parseResponse:response forTask:task];
                
                DLog(@"question search %@ parameter and \n response %@",getQuestionParameters,response);
                
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.tableview reloadData];
                
            });
        }
    }];
   
}

- (IBAction)AskNow:(id)sender {
    
    AskNowViewController *show = [self.storyboard instantiateViewControllerWithIdentifier:@"AskNowViewController"];
    [show setDelegate:self];
    
    [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
    [[appDelegate rootNavigationController] pushViewController:show animated:YES];
}


#pragma mark - QACustomViewCellDelegate

-(void)questionDeletedAction
{  isInitialPageCount = NO;
   [self getAllQuestion];
}
-(void)questionUpdatedAction
{
    [self getAllQuestion];
}

- (void)memberSuccessfullyAddedInCircle:(BOOL)circleStatus :(NSString *)circleMemberID
{
    for (int i=0; i< self.arrayGetQuestion.count; i++) {
        GetAllQuestion *qaCircle  =  [self.arrayGetQuestion objectAtIndex:i];
        if ([circleMemberID isEqualToString:qaCircle.addedQuestionMemberID]) {
            qaCircle.isMemberAlreadyInCircle = circleStatus;
            [self.arrayGetQuestion replaceObjectAtIndex:i withObject:qaCircle];
        }
    }
    [self.tableview reloadData];
}

- (void)showReportToAWMViewWithReportID:(NSString*)reportID
{
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:self.view.frame];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.selectedQuestionId = reportID;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeQuestion;
    [self.view addSubview:self.reportToAWMView];
}

- (void)memberSuccessfullyBlocked:(BOOL)blockStatus :(NSString *)blockMemberId
{
    isInitialPageCount = NO;
    [self getAllQuestion];
}

- (void)replyButtonPressedAtRow :(long)row withQuestionID:(NSString *)questionID buttonState:(BOOL)selected
{
    CommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeReplyOnQuestion;
    commentVC.questionID = questionID;
    [[appDelegate rootNavigationController] presentViewController:commentVC animated:YES completion:nil];
}

- (void)replySubmitButtonPressedAtRow :(long)row
{
    selectedReplyButtonSection = -1;
    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:row]
                  withRowAnimation:UITableViewRowAnimationFade];
}

- (void)commentSuccessfullySubmitted
{
    DLog(@"%s",__FUNCTION__);
}


- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(GetAllQuestion *)question
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
    [[appDelegate rootNavigationController] pushViewController:profileVC animated:YES];
}


- (void)clickOnMemeberName:(NSString*)memeberID {
    if ([Utility getValidString:memeberID].length > 0) {
        [self showMemberProfile:memeberID];
        
        DLog(@"memberid data %@",memeberID);
    }
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.activeTextField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	self.activeTextField = textField;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

-(BOOL)textViewShouldReturn:(UITextField *)textView
{
    [textView resignFirstResponder];
    return YES;
}

-(void)tappedOnView:(id)sender {
    
    [self.view endEditing:YES];
    [self resignFirstResponders];
}

#pragma mark ReportToAWMViewDelegate

- (void)reportToAWMVDSuccessfullySubmitted {
    [self.reportToAWMView removeFromSuperview];
    [self getAllQuestion];
}

#pragma mark - commentview delegate
- (void)updateRecordsForReplyCountInQA
{
    [self getAllQuestion];
}

#pragma mark - asknowview delegate
- (void)reloadQATable
{
    [self getAllQuestion];
}

#pragma mark- QADetailViewDelegate method
- (void)updateQASection
{
    [self getAllQuestion];
}

-(void)helpfulSuccessfully
{
    [self getAllQuestion];
}
#pragma mark - HideKeyboardNotification

- (void)receivedHideKeyboardNotification:(NSNotification *)notification
{
    DLog("Get %@ From RootVC",notification.name);
    if (notification.name) {
        [self resignFirstResponders];
     }
}

- (void)resignFirstResponders
{
    if ([self.activeTextField isFirstResponder]) {
        [self.activeTextField resignFirstResponder];
      }
}

@end

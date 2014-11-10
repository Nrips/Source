//
//  MyQaViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/15/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

typedef enum
{
    kTabQuestion,
    kTabReplied
    
}TabAction;


#import "MyQaViewController.h"
#import "AskNowViewController.h"
#import "Constants.h"
#import "QACustomViewCell.h"
#import "QADetailViewController.h"
#import "ReplyFooterView.h"
#import "ReportToAWMView.h"
#import "CommentViewController.h"
#import "Utility.h"
#import "SideMenuViewController.h"
#import "GetMyQuestion.h"
#import "ProfileShowViewController.h"
#import "GetMyQuestion.h"

@interface MyQaViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate, QACustomViewCellDelegate, ReplyFooterViewDelegate, ReportToAWMViewDelegate, CommentViewControllerDelegate,AskNowViewDelegate>
{
  
    TabAction currentTabAction; 
    UITextField *txtText;
  	NSArray *arrPicker;
    UIPickerView *StatePicker ;
    UIToolbar *pickerToolbar;
    int selectedReplyButtonSection;
    int tableViewHeight;
    
    float questionLabelHeight;
    float questionDetailLabelHeight;
    float rowHeight;

}


@property (weak, nonatomic) IBOutlet UIButton *btnAskNow;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnRepliesQuestionHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnAskQuestionHeader;
@property (weak, nonatomic) IBOutlet UIImageView *searchImageView;

@property (strong, nonatomic) IBOutlet UITextField *txtSearch;
@property (strong, nonatomic) IBOutlet UIImageView *tabImageView;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property(strong,nonatomic)NSArray *arrayMyQuestion;
@property(strong,nonatomic)UIPickerView *pickerView;
@property (nonatomic, strong) UIView *baseView;
@property(strong,nonatomic) ReportToAWMView *reportToAWMView;
@property(nonatomic, strong) UITextView *activeTextView;
@property(nonatomic, strong) UITextField *activeTextField;

@property (strong ,nonatomic) UIFont* qaFont;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;

@property(nonatomic, strong) UIRefreshControl *refreshControl;

-(IBAction)tabBtnAction:(id)sender;
-(IBAction)AskNow:(id)sender;
-(IBAction)btnSearchAction:(id)sender;

@end

@implementation MyQaViewController

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
    self.arrayMyQuestion = [[NSArray alloc]init];
    
    //Set up view for other user
    
     self.qaFont = [UIFont systemFontOfSize:13];
     self.lblNoRecordFound.hidden = YES;
    
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        //TODO Apply better approch
        //*> Navigation Isssue
        //[self updateViewForNotificationScreen];
    }
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        self.btnAskNow.hidden = YES;
        self.btnSearch.hidden = YES;
        self.btnRepliesQuestionHeader.hidden = YES;
        self.btnAskQuestionHeader.hidden = YES;
        self.txtSearch.hidden = YES;
        self.searchImageView.hidden = YES;
        self.tabImageView.hidden = YES;
        
        self.title = @"Q+A";
        self.tableview.frame = self.view.frame;
    } else {
        self.otherMemberId = @"";
    }
    
    //[self.tableview registerNib:[UINib nibWithNibName:@"ReplyFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"ReplyFooterView"];
    
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    [self getMyQuestion];
    tableViewHeight = self.tableview.frame.size.height;
    
    if (!IS_IPHONE_5) {
        self.tableview .contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getMyQuestion) forControlEvents:UIControlEventValueChanged];
    [self.tableview addSubview:self.refreshControl];
}


-(void)updateViewForNotificationScreen
{
    CGRect frame;
    
    frame = self.btnAskNow.frame;
    frame.origin.y -= 64;
    self.btnAskNow.frame = frame;
    
    frame = self.btnSearch.frame;
    frame.origin.y -= 64;
    self.btnSearch.frame = frame;
    
    frame = self.btnRepliesQuestionHeader.frame;
    frame.origin.y -= 64;
    self.btnRepliesQuestionHeader.frame = frame;
    
    
    frame = self.btnAskQuestionHeader.frame;
    frame.origin.y -= 64;
    self.btnAskQuestionHeader.frame = frame;
    
    frame = self.searchImageView.frame;
    frame.origin.y -= 64;
    self.searchImageView.frame = frame;
    
    frame = self.txtSearch.frame;
    frame.origin.y -= 64;
    self.txtSearch.frame = frame;
    
    frame = self.tabImageView.frame;
    frame.origin.y -= 64;
    self.tabImageView.frame = frame;
}


- (void)didMoveToParentViewController:(UIViewController *)parent
{
    // parent is nil if this view controller was removed
    if ([self.activeTextField isFirstResponder]) {
        [self.activeTextField resignFirstResponder];
    }
    if ([self.activeTextView isFirstResponder]) {
        [self.activeTextView resignFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	// Register notification when keyboard will be show
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
    
	// Register notification when keyboard will be hide
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

// To remove keyboard notification
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    selectedReplyButtonSection = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMyQuestion
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if ([self.profileType isEqualToString:kProfileTypeOther] && [Utility getValidString:self.otherMemberId].length < 1) {
        DLog(@"Can not perform Question/GetMyAllQuestions for other user beacuse other member id not exist");
        return;
    }
    NSDictionary *searchParams =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"other_member_id": [self.profileType isEqualToString:kProfileTypeOther] ? self.otherMemberId : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"type":@"my"
                                  };
    
    NSString *strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMyQueston];
    DLog(@"%s Performing %@ api \n with parameter :%@",__FUNCTION__, strSearchUrl, searchParams);
    [serviceManager executeServiceWithURL:strSearchUrl andParameters:searchParams forTask:kTaskMyQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s Performing %@ api \n Response :%@",__FUNCTION__, strSearchUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.arrayMyQuestion = [parsingManager parseResponse:response forTask:task];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblsearch reloadData];
                    });
             }
            
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                
                if ([self.profileType isEqualToString:kProfileTypeOther]) {
                    self.lblNoRecordFound.hidden = NO;
                    self.lblNoRecordFound.text = @"This member hasn't asked any questions yet.";
                    self.arrayMyQuestion = nil;
                    
                } else {
                    self.lblNoRecordFound.hidden = NO;
                    self.lblNoRecordFound.text = @"You haven't asked any questions yet.";
                    self.arrayMyQuestion = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblsearch reloadData];
                });
            }
        else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }

        } else {
            DLog(@"%s Error:%@",__FUNCTION__,error);
        }
    }];
   [self.refreshControl endRefreshing];
}

- (void)getRepliedQuestion
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *searchParams =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"other_member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"type":@"myReplies"
                                  };
    
    NSString *strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMyQueston];
    DLog(@"Performing myRepliesQuestions api with parameter :%@",searchParams);
    [serviceManager executeServiceWithURL:strSearchUrl andParameters:searchParams forTask:kTaskMyQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"myRepliesQuestions api rewsponse :%@",response);
        
        if (!error) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.arrayMyQuestion = [parsingManager parseResponse:response forTask:task];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblsearch reloadData];
                });
            }
            
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                
                if ([self.profileType isEqualToString:kProfileTypeOther]) {
                    self.lblNoRecordFound.hidden = NO;
                    //self.lblNoRecordFound.text = @"This member hasn't asked any questions yet.";
                    self.arrayMyQuestion = nil;
                    
                } else {
                    self.lblNoRecordFound.hidden = NO;
                    self.lblNoRecordFound.text = @"You haven't replied to any questions yet.";
                    self.arrayMyQuestion = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblsearch reloadData];
                });
            }

        else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else {
                DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];

            }
    }];
    
}

#pragma TAbale View Delagate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrayMyQuestion count];
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
     float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        cell.profileType = self.profileType;
      }
    [cell configureMyCell:[self.arrayMyQuestion objectAtIndex:indexPath.section] qaLabelHeight:questionLabelHeight qaDetailLabelHeight:questionDetailLabelHeight andCellHeight:cellHeight];
   
    cell.tag = indexPath.section;
    cell.delegate = self;
    
     if ([self.profileType isEqualToString:kProfileTypeOther]) {
         
         cell.btnReportToAwm.hidden = NO;
     }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    /*if (selectedReplyButtonSection > -1 && section == selectedReplyButtonSection) {
        ReplyFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ReplyFooterView"];
        footerView.delegate = self;
        footerView.replyText.placeholder = @"Write answer";
        footerView.replyText.delegate = self;
        footerView.commentType = CommentTypeReplyOnQuestion;
        footerView.questionID = ((GetAllQuestion *)[self.arrayMyQuestion objectAtIndex:section]).questionId;
        if ([[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL]) {
            [footerView.userProfileImageView configureImageForUrl:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL]];
        } else
        {
            footerView.userProfileImageView.image = [UIImage imageNamed:@"avatar-140.png"];
        }
        return footerView;
    }*/
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QACustomViewCell *cell = (QACustomViewCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    QADetailViewController *detail = [[QADetailViewController alloc]initWithNibName:@"QADetailViewController" bundle:nil];
    detail.strGetQuestionId = cell.questionId;
    detail.strgetQuestion = cell.strQuestion;
    detail.QADetails  = cell.strQuestionDetails;
    detail.userName  = cell.userName;
    detail.parentViewControllerName = kCallerViewMyQA;
    
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        detail.profileType = kProfileTypeOther;
     }

    
    //*> Navigation Isssue
   /* UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:detail];
    [self.navigationController presentViewController:nav animated:YES completion:nil];*/
    
    [[appDelegate rootNavigationController] pushViewController:detail animated:YES];
}


-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    GetMyQuestion* question= [self.arrayMyQuestion objectAtIndex:[indexPath section]];
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


-(void)clickOnHashTagForMyQA:(NSString *)hotWorldID hashType:(NSString *)hashType forQA:(GetMyQuestion *)question
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
    }
}

-(IBAction)backAction:(id)sender
{
    //*> Navigation Isssue
   // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)AskNow:(id)sender
{
      AskNowViewController *askNowView = [self.storyboard instantiateViewControllerWithIdentifier:@"AskNowViewController"];
      askNowView.delegate = self;
    
      [self.navigationController pushViewController:askNowView animated:YES];
}

-(void)reloadQATable
{   self.lblNoRecordFound.hidden = YES;
    [self getMyQuestion];
    //self.btnAskQuestionHeader.selected = YES;
    [self.tabImageView setImage:[UIImage imageNamed:@"askquestions-replied-btn.png"]];

}

- (IBAction)btnSearchAction:(id)sender {
    
    NSDictionary *searchParams =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"txtQuestion": self.txtSearch.text,
                                  @"other_member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"type" : @"my"
                                  };
    
    NSString *strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMyQueston];
    DLog(@"%s, Performing %@ api \n with parameter :%@",__FUNCTION__,strSearchUrl ,searchParams);

    [serviceManager executeServiceWithURL:strSearchUrl andParameters:searchParams forTask:kTaskMyQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, %@ api \n Response :%@",__FUNCTION__,strSearchUrl ,response);

        if (!error) {
            self.arrayMyQuestion = [parsingManager parseResponse:response forTask:task];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblsearch reloadData];
            });
        }
    }];

}

- (IBAction)tabBtnAction:(id)sender {
    
    currentTabAction = (int)[sender tag];
    
    switch (currentTabAction) {
            
        case kTabQuestion:
            [self.tabImageView setImage:[UIImage imageNamed:@"askquestions-replied-btn.png"]];
             self.lblNoRecordFound.hidden = YES;
            [self getMyQuestion];
            break;
            
        case kTabReplied:
            [self.tabImageView setImage:[UIImage imageNamed:@"replied-askquestions-btn.png"]];
            self.lblNoRecordFound.hidden = YES;
            [self getRepliedQuestion];
            break;
            
        default:
            break;
    }
}


-(void)questionDeletedAction
{
    
    [self getMyQuestion];
}


#pragma UITextFieldDelegate

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
    if (self.activeTextView) {
        [self.activeTextView resignFirstResponder];
       
    }
}

#pragma QACustomViewCellDelegate

- (void)showReportToAWMViewWithReportID:(NSString*)reportID
{
    CGRect frame = self.view.frame;
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications])
        frame.origin.y -= 64;
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:frame];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeQuestion;
    self.reportToAWMView.selectedQuestionId = reportID;
    [self.view addSubview:self.reportToAWMView];
}

-(void)memberSuccessfullyBlocked {
    
    [self getMyQuestion];
}

-(void)helpfulSuccessfully
{
  [self getMyQuestion];
}

-(void)memberSuccessfullyAddedInCircle
{
    [self getRepliedQuestion];
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
#pragma ReportToAWMViewDelegate

- (void)reportToAWMVDSuccessfullySubmitted {
    [self.reportToAWMView removeFromSuperview];
    [self getMyQuestion];
}


#pragma mark KeyBoard Show/Hide Delegate

- (void)keyboardWillShow:(NSNotification *)note
{
    if ([self.activeTextField isFirstResponder])
        return;	// Get the keyboard size
	CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	CGRect frame = self.tableview.frame;
    
	// Start animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    // Get keyboard height
    CGFloat kKeyBoardHeight = keyboardBounds.size.height < keyboardBounds.size.width ? keyboardBounds.size.height : keyboardBounds.size.width;
    
    
    // Reduce size of the Table view
    
    frame.size.height = tableViewHeight - kKeyBoardHeight;
    
	// Apply new size of table view
	self.tableview.frame = frame;
    
	// Scroll the table view to see the TextField just above the keyboard
	if (self.activeTextView)
	{
		CGRect textFieldRect = [self.tableview convertRect:self.activeTextView.bounds fromView:self.activeTextView];
		textFieldRect.size.height = textFieldRect.size.height + 10;
		[self.tableview scrollRectToVisible:textFieldRect animated:NO];
	}
    
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if ([self.activeTextField isFirstResponder])
        return;
	// Get the keyboard size
	CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	CGRect frame = self.tableview.frame;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    frame.size.height = tableViewHeight;
	self.tableview.frame = frame;
	[UIView commitAnimations];
}

@end

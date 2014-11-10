  //
//  ActivityShowViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Neuron-Solutions. All rights reserved.
//

#import "ActivityShowViewController.h"
#import "Utility.h"
#import "CustomMyPostCell.h"
#import "ReplyFooterView.h"
#import "ReportToAWMView.h"
#import "ActivityDetailViewController.h"
#import "CommentViewController.h"
#import "Member.h"
#import "ProfileShowViewController.h"
#import "GetMyActivity.h"
#import "VideoPlayerViewController.h"
#import "SVPullToRefresh.h"

@interface ActivityShowViewController () <UITextViewDelegate, ReplyFooterViewDelegate, CustomMyPostCellDelegate, ReportToAWMViewDelegate, UITextFieldDelegate,CommentViewControllerDelegate, ActivityDetailViewControllerDelegate>
{
    int selectedReplyButtonSection;
    int tableViewHeight;
    
    float activityLabelHeight;
    float nameLabelHeight;
    float attachLinkLabelHeight;
    float rowHeight;
    
    BOOL         isInitialPageCount;
    BOOL         isApplyfilter;
    NSInteger    currentPageNumber;
    NSInteger    totalPageCount;
    NSInteger    cellIndexpath;

}

@property(nonatomic,strong)NSMutableArray *getMyActivityArray;
@property(strong,nonatomic) ReportToAWMView *reportToAWMView;
@property(nonatomic, strong) UITextView *activeTextView;
@property(strong,nonatomic)IBOutlet UILabel* lblNoRecordFound;
@property(strong,nonatomic)UIFont *activityFont;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property(strong,nonatomic)NSString *activityCircleStatus;


@end

@implementation ActivityShowViewController

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
    DLog(@"");
    self.activeTextView.delegate = self;
    self.activityFont = [UIFont systemFontOfSize:13];
    self.getMyActivityArray = [NSMutableArray new];
    
/*    [self.tablePostActivity registerNib:[UINib nibWithNibName:@"ReplyFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"ReplyFooterView"];
   selectedReplyButtonSection = -1;*/
	// Do any additional setup after loading the view.
    
    self.lblNoRecordFound.hidden = YES;
    
    if (!IS_IPHONE_5) {
        self.tablePostActivity.contentInset = UIEdgeInsetsMake(0, 0, 50, 0); //values passed are - top, left, bottom, right
    }
    
    [self getActivity];
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getActivity) forControlEvents:UIControlEventValueChanged];
    [self.tablePostActivity addSubview:self.refreshControl];
    
    [self getMembersList];
    
     isInitialPageCount = NO;
    __weak ActivityShowViewController *weakSelf = self;
    
    // *************setup infinite scrolling***********
    [self.tablePostActivity addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getActivity];
    selectedReplyButtonSection = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma svmethods
- (void)insertRowAtBottom {
    __weak ActivityShowViewController *weakSelf = self;
    if (currentPageNumber < totalPageCount) {
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.tablePostActivity beginUpdates];
            currentPageNumber += 1;
            //[self callFindPeopleService:self.industryId andTopics:self.topicId];
            [self getActivity];

            DLog(@"current page %ld",(long)currentPageNumber);
            [weakSelf.tablePostActivity reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];

            [weakSelf.tablePostActivity endUpdates];
            [weakSelf.tablePostActivity.infiniteScrollingView stopAnimating];
        });
    }
    else
    {
        DLog(@"No more pages to load");
        [weakSelf.tablePostActivity.infiniteScrollingView stopAnimating];
    }
}


-(void)getActivity
{
    DLog(@"");

    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (self.refreshControl.refreshing) {
        
        isInitialPageCount = NO;
    }
    
    NSString *strMyActivityUrl;
    NSDictionary *activityParameters = @{
                                            @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"type": @"all" ,
                                         };
    if (!isInitialPageCount) {
        strMyActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMyActivity];
        currentPageNumber = 1;
     }
    else
     {
         strMyActivityUrl = [NSString stringWithFormat:@"%@%@/page/%ld",BASE_URL,WEB_URL_GetMyActivity,(long)currentPageNumber];
     }

   DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,strMyActivityUrl, activityParameters);
    
    [serviceManager executeServiceWithURL:strMyActivityUrl andParameters:activityParameters forTask:kTaskGetActivity completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api \n response:%@",__FUNCTION__,strMyActivityUrl,response);
        
        if (!error && response) {
            
            self.dataSource = [parsingManager parseResponse:response forTask:task];

            if (!isInitialPageCount)
            {
                [self.getMyActivityArray removeAllObjects];
                [self.getMyActivityArray addObjectsFromArray:self.dataSource];
            }
            else
            {                
                [self.getMyActivityArray addObjectsFromArray:self.dataSource];

             }
            DLog(@"DataSource ...... %@",self.dataSource);
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
              dispatch_async(dispatch_get_main_queue(),^{
                    self.lblNoRecordFound.hidden = YES;
                    isInitialPageCount = YES;
                    totalPageCount = [[response objectForKey:@"total_pages"] integerValue];
                    [self.tablePostActivity reloadData];
                });
            }
       if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.lblNoRecordFound.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.getMyActivityArray = nil;                    
                    if (!isInitialPageCount) {
                        self.lblNoRecordFound.hidden = NO;
                        [self.tablePostActivity reloadData];
                      }
                    else if (isApplyfilter)
                     {   self.lblNoRecordFound.hidden = NO;
                        [self.tablePostActivity reloadData];
                      }

                    });
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
    [self.refreshControl endRefreshing];
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
    //DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,requestUrl, requestParameters);
    
    [serviceManager executeServiceWithURL:requestUrl andParameters:requestParameters forTask:kTaskGetMemberList completionHandler:^(id response, NSError *error, TaskType task) {
        
        //DLog(@"%s %@ Api \n response:%@",__FUNCTION__,requestUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(),^{
                    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
                    appdel.memberListArray = [parsingManager parseResponse:response forTask:task];
                    /*for (Member *member in appdel.memberListArray) {
                        DLog(@"----name:%@ \n id:%@, \n avatar:%@",member.name, member.memberId, member.avatar);
                    }*/
                });
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.getMyActivityArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateRowHeightAtIndexPath:indexPath];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*cellId = @"cell";
    
    CustomMyPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        
        cell = [CustomMyPostCell cellFromNibNamed:@"CustomMyPostCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.tag = indexPath.section;
    //cellIndexpath = cell.tag;
    self.activityCircleStatus = cell.activityMemberId;
    
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
    
    [cell configureCell:[self.getMyActivityArray objectAtIndex:indexPath.section] activityDetailLabelHeight:activityLabelHeight attachLinkHeight:attachLinkLabelHeight andCellHeight:cellHeight];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomMyPostCell *cell = (CustomMyPostCell *)[self.tablePostActivity cellForRowAtIndexPath:indexPath];
   
    cellIndexpath = cell.tag;
    
    GetMyActivity *selectedActivity = (GetMyActivity *)[self.getMyActivityArray objectAtIndex:indexPath.section];
    ActivityDetailViewController *detail = [[ActivityDetailViewController alloc]initWithNibName:@"ActivityDetailViewController" bundle:nil];
    detail.delegate = self;
    detail.activityID = selectedActivity.activityId;
    detail.userName = selectedActivity.name;
    detail.commentText = selectedActivity.detail;
    detail.commentTime = selectedActivity.activityTime;
    detail.imageUrl = selectedActivity.picture;
    detail.isSelfActivity = selectedActivity.isSelfMemberActivity;
    detail.isMemberActivityHug = selectedActivity.isMemberActivityHug;
    detail.isMemberActivityLike = selectedActivity.isMemberActivityLike;
    detail.activityTagArray  = selectedActivity.tagsArray;
    detail.activityMemberId  = selectedActivity.activityMemberId;
    
    //*> Navigation Isssue
    /*
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:detail];
    
    [[appDelegate rootNavigationController] presentViewController:nav animated:YES completion:nil];*/
    
    [[appDelegate rootNavigationController] pushViewController:detail animated:YES];
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    GetMyActivity *activity = [self.getMyActivityArray objectAtIndex:[indexPath section]];
    activityLabelHeight = [self calculateActivityStringHeight:activity.detail];
    attachLinkLabelHeight = [self calculateActivityURLStringHeight:activity.attachLinkUrl];
    
    rowHeight = activityLabelHeight + ACTIVITY_BUTTONVIEW0_HEIGHT + ACTIVITY_MEMBERNAME_HEIGHT + ACTIVITY_TIMELABEL_HEIGHT  + ACTIVITY_LABELMARGIN_HEIGHT + CELL_CONTENT_MARGIN + CELL_LABEL_MARGIN;
    
    
    if (activity.isWallPost) {
        
        rowHeight += ACTIVITY_MEMBERNAME_HEIGHT;
    }
    
    if ([Utility getValidString:activity.attachLinkUrl].length > 0) {
        
        rowHeight += attachLinkLabelHeight + CELL_CONTENT_MARGIN;
    }
    if ([Utility getValidString:activity.attachLinkThumbnailImageUrl].length > 0) {
        
        rowHeight += ACTIVITY_ATTACHIMAGEFRAME_HEIGHT + CELL_CONTENT_MARGIN;
    }

    if (activity.imagesArray.count > 0) {
        rowHeight += ACTIVITY_COLLECTIONVIEW_HEIGHT;
     }
    
    if ([Utility getValidString:activity.attachVideoUrl].length > 0) {
        rowHeight += ACTIVITY_ATTACH_VIDEO_URL_HEIGHT;
    }
        
    if ([Utility getValidString:activity.videoThumbnailImageUrl].length > 0) {
        rowHeight += ACTIVITY_VIDEOFRAME_HEIGHT;
      }
    rowHeight += CELL_CONTENT_MARGIN;
    return rowHeight;
}


-(float)calculateActivityStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(212,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.activityFont} context:nil];
    return textRect.size.height;
}

-(float)calculateActivityURLStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(185,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.activityFont} context:nil];
    return textRect.size.height;
}

#pragma mark - CustomMyPostCellDelegate

- (void)memberSuccessfullyAddedInCircle:(BOOL)circleStatus :(NSString *)memberID
{
    DLog(@"id----...%@",memberID);
  for (int i=0; i< self.getMyActivityArray.count; i++) {
        GetMyActivity *activityCircle  =  [self.getMyActivityArray objectAtIndex:i];
     if ([memberID isEqualToString:activityCircle.activityMemberId]){
            activityCircle.isMemberAlreadyCircle = circleStatus;
            [self.getMyActivityArray replaceObjectAtIndex:i withObject:activityCircle];
        }
    }
[self.tablePostActivity reloadData];
}

- (void)memberSuccessfullyBlocked:(BOOL)circleBlock :(NSString *)blockMemberID
{  for (int i=0; i< self.getMyActivityArray.count; i++) {
    GetMyActivity *activityBlock  =  [self.getMyActivityArray objectAtIndex:i];
      if ([blockMemberID isEqualToString:activityBlock.activityMemberId]) {
            activityBlock.isMemeberBlocked = circleBlock;
            [self.getMyActivityArray replaceObjectAtIndex:i withObject:activityBlock];
         }
     }
    [self.tablePostActivity reloadData];
}

- (void)showReportToAWMViewWithReportID:(NSString*)reportID
{
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:self.view.frame];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.selectedQuestionId = reportID;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeReportActivity;
    [self.view addSubview:self.reportToAWMView];
}

- (void)replyButtonPressedAtRow :(long)row withQuestionID:(NSString *)activityID buttonState:(BOOL)selected
{
    CommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeActivity;
    commentVC.selectedActivityId = activityID;
    [[appDelegate rootNavigationController] presentViewController:commentVC animated:YES completion:nil];
}

-(void)replySubmitButtonPressedAtRow :(long)row
 {
    selectedReplyButtonSection = -1;
    [self.tablePostActivity reloadSections:[NSIndexSet indexSetWithIndex:row]
                  withRowAnimation:UITableViewRowAnimationFade];
  }
- (void)activityDeletedFromActivityView {
    isInitialPageCount = NO;
    [self getActivity];
}

-(void)userLikeActivitySuccessfully:(BOOL)isLikeValue :(NSString *)activityId
{
    for (int i=0; i< self.getMyActivityArray.count; i++) {
        GetMyActivity *activity  =  [self.getMyActivityArray objectAtIndex:i];
        if ([activityId isEqualToString:activity.activityId]) {
            
            activity.isMemberActivityLike = isLikeValue;
            activity.isMemberActivityHug  = isLikeValue;
            
         [self.getMyActivityArray replaceObjectAtIndex:i withObject:activity];
        }
     }
    [self.tablePostActivity reloadData];
}


-(void)activityChanges:(NSString *)activityMemberId :(NSString *)activityId :(BOOL)isLike :(BOOL)isHug :(BOOL)isInCircle :(BOOL)isBolkMember :(BOOL)isReportAwm
{
    for (int i=0; i< self.getMyActivityArray.count; i++) {
        GetMyActivity *activity  =  [self.getMyActivityArray objectAtIndex:i];
        if ([activityMemberId isEqualToString:activity.activityMemberId]) {
            
            activity.isMemberAlreadyCircle = isInCircle;
            activity.isMemeberBlocked = isBolkMember;
            
       if ([activityId isEqualToString:activity.activityId]) {

            activity.isMemberActivityLike = isLike;
            activity.isMemberActivityHug  = isHug;
           
           }
        }
        
        [self.getMyActivityArray replaceObjectAtIndex:i withObject:activity];
        
     }
  [self.tablePostActivity reloadData];
}

- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forMyActivity:(GetMyActivity *)myActivity{
    if ([hashType isEqualToString:kHotWordHashtag] && [Utility getValidString:hotWorldID].length > 0) {
        [self showMemberProfile:hotWorldID];
    }
}

-(void)clickOnMemeberName:(NSString*)memeberID {
    if ([Utility getValidString:memeberID].length > 0) {
        [self showMemberProfile:memeberID];
    }
}

- (void)showMemberProfile:(NSString*)memeberID {
    //DLog(@"%s",__FUNCTION__);

    ProfileShowViewController *profileVC = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
    profileVC.otherUserId = memeberID;
    if (![memeberID isEqualToString:[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]])
        profileVC.profileType =  kProfileTypeOther;
    [[appDelegate rootNavigationController] pushViewController:profileVC animated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.activeTextView = textView;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

-(BOOL)textViewShouldReturn:(UITextField *)textView
{
    [textView resignFirstResponder];
    return YES;
}

-(void)tappedOnView:(id)sender
{
    if ([self.activeTextView isFirstResponder]) {
        [self.activeTextView resignFirstResponder];
    }
    [self.view endEditing:YES];
}

#pragma mark ReportToAWMViewDelegate

- (void)reportToAWMVDSuccessfullySubmitted
{
    [self.reportToAWMView removeFromSuperview];
    [self getActivity];
}

#pragma mark KeyBoard Show/Hide Delegate

- (void)keyboardWillShowMyActivity:(NSNotification *)note
{
    if ([self.activeTextView isFirstResponder])
        return;	// Get the keyboard size
	CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	CGRect frame = self.tablePostActivity.frame;
    
	// Start animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    // Get keyboard height
    CGFloat kKeyBoardHeight = keyboardBounds.size.height < keyboardBounds.size.width ? keyboardBounds.size.height : keyboardBounds.size.width;
    // Reduce size of the Table view
    
    frame.size.height = tableViewHeight - kKeyBoardHeight + 44;
    
	// Apply new size of table view
	self.tablePostActivity.frame = frame;
    
	// Scroll the table view to see the TextField just above the keyboard
	if (self.activeTextView)
	{
		CGRect textFieldRect = [self.tablePostActivity convertRect:self.activeTextView.bounds fromView:self.activeTextView];
		textFieldRect.size.height = textFieldRect.size.height + 10;
		[self.tablePostActivity scrollRectToVisible:textFieldRect animated:NO];
	  }
    [UIView commitAnimations];
}

- (void)keyboardWillHideMyActivity:(NSNotification *)note
{
    if ([self.activeTextView isFirstResponder])
        return;
	// Get the keyboard size
	CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	CGRect frame = self.tablePostActivity.frame;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    frame.size.height = tableViewHeight;
	self.tablePostActivity.frame = frame;
	[UIView commitAnimations];
}

#pragma - ActivityDetailViewControllerDelegate

- (void)activtyDeleted {
    [self getActivity];
}

- (void)videoPlayButtonPressedWithUrl:(NSString*)videoUrl {
    UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    VideoPlayerViewController *VideoPlayerVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    
    VideoPlayerVC.title = @"Video Player";
    
    VideoPlayerVC.videoUrl = videoUrl;
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:VideoPlayerVC];
    
    [[appDelegate rootNavigationController] presentViewController:nav animated:YES completion:nil];
}
@end

//
//  ActivityDetailViewController.m
//  Autism
//
//  Created by Dipak on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "MyImageView.h"
#import "ActivityDetailsCell.h"
#import "Utility.h"
#import "GetMyActivity.h"
#import "NSDictionary+HasValueForKey.h"
#import "ProfileShowViewController.h"
#import "CommentViewController.h"
#import "ActivityDetailHeaderViewCell.h"
#import "VideoPlayerViewController.h"
#import "ReportToAWMView.h"

#define kTableViewCellHieght 121

@interface ActivityDetailViewController () <ActivityDetailsCellDelegate, UITextViewDelegate,CommentViewControllerDelegate,ActivityDetailHeaderViewCellDelegate,ReportToAWMViewDelegate>
{
    UIStoryboard* mainStoryBoard;
    
    int tableViewHeight;
    float nameLabelHeight;
    float DetailLabelHeight;
    float rowHeight;
    
    float headerTimeLabelHeight;
    float headerDetailLabelHeight;
    float headerNameLabelHeight;
    
    float activityLabelHeight;
    float attachLinkLabelHeight;
    float activityNameLabel;
    float activityOtherUserName;

}

@property (strong ,nonatomic) UITextView *activeTextView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextview;
@property (weak, nonatomic) IBOutlet MyImageView *userImageView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSArray *activityDetailsArray;
@property(nonatomic) BOOL isChangeActivity;


@property (strong ,nonatomic) UIFont* activityFont;
@property(weak,nonatomic)ActivityDetailHeaderViewCell *cell;
@property(strong,nonatomic) ReportToAWMView *reportToAWMView;

-(IBAction)removeActivityButtonPressed:(id)sender;

@end

@implementation ActivityDetailViewController
@synthesize isLike,strMessage,btnHug,btnLike;

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
    self.isChangeActivity = NO;
    self.activityFont = [UIFont systemFontOfSize:13.6];
    
    //DLog(@"%s",__FUNCTION__);
    self.title = @"Update";

    [self updateActivityDetail];
   
 UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(cancelButtonPressed:)];
   
    self.navigationItem.leftBarButtonItem = cancelButton;
    

    
    // Do any additional setup after loading the view from its nib.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(updateActivityDetail) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    

    if (!IS_IPHONE_5) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    
    self.strActivityId = self.activityID;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   mainStoryBoard  = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

// To remove keyboard notification
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


- (IBAction)removeActivityButtonPressed:(id)sender {
    
    //DLog(@"%s",__FUNCTION__);
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                      message:@"Are you sure you want to delete this post?"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"No", @"Yes", nil];
    myAlert.tag = kTagDeleteActivityAlert;
    [myAlert show];
}


- (void)updateActivityHeaderView {
    self.userNameLabel.text = self.userName;
    self.commentTimeLabel.text = self.commentTime;
    self.commentTextview.text = self.commentText;
    
    //For Hash Tagging
    ///////
    self.lblHeaderComment.callerView = kCallerViewActivityDetailHeader;
    [self.lblHeaderComment setupFontColorOfHashTag];
    self.lblHeaderComment.ActivityTagArray = [[NSArray alloc] initWithArray:self.activityTagArray];
    self.lblHeaderComment.activityDetail = [[NSString alloc]initWithString:self.commentText];
    self.lblHeaderComment.text = self.commentText;
    
    
    __weak typeof(self) weakSelf = self;
    
    [self.lblHeaderComment setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[kHotWordHandle, kHotWordHashtag,kHotWordLink, kHotWordNotification];
        NSString *selectedString = [NSString stringWithFormat:@"%@ [%d,%d]: hotWorld: %@, hotWorldID:%@, %@", hotWords[hotWord], (int)range.location, (int)range.length, hotString, hotWorldID,(protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
        
        DLog(@"Clickeded UserID String:%@",selectedString);
        
        [weakSelf showMemberProfile:hotWorldID];
    }];

    //self.removeActivityButton.hidden = !self.isSelfActivity;
    [self.userImageView configureImageForUrl:self.imageUrl];
    self.btnHug.selected = self.isMemberActivityHug;
    self.btnLike.selected = self.isMemberActivityLike;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != kTagDeleteActivityAlert) {
        return;
    }
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
     }
    else if (buttonIndex == 1)
    {
        [self deleteActivity];
    }
}


-(void)replyButtonPressedAtRow:(long)row withActivityID:(NSString *)ActivityID ActivityText:(NSString *)activityText andActivityTagArray:(NSArray *)activityTagArray buttonState:(BOOL)selected
{
   CommentViewController *commentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeActivityDetail;
    commentVC.activityDetailId = ActivityID;
    commentVC.activityCommentText = activityText;
    commentVC.tagArray = activityTagArray;
    commentVC.parentViewControllerName = kCallerViewActivityDetail;
    
   // DLog(@"actdetail %@ andtag %@",commentVC.activityCommentText,commentVC.tagArray);
    
    [self presentViewController:commentVC animated:YES completion:nil];
    
}



-(void)deleteActivity
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.activityID)
    {
        DLog(@"ActivtyId does not exist");
        return;
    }
    NSDictionary *deleteActivityParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"activity_id":self.activityID,
                                                 };
    NSString *deleteActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_DeleteActivity];
    //DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,deleteActivityUrl, deleteActivityParameters);
    [serviceManager executeServiceWithURL:deleteActivityUrl andParameters:deleteActivityParameters forTask:kTaskDeleteActivity completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,deleteActivityUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                //*> Navigation Isssue
                [self.navigationController popViewControllerAnimated:YES];
                   // [self dismissViewControllerAnimated:YES completion:nil];
                    if ([self.delegate respondsToSelector:@selector(activtyDeleted)]) {
                        [self.delegate activtyDeleted];
                    }
              } 
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];

}

-(void)updateActivityDetail
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.activityID)
    {  DLog(@"ActivtyId does not exist");
       return;
    }
    NSDictionary *getActivityDetailParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                 @"activity_id":self.activityID
                                                 };
    
    NSString *getActivityDetailUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_GetActivityDetailById];
    //DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,getActivityDetailUrl, getActivityDetailParameters);
    [serviceManager executeServiceWithURL:getActivityDetailUrl andParameters:getActivityDetailParameters forTask:kTaskGetActivityDetailById completionHandler:^(id response, NSError *error, TaskType task) {
       
        DLog(@"%s %@ api  %@ parameter \n response:%@",__FUNCTION__,getActivityDetailUrl,getActivityDetailParameters, response);

        if (!error && response) {
            NSDictionary *dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"])
            {
                NSDictionary *data;
                if ([dict hasValueForKey:@"data"]) {
                    NSArray *dataArray = [dict valueForKey:@"data"];
                    data = [dataArray objectAtIndex:0];
                    if ([data hasValueForKey:@"member_name"]) {
                        self.userName = [data valueForKey:@"member_name"];
                    }
                    if ([data hasValueForKey:@"activity_time"]) {
                        self.commentTime = [data valueForKey:@"activity_time"];
                    }
                    if ([data hasValueForKey:@"member_activity_text"]) {
                        self.commentText = [data valueForKey:@"member_activity_text"];
                    }
                    if ([data hasValueForKey:@"member_activity_self"]) {
                        self.isSelfActivity = [[data valueForKey:@"member_activity_self"] boolValue];
                    }
                    if ([data hasValueForKey:@"member_picture"]) {
                        self.imageUrl = [data valueForKey:@"member_picture"];
                    }
                    if ([data hasValueForKey:@"member_activity_hug"]) {
                        self.isMemberActivityHug = [[data valueForKey:@"member_activity_hug"] boolValue];
                    }
                    if ([data hasValueForKey:@"member_activity_like"]) {
                        self.isMemberActivityLike = [[data valueForKey:@"member_activity_like"] boolValue];
                    }
                    if ([data hasValueForKey:@"member_tagged"]) {
                        self.activityTagArray = [data valueForKey:@"member_tagged"];
                    }
                    
                    if ([data hasValueForKey:@"activity_member_id"]) {
                        
                        self.activityMemberid = [data valueForKey:@"activity_member_id"];
                    }
                    
                    self.attachVideoUrl = [data hasValueForKey:@"activity_video_link"] ? [data objectForKey:@"activity_video_link"] : @"";
                    
                    self.videoThumbnailImageUrl = [data hasValueForKey:@"activity_video_thumbnail"] ? [data objectForKey:@"activity_video_thumbnail"] : @"";
                    
                    self.videoUrl = [data hasValueForKey:@"activity_video_ifame"] ? [data objectForKey:@"activity_video_ifame"] : @"";
                    
                    
                    if ([data hasValueForKey:@"activity_images"]) {
                        self.imagesArray = [data objectForKey:@"activity_images"];
                        DLog(@"activity images %@",self.imagesArray);
                    }
                    
                    if ([data hasValueForKey:@"member_activity_link"]) {
                        self.attachLinkUrl = [data objectForKey:@"member_activity_link"];
                        
                    }
                    
                    if ([data hasValueForKey:@"member_activity_image_attach_link"]) {
                        self.attachLinkThumbnailImageUrl = [data objectForKey:@"member_activity_image_attach_link"];
                        
                    }
                    if ([data hasValueForKey:@"member_activity_is_reported"]) {
                        self.isMemberActivityReported = [[data valueForKey:@"member_activity_is_reported"] boolValue];
                    }
                    if ([data hasValueForKey:@"is_member_already_circle"]) {
                      self.isMemberAlreadyInCircle = [[data valueForKey:@"is_member_already_circle"] boolValue];
                      
                      }
                    if ([data hasValueForKey:@"is_memeber_blocked"]) {
                        self.isMemeberBlocked = [[data valueForKey:@"is_memeber_blocked"] boolValue];
                     }
                    
                    if ([data hasValueForKey:@"is_wall_post"]) {
                        self.isWallPost = [[data objectForKey:@"is_wall_post"]boolValue];
                    }
                    
                    if ([data hasValueForKey:@"wall_post_member_id"]) {
                        self.wallPostuserId = [data objectForKey:@"wall_post_member_id"];
                    }
                    
                    if ([data hasValueForKey:@"wall_post_member_name"]) {
                        self.wallPostUserName = [data objectForKey:@"wall_post_member_name"];
                    }
                }
                self.activityDetailsArray = [parsingManager parseResponse:response forTask:task];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                  
                    [self.tableView reloadData];
                });
              }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                  self.tableView.hidden = YES;
                 [Utility showAlertMessage:@"Activity detail not found" withTitle:@"Message"];
               }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    [self.refreshControl endRefreshing];
}

#pragma mark - UItablevie datasource

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activityDetailsArray.count;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateRowHeightAtIndexPath:indexPath];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ActivityDetailsCell";
    ActivityDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [ActivityDetailsCell cellFromNibNamed:@"ActivityDetailsCell"];
        cell.tag = indexPath.row;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
   
    [cell configureActivityDetailCell:[self.activityDetailsArray objectAtIndex:indexPath.row] detailLabelHeight:activityLabelHeight andCellHeight:cellHeight];
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self calculateHeadetHeightAtIndexPath];
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath
{
    ActivityDetails *activity = [self.activityDetailsArray objectAtIndex:[indexPath row]];
    activityLabelHeight = [self calculateMessageStringHeight:activity.commentText];
    
    rowHeight = activityLabelHeight + ACTIVITY_BUTTONVIEW0_HEIGHT + ACTIVITY_MEMBERNAME_HEIGHT + ACTIVITY_LABELMARGIN_HEIGHT + ACTIVITY_MEMBERNAME_HEIGHT;
    
    return rowHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ActivityDetailHeaderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ActivityDetailHeaderViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    if ([self.parentViewControllerName isEqualToString:kCallerViewFindPeople])
     {
         cell.parentViewControllerName = kCallerViewFindPeople;
      }
    
    float headerCellHeight = [self calculateHeadetHeightAtIndexPath];
    
    [cell passHeaderValue:self.userName time:self.commentTime activityDetail:self.commentText activityID:self.activityID profileImage:self.imageUrl likeValue:self.isMemberActivityLike hugValue:self.isMemberActivityHug activityTagArray:self.activityTagArray headerHeight:headerCellHeight memberID:self.activityMemberid attachLink:self.attachLinkUrl imageAttachLink:self.attachLinkThumbnailImageUrl vedioLink:self.videoUrl vedioLinkImage:self.videoThumbnailImageUrl imageArray:self.imagesArray memberBlocked:self.isMemeberBlocked isSelfActivity:self.isSelfActivity isActivityMemberReport:self.isMemberActivityReported isMemberInCircle:self.isMemberAlreadyInCircle attachVedioLink:self.AttachVideoUrl WallPostUserName:self.wallPostUserName wallPostUserId:self.wallPostuserId isWallPost:self.isWallPost];
    
      return  cell;
}


-(float)calculateHeadetHeightAtIndexPath
{
    activityLabelHeight = [self calculateMessageStringHeight:self.commentText];
    attachLinkLabelHeight = [self calculateMessageStringHeight:self.attachLinkUrl];
    activityNameLabel = [self calculateMessageStringHeight:self.userName];
    activityOtherUserName = [self calculateMessageStringHeight:self.wallPostUserName];
    
    rowHeight = activityLabelHeight + ACTIVITY_BUTTONVIEW0_HEIGHT + ACTIVITY_TIMELABEL_HEIGHT  + ACTIVITY_LABELMARGIN_HEIGHT + activityNameLabel + CELL_LABEL_MARGIN;
    
    if (self.isWallPost) {
        
        rowHeight += activityOtherUserName;
    }
    
    if ([Utility getValidString:self.attachLinkUrl].length > 0) {
        
        rowHeight += attachLinkLabelHeight + CELL_CONTENT_MARGIN;
    }
    if ([Utility getValidString:self.attachLinkThumbnailImageUrl].length > 0) {
        
        rowHeight += ACTIVITY_ATTACHIMAGEFRAME_HEIGHT + CELL_CONTENT_MARGIN;
    }
    
    if (self.imagesArray.count > 0) {
        rowHeight += ACTIVITY_COLLECTIONVIEW_HEIGHT;
    }
    
    if ([Utility getValidString:self.AttachVideoUrl].length > 0) {
        rowHeight += ACTIVITY_ATTACH_VIDEO_URL_HEIGHT;
    }

    if ([Utility getValidString:self.videoThumbnailImageUrl].length > 0) {
        rowHeight += ACTIVITY_VIDEOFRAME_HEIGHT;
    }
    rowHeight += CELL_CONTENT_MARGIN;
    return rowHeight;
    
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(235, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.activityFont} context:nil];
    return textRect.size.height;
}

#pragma  mark - ActivityDetailsCellDelegate

-(void)clickOnHashTag:(NSString *)hotWorldID hashType:(NSString *)hashType forActivity:(ActivityDetails *)activity
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
    profileVC.parentViewControllerName = kCallerViewActivityDetail;
    
    //[[appDelegate rootNavigationController] pushViewController:profileVC animated:YES];
    [self.navigationController pushViewController:profileVC animated:YES];
    
}


-(void)videoPlayButtonPressedWithUrl:(NSString*)videoUrl {
        
    VideoPlayerViewController *VideoPlayerVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    
    VideoPlayerVC.title = @"Video Player";
    
    VideoPlayerVC.videoUrl = videoUrl;
    VideoPlayerVC.parentView = kCallerViewActivityDetail;
    
     //*> Navigation Isssue
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:VideoPlayerVC];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)activityDeletedFromActivityView
{
    if ([self.delegate respondsToSelector:@selector(activtyDeleted)]) {
        [self.delegate activtyDeleted];
      }
   // [self dismissViewControllerAnimated:YES completion:nil];
    
    //*> Navigation Isssue
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)clickOnMemeberName:(NSString *)activityID
{
    [self showMemberProfile:activityID];
}

- (void)activityCommentDeleted
{
    [self updateActivityDetail];
}

-(void)activityCommentLike
{
    [self updateActivityDetail];
}

-(void)updateRecordByPost
{
  [self updateActivityDetail];
}

#pragma mark - Activity Header CellDelegate

- (void)memberSuccessfullyAddedInCircle:(BOOL)isInCircle
{  self.isChangeActivity = YES;
    self.isMemberAlreadyInCircle = isInCircle;
   [self updateActivityDetail];
}

- (void)memberSuccessfullyBlocked:(BOOL)isBlockMember
{  self.isChangeActivity = YES;
    self.isMemeberBlocked = isBlockMember;
   [self updateActivityDetail];
}

-(void)memberSuccessfullyHug:(BOOL)isHug
{   self.isChangeActivity = YES;
    self.isHug = isHug;
    [self updateActivityDetail];
}

-(void)memberSuccessfullyLike:(BOOL)isLikevalue
{    self.isChangeActivity = YES;
     self.isLike = isLikevalue;
    [self updateActivityDetail];
}


#pragma mark KeyBoard Show/Hide Delegate

- (void)keyboardWillShowMyActivity:(NSNotification *)note
{
	
    // Get the keyboard size
	/*CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	CGRect frame = self.tableView.frame;
    
	// Start animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    // Get keyboard height
    CGFloat kKeyBoardHeight = keyboardBounds.size.height < keyboardBounds.size.width ? keyboardBounds.size.height : keyboardBounds.size.width;
    
    // Reduce size of the Table view
    
    frame.size.height = tableViewHeight - kKeyBoardHeight;
    //frame.size.height = 184;*/
	CGRect frame = CGRectMake(0, 168, 320, 184);
    self.tableView.frame = frame;

	// Apply new size of table view
    
   	// Scroll the table view to see the TextView just above the keyboard
	if (self.activeTextView)
	{
		CGRect textFieldRect = [self.tableView convertRect:self.activeTextView.bounds fromView:self.activeTextView];
		textFieldRect.size.height = textFieldRect.size.height;
		[self.tableView scrollRectToVisible:textFieldRect animated:NO];
	}
    
	[UIView commitAnimations];
}

- (void)keyboardWillHideMyActivity:(NSNotification *)note
{
	// Get the keyboard size
	CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	//CGRect frame = self.tableView.frame;
    CGRect frame = CGRectMake(0, 198, 320, 370);
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    frame.size.height = tableViewHeight;
	self.tableView.frame = frame;
	[UIView commitAnimations];
}

-(void)tappedOnView:(id)sender
{
    if ([self.activeTextView isFirstResponder]) {
        [self.activeTextView resignFirstResponder];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.selectedRange = NSMakeRange(self.activeTextView.text.length, 0);

    if ([self.activeTextView isFirstResponder]){
        [self.activeTextView becomeFirstResponder];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.activeTextView isFirstResponder]) {
        [self.activeTextView resignFirstResponder];
    }
}

#pragma mark - UIMethods
-(IBAction)likeAction:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.activityID) {
        DLog(@"likeActivity api call not perform because ActivityId is not exist");
        return;
    }
    
    
    NSDictionary *likeActivityParameter =@{   @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"activity_id":self.activityID,
                                              @"type": @"like"
                                              
                                              };
    
    NSString *strLikeActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostLikeHug];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__, strLikeActivityUrl, likeActivityParameter);
    
    [serviceManager executeServiceWithURL:strLikeActivityUrl andParameters:likeActivityParameter forTask:kTaskLikeHug completionHandler:^(id response, NSError *error, TaskType task) {
         //DLog(@"%s %@ api \n Response:%@",__FUNCTION__, strLikeActivityUrl, response);
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
           
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                isLike = [[response objectForKey:@"is_like"] boolValue];
                self.cell.btnLike.selected = isLike;
                
                if ([self.delegate performSelector:@selector(userLikeActivitySuccessfully)]) {
                    [self.delegate userLikeActivitySuccessfully];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else{
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
    }];
}


-(IBAction)hugAction:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!_activityID) {
        DLog(@"hug Activity api call not perform because questionId is not exist");
        return;
    }
    
    NSDictionary *hugActivityParameter =@{   @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"activity_id":_activityID,
                                             @"type": @"hug",
                                             
                                             };
    
    DLog(@"%s Performing auth/hugActivity with parameter:%@",__FUNCTION__,hugActivityParameter);
    
    
    NSString *strHugActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostLikeHug];
    
    [serviceManager executeServiceWithURL:strHugActivityUrl andParameters:hugActivityParameter forTask:kTaskLikeHug completionHandler:^(id response, NSError *error, TaskType task) {
        //DLog(@"%s Response of auth/hugActivity api:%@",__FUNCTION__,response);
        
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isHug = [[response objectForKey:@"is_hug"] boolValue];
                    self.btnHug.selected = self.isHug;
                    if ([self.delegate performSelector:@selector(userLikeActivitySuccessfully)]) {
                        [self.delegate userLikeActivitySuccessfully];
                    }
                });
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            
            else{
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
    }];
}

- (IBAction)shareAction:(id)sender
{
    
    self.btnShare.selected = YES;
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (self.activityID.length < 1) {
        DLog(@"share Activity api call not perform because questionId is not exist");
        return;
    }
    
    NSDictionary *shareActivityParameter =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"activity_id":_activityID,
                                             
                                             };
    
    NSString *shareActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ShareActivity];
    
    DLog(@"%s Performing  %@ api \n with parameter:%@",__FUNCTION__,shareActivityUrl, shareActivityParameter);
    
    [serviceManager executeServiceWithURL:shareActivityUrl andParameters:shareActivityParameter forTask:kTaskShareActivity completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ \n with response : %@ ",__FUNCTION__,shareActivityUrl,response);
        self.btnShare.selected = NO;
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    DLog(@"share api response %@",response);
                    [Utility showAlertMessage:@"" withTitle:@"You have successfully shared this post"];
                });
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

- (IBAction)commentButtonPressed:(id)sender {
    [self replyButtonPressed:self.strActivityId buttonState:self.btncomment.selected];
}


- (void)showReportToAWMViewWithReportID:(NSString*)reportID
{
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:CGRectMake(0, -60, self.view.frame.size.width, self.view.frame.size.height)];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.selectedQuestionId = reportID;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeReportActivity;
    [self.view addSubview:self.reportToAWMView];
}

#pragma mark ReportToAWMViewDelegate

- (void)reportToAWMVDSuccessfullySubmitted
{
    [self.reportToAWMView removeFromSuperview];
    [self updateActivityDetail];
}


-(void)replyButtonPressed :(NSString *)activityID buttonState:(BOOL)selected
{
   CommentViewController *commentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeActivity;
    commentVC.selectedActivityId = activityID;
    
    [self presentViewController:commentVC animated:YES completion:nil];
}

-(void)commentButtonPressed:(NSString *)activityID buttonState:(BOOL)selected
{
    CommentViewController *commentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeActivity;
    commentVC.selectedActivityId = activityID;
    
    [self presentViewController:commentVC animated:YES completion:nil];
}


#pragma mark-  commentview delegate implementation
-(void)commentSuccessfullySubmitted
{
    [self updateActivityDetail];
}

-(IBAction)cancelButtonPressed:(id)sender
{
    if (self.isChangeActivity) {
       if ([self.delegate respondsToSelector:@selector(activityChanges:::::::)]) {
           [self.delegate activityChanges:self.activityMemberId :self.activityID :self.isLike :self.isHug :self.isMemberAlreadyInCircle :self.isMemeberBlocked :self.isMemberActivityReported];
          }
       [self.navigationController popViewControllerAnimated:YES];
    }
   else{
       //> Navigation Isssue
    [self.navigationController popViewControllerAnimated:YES];
   }
}

@end

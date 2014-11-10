//
//  MyUpdateViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 3/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MyUpdateViewController.h"

#import "ActivityDetailViewController.h"
#import "CommentView.h"
#import "CustomMyPostCell.h"
#import "GetMyActivity.h"
#import "Utility.h"
#import "CommentViewController.h"
#import "ProfileShowViewController.h"
#import "VideoPlayerViewController.h"

@interface MyUpdateViewController () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate, UITextViewDelegate, ActivityDetailViewControllerDelegate,CommentViewDelegate,CommentViewControllerDelegate, CustomMyPostCellDelegate>
{
  UIStoryboard *mainStoryBoard;
    float activityLabelHeight;
    float attachLinkLabelHeight;
    float rowHeight;
}

@property (nonatomic, strong) CommentView *commentView;
@property(nonatomic,strong)UIFont* activityFont;
@property (nonatomic, assign) BOOL hugValueActivity;
@property (nonatomic, assign) BOOL likeValueActivity;
@property(nonatomic, strong) UITextView *activeTextView;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) NSAttributedString *attributedString;

@property (nonatomic,assign) NSInteger currentSection;

@property(nonatomic,strong) NSMutableArray *hugArray;
@property(nonatomic,strong) NSMutableArray *likeArray;

@property (nonatomic,strong) IBOutlet UITableView *tablePostActivity;

@property (nonatomic,strong) NSMutableArray *getMyActivityArray;


@end

@implementation MyUpdateViewController

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
    // Do any additional setup after loading the view from its nib.
    self.activityFont = [UIFont systemFontOfSize:13];
    DLog(@"%s",__FUNCTION__);
    [self getMyActivity];
    
    mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];

    
    self.title = @"My Updates";
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getMyActivity) forControlEvents:UIControlEventValueChanged];
    [self.tablePostActivity addSubview:self.refreshControl];

    if (!IS_IPHONE_5) {
        self.tablePostActivity.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Get and post request methods

-(void)getMyActivity
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *activityParameters = @{ @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                          @"type": @"my"
                                          };
    
    NSString *strMyActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMyActivity];
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,strMyActivityUrl, activityParameters);
    
    [serviceManager executeServiceWithURL:strMyActivityUrl andParameters:activityParameters forTask:kTaskGetActivity completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api \n response:%@",__FUNCTION__,strMyActivityUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                self.getMyActivityArray = [parsingManager parseResponse:response forTask:task];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [self.tablePostActivity reloadData];
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
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    [self.refreshControl endRefreshing];
}


-(void)ValuesFetch
{
    [self.tablePostActivity reloadData];
}


#pragma mark - tableview datasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.getMyActivityArray count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    
    CustomMyPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        
        cell = [CustomMyPostCell cellFromNibNamed:@"CustomMyPostCell"];
    }
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
    
    [cell configureCell:[self.getMyActivityArray objectAtIndex:indexPath.row] activityDetailLabelHeight:activityLabelHeight attachLinkHeight:attachLinkLabelHeight andCellHeight:cellHeight];
    
    cell.tag = indexPath.row;
    cell.btnLike.tag = [indexPath row];
    cell.btncomment.tag = [indexPath row];
    cell.btnShare.tag = [indexPath row];
    cell.btnHug.tag =[indexPath row];
    
    [cell.btnShare addTarget:self action:@selector(shareEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnHug addTarget:self action:@selector(ChecktagHug:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnLike addTarget:self action:@selector(likeEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    GetMyActivity *activity = [self.getMyActivityArray objectAtIndex:[indexPath row]];
    activityLabelHeight = [self calculateActivityStringHeight:activity.detail];
    attachLinkLabelHeight = [self calculateActivityURLStringHeight:activity.attachLinkUrl];
    
    rowHeight = activityLabelHeight + ACTIVITY_BUTTONVIEW0_HEIGHT + ACTIVITY_MEMBERNAME_HEIGHT + ACTIVITY_TIMELABEL_HEIGHT  + ACTIVITY_LABELMARGIN_HEIGHT + CELL_CONTENT_MARGIN;
    
    
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


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateRowHeightAtIndexPath:indexPath];
}


#pragma mark - tableview delegates

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.getMyActivityArray objectAtIndex:indexPath.row]) {
        GetMyActivity *selectedActivity = (GetMyActivity *)[self.getMyActivityArray objectAtIndex:indexPath.row];
        ActivityDetailViewController *detail = [[ActivityDetailViewController alloc]initWithNibName:@"ActivityDetailViewController" bundle:nil];
        detail.delegate = self;
        detail.activityID = selectedActivity.activityId;
        detail.userName = selectedActivity.name;
        detail.commentText = selectedActivity.detail;
        detail.commentTime = selectedActivity.activityTime;
        detail.imageUrl = selectedActivity.picture;
        detail.isSelfActivity = selectedActivity.isSelfMemberActivity;
      
        //*> Navigation issue
        /*UINavigationController *nav = [[UINavigationController alloc]
                                       
                                       initWithRootViewController:detail];
        
        
        [self presentViewController:nav animated:YES completion:NULL];*/
        [[appDelegate rootNavigationController] pushViewController:detail animated:YES];
    }
}

#pragma mark - QACustomViewCellDelegate

- (void)memberSuccessfullyAddedInCircle
{
    [self getMyActivity];
}

- (void)memberSuccessfullyBlocked {
    [self getMyActivity];
}


- (void)replyButtonPressedAtRow :(long)row withQuestionID:(NSString *)questionID buttonState:(BOOL)selected
{
    CommentViewController *commentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeActivity;
    commentVC.selectedActivityId = questionID;
    [self presentViewController:commentVC animated:YES completion:nil];

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

- (void)commentSuccessfullySubmitted
{
    [self.commentView removeFromSuperview];
}

- (void)activityDeletedFromActivityView {
    [self getMyActivity];
}

-(void)userLikeActivitySuccessfully
{
    [self getMyActivity];
}

#pragma - ActivityDetailViewControllerDelegate

- (void)activtyDeleted {
    [self getMyActivity];
}

#pragma mark - Cell Button Methods

-(void) shareEvent: (UIButton *)sender
{
    //CustomMyPostCell *cell = [CustomMyPostCell new];
    
   /* UIActionSheet *shareActionSheet =[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share Now", nil];
    
    [shareActionSheet showInView:self.view];*/
}

- (void)likeEvent:(UIButton *)sender
{
    UIButton *likeButton =  (UIButton * )sender;
    if (likeButton.isSelected) {
        [likeButton  setImage:[UIImage imageNamed:@"act-like.png"] forState:UIControlStateNormal];
    }else {
        [likeButton  setImage:[UIImage imageNamed:@"act-like-active.png"] forState:UIControlStateSelected];
    }
    [likeButton  setSelected:!likeButton.isSelected];
    GetMyActivity *currentActivity = [self.getMyActivityArray objectAtIndex:likeButton.tag];
    currentActivity.like = [NSString stringWithFormat:@"%d",likeButton.isSelected];
    [self.getMyActivityArray replaceObjectAtIndex:likeButton.tag withObject:currentActivity];
    currentActivity = [self.getMyActivityArray objectAtIndex:likeButton.tag];
    DLog(@"like:%d",likeButton.isSelected);
}


- (void)commentEvent:(UIButton *)sender
{
    CustomMyPostCell *cell = [CustomMyPostCell new];
    cell.btncomment = (UIButton * )sender;
}

-(void)ChecktagHug:(UIButton *)sender
{
    
    UIButton *hugButton =  (UIButton * )sender;
    if (hugButton.isSelected) {
        [hugButton  setImage:[UIImage imageNamed:@"act-hug.png"] forState:UIControlStateNormal];
    }else {
        [hugButton  setImage:[UIImage imageNamed:@"act-hug-active.png"] forState:UIControlStateSelected];
    }
    [hugButton  setSelected:!hugButton.isSelected];
    DLog(@"like:%d",hugButton.isSelected);

}

- (void)videoPlayButtonPressedWithUrl:(NSString*)videoUrl {
    
    VideoPlayerViewController *VideoPlayerVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    
    VideoPlayerVC.title = @"Video Player";
    
    VideoPlayerVC.videoUrl = videoUrl;
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:VideoPlayerVC];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
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
    
    [self.view endEditing:YES];
    if ([self.activeTextView isFirstResponder]) {
        [self.activeTextView resignFirstResponder];
        [self.commentView removeFromSuperview];
    }
}


#pragma mark KeyBoard Show/Hide Delegate
/*
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
*/

@end

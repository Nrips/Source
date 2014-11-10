//
//  ProfileShowViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/25/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "ProfileShowViewController.h"
#import "ActivityDetailViewController.h"
#import "PostViewController.h"
#import "MyStoryViewController.h"
#import "MyQaViewController.h"
#import "MyFamilyViewController.h"
#import "RootViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "CustomMyPostCell.h"
#import "GetMyActivity.h"
#import "Utility.h"
#import "MyEventLeftMenuViewController.h"
#import "MyCircleViewController.h"
#import "MyCircleFindPeopleViewController.h"
#import "NSDictionary+HasValueForKey.h"
#import "ReportToAWMView.h"
#import "OtherStoryViewController.h"
#import "PECropViewController.h"
#import "CommentViewController.h"
#import "MyPictureViewController.h"
#import "VideoPlayerViewController.h"


@interface ProfileShowViewController ()
<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate, CommentViewControllerDelegate, CustomMyPostCellDelegate, ActivityDetailViewControllerDelegate, PostViewControlleDelegate,ReportToAWMViewDelegate, PECropViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIStoryboard *mainStoryBoard;
    float activityLabelHeight;
    float nameLabelHeight;
    float attachLinkLabelHeight;
    float rowHeight;
}
@property (nonatomic, strong) AppDelegate *appdel;
@property (weak, nonatomic) IBOutlet UIButton *btnAllActivity;
@property (nonatomic) BOOL hugValueActivity;
@property (nonatomic) BOOL likeValueActivity;
@property (nonatomic, strong) NSString *cityAuthorityString;
@property (nonatomic, strong) NSString *activityType;

@property (nonatomic,strong) NSDictionary *memberDetailDict;
@property(nonatomic,strong) NSArray *getMyActivityArray;

@property (nonatomic,assign) NSInteger currentSection;
@property (nonatomic) float heightSum;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;

@property(nonatomic,strong) NSMutableArray *hugArray;
@property(nonatomic,strong) NSMutableArray *likeArray;
@property(nonatomic,strong) NSMutableArray *arrData;
@property(nonatomic,strong)UIFont *activityFont;

@property(nonatomic,strong) CommentViewController *commentView;
@property(nonatomic,strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) ReportToAWMView *reportToAWMView;
@property (nonatomic, strong) UIImage *selectedImage;
@property(nonatomic)BOOL isImageRemove;

- (IBAction)allActivityButtonPressed:(id)sender;
- (IBAction)postUpdateAction:(id)sender;
- (IBAction)myRecentActivityAction:(id)sender;
- (IBAction)blockMemberButtonPressed:(id)sender;
- (IBAction)addToCircleButtonPressed:(id)sender;
- (IBAction)sendMessageButtonPressed:(id)sender;


@end

@implementation ProfileShowViewController

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
    DLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
    self.activityFont = [UIFont systemFontOfSize:13];
    self.appdel = [[UIApplication sharedApplication] delegate];
 
    // Do any additional setup after loading the view from its nib.
    
    mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    
    [self.imgProfilePicture.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    
    self.lblNoRecordFound.hidden = YES;
    
    if (!IS_IPHONE_5) {
        self.tablePostActivity.contentInset = UIEdgeInsetsMake(0, 0, 103, 0); //values passed are - top, left, bottom, right
    }
    
    CALayer * layer = [self.imgProfilePicture layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0];
    [layer setBorderWidth:1.0];
    self.cityAuthorityString = @"";
    
    [self setProfileViewAccodingToProfileType];
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        
        [self getOtherActivity];
        [self.refreshControl addTarget:self action:@selector(getOtherActivity) forControlEvents:UIControlEventValueChanged];
        
    } else{
        [self getActivity];
        [self.refreshControl addTarget:self action:@selector(getActivity) forControlEvents:UIControlEventValueChanged];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapOnImage:)];
        [self.imgProfilePicture addGestureRecognizer:singleTap];
        
    }
    
    [self.tablePostActivity addSubview:self.refreshControl];
    
    /*int increaseHeight = 0;
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        increaseHeight += 88;
    }
    int count = [self.getMyActivityArray count];
    
    if (count > 1) {
        
        NSLog(@"count value %d",count);
    }
    self.scrollView.frame = CGRectMake(0, 0, 320, 565);
    [self.scrollView setContentSize:CGSizeMake(320,650 + increaseHeight)];*/
 }

-(void)scrollViewHeight
{
    int increaseHeight = 0;
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        increaseHeight += 0;
    }
    self.scrollView.frame = CGRectMake(0, 0, 320, 565);
    int count = [self.getMyActivityArray count];
    if (count > 2) {
        
        [self.scrollView setContentSize:CGSizeMake(320,750 + increaseHeight)];
    }
else{
     if (self.heightSum > 333) {
        
        [self.scrollView setContentSize:CGSizeMake(320,750 + increaseHeight)];
      }
     else{ if(self.heightSum > 234){
        
               [self.scrollView setContentSize:CGSizeMake(320,680 + increaseHeight)];
             }
           else{   if(self.heightSum < 217)
                   {
                     [self.scrollView setContentSize:CGSizeMake(320,560 + increaseHeight)];
                    }
                  else{
                       [self.scrollView setContentSize:CGSizeMake(320,650 + increaseHeight)];
                      }
         
                }
          }
     }
if (count == 0) {
    [self.scrollView setContentSize:CGSizeMake(320,560 + increaseHeight)];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
    [self getOtherActivity];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFindPeopleApiCAllFromProfileViewController object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 -(void)setProfileViewAccodingToProfileType
{
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        
        
        self.BtnMyRecentActivity.hidden = YES;
        self.BtnPostUpdate.hidden = YES;
        self.btnAllActivity.hidden = YES;
        
        self.BtnOtherPostUpdate.hidden = NO;
        self.BtnAddToCircle.hidden = NO;
        self.BtnSendMessage.hidden = NO;
        self.BtnBlockMember.hidden = NO;
        
        [self.BtnAddToCircle setTitle:(self.isMemberAlreadyCircle ? kTitleInCircle : kTitleAddToCircle) forState:UIControlStateNormal];
        [self.BtnBlockMember setTitle:(self.isMemeberBlocked ? @"Unblock Member" : @"Block Member" ) forState:UIControlStateNormal];
        
        [self.imgProfilePicture configureImageForUrl:self.profileImage];
        [self.btnMyStory setBackgroundImage:[UIImage imageNamed:@"story-profile-tab.png"] forState:UIControlStateNormal];
        [self.btnMyFamily setBackgroundImage:[UIImage imageNamed:@"family-profile-tab.png"] forState:UIControlStateNormal];
        [self.btnMyPicture setBackgroundImage:[UIImage imageNamed:@"picture-tab.png"] forState:UIControlStateNormal];
        [self.MyCircle setBackgroundImage:[UIImage imageNamed:@"circle-profile-tab.png"] forState:UIControlStateNormal];
        [self.btnMyQA setBackgroundImage:[UIImage imageNamed:@"qa-profile-tab.png"] forState:UIControlStateNormal];
        [self.MyEvents setBackgroundImage:[UIImage imageNamed:@"events-profile-tab.png"] forState:UIControlStateNormal];
        
        self.btnMyPicture.userInteractionEnabled = YES;
        
        self.lblName.text = self.strUserName;
        if ([Utility getValidString:self.strCity].length > 0) {
            self.cityAuthorityString = self.strCity;
        }
        if ([Utility getValidString:self.strLocalAuthority].length > 0) {
            self.cityAuthorityString  = [NSString stringWithFormat:@"%@/%@",self.cityAuthorityString,self.strLocalAuthority];
        }
        self.lblCity.text = self.cityAuthorityString;
        
    } else{
        self.title = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_NAME];
        self.BtnMyRecentActivity.hidden = NO;
        self.BtnPostUpdate.hidden = NO;
        self.btnAllActivity.hidden = NO;
        
        self.BtnOtherPostUpdate.hidden = YES;
        self.BtnAddToCircle.hidden = YES;
        self.BtnSendMessage.hidden = YES;
        self.BtnBlockMember.hidden = YES;

        
        [self.btnMyStory setBackgroundImage:[UIImage imageNamed:@"mystory-profile-tab.png"] forState:UIControlStateNormal];
        [self.btnMyFamily setBackgroundImage:[UIImage imageNamed:@"myfamily-profile-tab.png"] forState:UIControlStateNormal];
        [self.btnMyPicture setBackgroundImage:[UIImage imageNamed:@"my-picture-tab.png"] forState:UIControlStateNormal];
        [self.MyCircle setBackgroundImage:[UIImage imageNamed:@"mycircle-profile-tab.png"] forState:UIControlStateNormal];
        [self.btnMyQA setBackgroundImage:[UIImage imageNamed:@"myqa-profile-tab.png"] forState:UIControlStateNormal];
        [self.MyEvents setBackgroundImage:[UIImage imageNamed:@"myevents-profile-tab.png"] forState:UIControlStateNormal];

        
        if ([Utility getValidString:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_City]].length > 0) {
            self.cityAuthorityString = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_City];
        }
        if ([Utility getValidString:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_LocalAuthority]].length > 0) {
            self.cityAuthorityString  = [NSString stringWithFormat:@"%@/%@",self.cityAuthorityString,[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_LocalAuthority]];
        }
        self.lblCity.text = self.cityAuthorityString;
        
        if ([[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL]) {
            [self.imgProfilePicture configureImageForUrl:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL]];
        }
        if ([Utility getValidString:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_ROLE]].length > 0) {
            self.strNameRole = [NSString stringWithFormat:@"%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_NAME],[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_ROLE]];
        }
        self.profileType = @"My";
        self.lblName.text = self.strNameRole;
        self.btnAllActivity.selected = YES;
        self.activityType = @"my";
    }
}

- (void)updateViewForOtherUser {
    
    if([self.memberDetailDict hasValueForKey:@"is_member_already_circle"]){
        self.isMemberAlreadyCircle = [[self.memberDetailDict valueForKey:@"is_member_already_circle"] boolValue];
        [self.BtnAddToCircle setTitle:(self.isMemberAlreadyCircle ? kTitleInCircle : kTitleAddToCircle) forState:UIControlStateNormal];
    }
    if([self.memberDetailDict hasValueForKey:@"is_memeber_blocked"]){
        self.isMemeberBlocked = [[self.memberDetailDict valueForKey:@"is_memeber_blocked"] boolValue];
        
        [self.BtnBlockMember setTitle:(self.isMemeberBlocked ? @"Unblock Member" : @"Block Member" ) forState:UIControlStateNormal];
    }
    if([self.memberDetailDict hasValueForKey:@"member_full_name"]){
        self.strUserName = [self.memberDetailDict valueForKey:@"member_full_name"];
        self.lblName.text = self.strUserName;
        self.title = self.strUserName;
    }
     if([self.memberDetailDict hasValueForKey:@"member_role"]){
         self.strNameRole= [NSString stringWithFormat:@"%@/%@",self.strUserName,[self.memberDetailDict valueForKey:@"member_role"]];
     }
    if([self.memberDetailDict hasValueForKey:@"member_city"]){
        self.cityAuthorityString = [self.memberDetailDict valueForKey:@"member_city"];
    }
    if([self.memberDetailDict hasValueForKey:@"member_local_authority"]){
        self.cityAuthorityString = [NSString stringWithFormat:@"%@/%@",self.cityAuthorityString, [self.memberDetailDict valueForKey:@"member_local_authority"]];
    }
    if([self.memberDetailDict hasValueForKey:@"member_picture"]){
        [self.imgProfilePicture configureImageForUrl:[self.memberDetailDict valueForKey:@"member_picture"]];
    }
    self.lblName.text = self.strNameRole;
    self.lblCity.text = self.cityAuthorityString;
}

#pragma mark - Get and post request methods

-(void)addToCircleApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.otherUserId) {
        DLog(@"Person id whom you want to add does not exist");
        return;
    }
    NSDictionary *addToCircleParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"add_member_id" : self.otherUserId,
                                            };
    NSString *addToCircleUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_AddMemberInTeam];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,addToCircleUrl, addToCircleParameters);
    [serviceManager executeServiceWithURL:addToCircleUrl andParameters:addToCircleParameters forTask:kTaskAddMemberInTeam completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,addToCircleUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if([[dict objectForKey:@"is_memmber_added_incircle"] boolValue]){
                    [Utility showAlertMessage:@"" withTitle:@"Member added successfully in your circle."];
                    [self.BtnAddToCircle setTitle:kTitleInCircle forState:UIControlStateNormal];
                } else {
                    [self.BtnAddToCircle setTitle:kTitleAddToCircle forState:UIControlStateNormal];
                    [Utility showAlertMessage:@"" withTitle:@"Member successfully removed from your circle."];
                }
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


-(void)getActivity
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *activityParameters = @{ @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                          @"type":self.activityType
                                          };
    
    NSString *strMyActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMyActivity];
    DLog(@"%s Performing %@ api \n with parameter :%@",__FUNCTION__,strMyActivityUrl,activityParameters);
    
    [serviceManager executeServiceWithURL:strMyActivityUrl andParameters:activityParameters forTask:kTaskGetActivity completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s Performing %@ api \n response :%@",__FUNCTION__, strMyActivityUrl, response);
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                self.getMyActivityArray = [parsingManager parseResponse:response forTask:task];
                  dispatch_async(dispatch_get_main_queue(),^{
                    self.lblNoRecordFound.hidden = YES;
                    self.arrData =[response valueForKey:@"data"];
                    [self.tablePostActivity reloadData];
                    [self scrollViewHeight];
                });
            }
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.lblNoRecordFound.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.getMyActivityArray = nil;
                    [self.tablePostActivity reloadData];
                });
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


-(void)getOtherActivity
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    DLog(@"[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]:%@ \n self.otherUserId:%@",[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID], self.otherUserId);
    
    NSDictionary *OtherActivityParameters = @{ @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               @"other_member_id" : self.otherUserId
                                               };
    
    NSString *OtherActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_OtherUserActivity];
    
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,OtherActivityUrl,OtherActivityParameters);
    
    [serviceManager executeServiceWithURL:OtherActivityUrl andParameters:OtherActivityParameters forTask:kTaskOtherActivity completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n Response:%@",__FUNCTION__,OtherActivityUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                NSArray *memberDetailArray;
                if ([dict hasValueForKey:@"member_detail"]) {
                    memberDetailArray  =  [NSArray arrayWithArray:[dict valueForKey:@"member_detail"]];
                    if (memberDetailArray.count > 0) {
                        self.memberDetailDict = [memberDetailArray  objectAtIndex:0];
                        [self updateViewForOtherUser];
                    }
                }
                self.getMyActivityArray = [parsingManager parseResponse:response forTask:task];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    self.arrData = [response valueForKey:@"data"];
                    [self.tablePostActivity reloadData];
                    [self scrollViewHeight];
                });
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                 //[Utility showAlertMessage:@"You are blocked by this member" withTitle:@"connect"];
                self.imgProfilePicture.image = [UIImage imageNamed:@"avatar-140"];
                self.imgProfilePicture.userInteractionEnabled = NO;
                self.lblName.text = @"";
                self.lblRole.text = @"";
                self.lblCity.text = @"";
                
                self.BtnAddToCircle.hidden      = YES;
                self.btnAllActivity.hidden      = YES;
                self.BtnBlockMember.hidden      = YES;
                self.btnMyFamily.hidden         = YES;
                self.btnMyPicture.hidden        = YES;
                self.btnMyQA.hidden             = YES;
                self.BtnMyRecentActivity.hidden = YES;
                self.btnMyStory.hidden          = YES;
                self.BtnOtherPostUpdate.hidden  = YES;
                self.BtnPostUpdate.hidden       = YES;
                self.BtnSendMessage.hidden      = YES;
                self.MyCircle.hidden            = YES;
                self.MyEvents.hidden            = YES;
                self.tablePostActivity.hidden   = YES;
                
                self.scrollView.scrollEnabled   = NO;
                
                UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, 210, 300, 63)];
                lblMessage.text = @"You do not have access to view this profile. If you want to know why please contact AWM.";
                lblMessage.font = [UIFont systemFontOfSize:17.0f];
                lblMessage.numberOfLines = 0;
                lblMessage.textColor = [UIColor grayColor];
                [self.scrollView addSubview:lblMessage];
            }
        }
        else {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self.refreshControl endRefreshing];
    }];
}



-(void)blockMemberApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.otherUserId) {
        DLog(@"Person id whom you want to block/unblock does not exist");
        return;
    }
    
    NSDictionary *blockMemberParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           @"block_member_id" : self.otherUserId,
                                           };
    
    NSString *blockMemberUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_BlockMember];
    DLog(@"Performing %@ api \n with parameter:%@",blockMemberUrl,blockMemberParameters);
    
    [serviceManager executeServiceWithURL:blockMemberUrl andParameters:blockMemberParameters forTask:kTaskBlockMember completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"blockMemberUrl api response :%@",response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.isMemeberBlocked = [[dict valueForKey:@"is_blocked"] boolValue];
                if (self.isMemeberBlocked) {
                    
                    [self.BtnAddToCircle setTitle:(self.isMemberAlreadyCircle ? kTitleAddToCircle : kTitleAddToCircle) forState:UIControlStateNormal];
                    [self.BtnBlockMember setTitle:@"Unblock Member" forState:UIControlStateNormal];
                    [Utility showAlertMessage:@"" withTitle:@"Member Blocked Succussfully"];
                } else {
                    
                    [Utility showAlertMessage:@"" withTitle:@"Member Unblocked Succussfully"];
                    [self.BtnBlockMember setTitle:@"Block Member" forState:UIControlStateNormal];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

-(void)updateProfilePictureApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSString *base64StringFromProfileImage = @"";
    if (self.selectedImage) {
        base64StringFromProfileImage = [self base64forData:UIImagePNGRepresentation(self.selectedImage)];
    }
    
    if ([Utility getValidString:base64StringFromProfileImage].length < 1)
    {
        //[Utility showAlertMessage:@"Can not upload blank image." withTitle:@"Error!"];
        //return;
    }
    
    NSDictionary *requestParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                        @"member_image" : base64StringFromProfileImage,
                                        @"is_image_remove":[NSString stringWithFormat:@"%d",self.isImageRemove],
                                        };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_UpdateProfilePicture];
    
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,requestUrl, requestParameters);
    
    //DLog(@"%s Performing %@ api",__FUNCTION__,requestUrl);

    [serviceManager executeServiceWithURL:requestUrl andParameters:requestParameters forTask:kTaskUpdateProfilePicture completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,requestUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            NSString *profileUrl = [NSString stringWithFormat:@"%@",[response valueForKey:@"data"]];
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [userDefaults removeObjectForKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL];
                [userDefaults setObject:profileUrl forKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL];
                [userDefaults synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.imgProfilePicture configureImageForUrl:profileUrl];
                    [Utility showAlertMessage:@"Profile pic changed successfully" withTitle:@""];
                    if ([self.delegate respondsToSelector:@selector(updateUsersProfileImage:)]) {
                        [self.delegate updateUsersProfileImage:self.selectedImage];
                    }
                });
                //
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else {
                [Utility showAlertMessage:@"Can not upload image there are some problem." withTitle:@"Error!"];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}


#pragma mark - Table view  Datasource and delegate Method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"Recent Activity count:%lu",(unsigned long)[self.getMyActivityArray count]);
    return [self.getMyActivityArray count];
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
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.parentViewControllerName = kCallerViewFindPeople;
    
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
    
     [cell configureCell:[self.getMyActivityArray objectAtIndex:indexPath.row] activityDetailLabelHeight:activityLabelHeight attachLinkHeight:attachLinkLabelHeight andCellHeight:cellHeight];
    
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
        
        rowHeight += attachLinkLabelHeight + CELL_CONTENT_MARGIN + CELL_LABEL_MARGIN;
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
    
    self.heightSum = self.heightSum + rowHeight;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GetMyActivity *selectedActivity = (GetMyActivity *)[self.getMyActivityArray objectAtIndex:indexPath.row];
    ActivityDetailViewController *detail = [[ActivityDetailViewController alloc]initWithNibName:@"ActivityDetailViewController" bundle:nil];

    detail.delegate = self;
    detail.activityID = selectedActivity.activityId;
    detail.userName = selectedActivity.name;
    detail.commentText = selectedActivity.detail ;
    detail.commentTime = selectedActivity.activityTime;
    detail.imageUrl = selectedActivity.picture;
    detail.isSelfActivity = selectedActivity.isSelfMemberActivity;
    detail.parentViewControllerName = kCallerViewFindPeople;
    
    
    
    //*> Navigation issue
    /*UINavigationController *nav = [[UINavigationController alloc]
     
     initWithRootViewController:detail];
     
     
     [self presentViewController:nav animated:YES completion:NULL];*/
    [[appDelegate rootNavigationController] pushViewController:detail animated:YES];
}


#pragma mark - Cell Button Methods

-(void) shareEvent: (UIButton *)sender
{
    UIActionSheet *shareActionSheet =[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share Now", nil];
    
    [shareActionSheet showInView:self.view];
}

-(void) likeEvent: (UIButton *)sender {
    CustomMyPostCell *cell = [CustomMyPostCell new];
    cell.btnLike = (UIButton * )sender;
}

-(void) commentEvent: (UIButton *)sender
{
    CustomMyPostCell *cell = [CustomMyPostCell new];
    cell.btncomment =(UIButton * )sender;
}


-(void)ChecktagHug:(UIButton *)sender
{
    CustomMyPostCell *cell = [CustomMyPostCell new];
    cell.btnHug =(UIButton * )sender;
    
    UIImage *unselectedImage =[UIImage imageNamed:@"hug-default.png"];
    UIImage *selectedImage = [UIImage imageNamed:@"hug-active.png"];
    
    if ([sender isSelected] && cell.hugValue == NO) {
        [sender setImage:unselectedImage forState:UIControlStateNormal];
        [sender setSelected:NO];
        self.hugValueActivity = NO;
    } else {
        [sender setImage:selectedImage forState:UIControlStateSelected];
        [sender setSelected:YES];
        self.hugValueActivity = YES;
    }
}


- (IBAction)mystoryEvent:(id)sender {
  
        OtherStoryViewController *otherStoryVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"OtherStoryViewController"];
        otherStoryVC.otherUserId = self.otherUserId;
        otherStoryVC.parentViewControllerName = self.parentViewControllerName;
        otherStoryVC.profileType = self.profileType;
        [self.navigationController pushViewController:otherStoryVC animated:YES];
}

- (IBAction)myFamilyEvent:(id)sender {
    
    MyFamilyViewController *familyVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyFamilyViewController"];
    familyVC.otherMemberId = self.otherUserId;
    familyVC.profileType = self.profileType;
    [self.navigationController pushViewController:familyVC animated:YES];
    
}

-(IBAction)mycircleEvent:(id)sender {
    
    MyCircleViewController *myCircletVc =[mainStoryBoard instantiateViewControllerWithIdentifier:@"MyCircleViewController"];
    myCircletVc.otherMemberId = self.otherUserId;
    myCircletVc.profileType = self.profileType;
    myCircletVc.parentViewControllerName = self.parentViewControllerName;
    [self.navigationController pushViewController:myCircletVc animated:YES];
}


- (IBAction)myEventsAction:(id)sender {
    
    MyEventLeftMenuViewController *myEventVc =[mainStoryBoard instantiateViewControllerWithIdentifier:@"MyEventLeftMenuViewController"];
    myEventVc.otherMemberId = self.otherUserId;
    myEventVc.profileType = self.profileType;
    myEventVc.parentViewControllerName = self.parentViewControllerName;
    
    DLog(@"other member id %@",myEventVc.otherMemberId);
    [self.navigationController pushViewController:myEventVc animated:YES];
    
}

- (IBAction)myPictureEvent:(id)sender {
    
    MyPictureViewController *pictureVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyPictureViewController"];
    pictureVC.otherMemberId = self.otherUserId;
    pictureVC.profileType = self.profileType;
    pictureVC.parentViewControllerName = self.parentViewControllerName;
    [self.navigationController pushViewController:pictureVC animated:YES];
    
}

- (IBAction)myQAEvent:(id)sender {
    
    MyQaViewController *qaVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyQaViewController"];
    qaVC.otherMemberId = self.otherUserId;
    qaVC.profileType = self.profileType;
    qaVC.parentViewControllerName = self.parentViewControllerName;
    [self.navigationController pushViewController:qaVC animated:YES];

}

- (IBAction)postUpdateAction:(id)sender {
    
    DLog(@"%s",__FUNCTION__ );
  
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
         if (!self.appdel.postUpdateToOtherVC) {
             self.appdel.postUpdateToOtherVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PostViewController"];
         }
         self.appdel.postUpdateToOtherVC.callerView = kPostUpdateTypePostUpdateOther;
         self.appdel.postUpdateToOtherVC.delegate = self;
         self.appdel.postUpdateToOtherVC.otherMemberId = self.otherUserId;
         UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.appdel.postUpdateToOtherVC];
         
         [self presentViewController:navigationController animated:YES completion:nil];
    }else {
        if (!self.appdel.postVC) {
            self.appdel.postVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PostViewController"];
        }
        self.appdel.postVC.callerView = kPostUpdateTypePostUpdateMy;
        self.appdel.postVC.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.appdel.postVC];
        
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    
}

- (IBAction)myRecentActivityAction:(id)sender {
    
    self.btnAllActivity.selected = NO;
    self.BtnMyRecentActivity.selected = YES;
    
    self.activityType = @"recent";
    [self getActivity];
}

- (IBAction)allActivityButtonPressed:(id)sender {
    
    self.btnAllActivity.selected = YES;
    self.BtnMyRecentActivity.selected = NO;
    self.activityType = @"my";
    [self getActivity];
}

- (IBAction)blockMemberButtonPressed:(id)sender {
    
    DLog(@"%s",__FUNCTION__);
    NSString *message = self.isMemeberBlocked ? @"Are you sure you want to Unblock this member?" : @"Are you sure you want to block this member?";
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"No", @"Yes", nil];
    myAlert.tag = kTagBlockMemeberAlert;
    [myAlert show];
}

- (IBAction)addToCircleButtonPressed:(id)sender
{
    [self addToCircleApiCall];
}

- (IBAction)sendMessageButtonPressed:(id)sender {
    DLog(@"%s",__FUNCTION__ );
    
    if (!self.appdel.sendMessageVC) {
        self.appdel.sendMessageVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PostViewController"];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.appdel.sendMessageVC];
    self.appdel.sendMessageVC.callerView = kPostUpdateTypeSendMessage;
    self.appdel.sendMessageVC.delegate = self;
    self.appdel.sendMessageVC.otherMemberId = self.otherUserId;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)removeActivtyButtonPressed:(id)sender
{
   
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != kTagBlockMemeberAlert) {
        return;
    }
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        
    }
    else if (buttonIndex == 1)
    {
        [self blockMemberApiCall];
    }
}

#pragma mark - QACustomViewCellDelegate

- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forMyActivity:(GetMyActivity *)myActivity{
    if ([hashType isEqualToString:kHotWordHashtag] && [Utility getValidString:hotWorldID].length > 0) {
        [self updateProfileViewForMemberID:hotWorldID];
    }
}

- (void)clickOnMemeberName:(NSString*)memeberID {
    if ([Utility getValidString:memeberID].length > 0) {
        [self updateProfileViewForMemberID:memeberID];
    }
}

- (void)updateProfileViewForMemberID:(NSString*)memeberID {
    DLog(@"%s",__FUNCTION__);
    
    if ([memeberID isEqualToString:self.otherUserId])
        return;
    
    self.otherUserId = memeberID;
    if ([memeberID isEqualToString:[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]])
    {
        self.profileType =  @"my";
        self.activityType = @"my";
        [self getActivity];
    } else {
        self.profileType =  kProfileTypeOther;
        [self getOtherActivity];
    }
    [self setProfileViewAccodingToProfileType];
}

- (void)replyButtonPressedAtRow :(long)row withQuestionID:(NSString *)questionID buttonState:(BOOL)selected
{
    CommentViewController *commentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.delegate = self;
    commentVC.commentType = CommentTypeProfile;
    commentVC.selectedActivityId = questionID;
    [self presentViewController:commentVC animated:YES completion:nil];
}

- (void)commentSuccessfullySubmitted
{
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        [self getOtherActivity];
    }else {
        [self getActivity];
    }
    //[self.commentView removeFromSuperview];
    [Utility showAlertMessage:@"" withTitle:@"You commented Successfully."];
}

- (void)activityDeletedFromActivityView {
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        [self getOtherActivity];
    }else {
        [self getActivity];
    }
}

-(void)userLikeActivitySuccessfully
{
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        [self getOtherActivity];
    }else {
        [self getActivity];
    }
}


#pragma mark -  ActivityDetailViewControllerDelegate

- (void)activtyDeleted {
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        [self getOtherActivity];
    }else {
        [self getActivity];
    }
}



- (void)videoPlayButtonPressedWithUrl:(NSString*)videoUrl {

    VideoPlayerViewController *VideoPlayerVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    
    VideoPlayerVC.title = @"Video Player";
    
    VideoPlayerVC.videoUrl = videoUrl;
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:VideoPlayerVC];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}


#pragma mark - PostViewControlleDelegate

- (void)postUpdatedSuccesfully{
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        [self getOtherActivity];
    }else {
        [self getActivity];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ReportToAWMViewMethods

- (void)showReportToAWMViewWithReportID:(NSString*)activityID
{
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:CGRectMake(0,-60, 320,568)];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.selectedQuestionId = activityID;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeReportActivity;
    [self.view addSubview:self.reportToAWMView];
}

- (void)reportToAWMVDSuccessfullySubmitted {
    [self.reportToAWMView removeFromSuperview];
    [self getOtherActivity];
}


#pragma mark - QACustomViewCellDelegate

- (void)memberSuccessfullyAddedInCircle
{
    [self getOtherActivity];
}

- (void)memberSuccessfullyBlocked {
    
    [self getOtherActivity];
}


#pragma mark - Profile Image Cropping Methods

-(void) singleTapOnImage:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select image from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:
                            @"Camera",
                            @"Photo Gallery",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0: {
                    self.selectedImage = nil;
                    self.isImageRemove = YES;
                    self.imgProfilePicture.image = [UIImage imageNamed:@"avatar-140.png"];
                    [self updateProfilePictureApiCall];
                }
                    break;
                case 1: {
                    self.isImageRemove = NO;
                    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:picker animated:YES completion:NULL];
                }
                    break;
                case 2: {
                    self.isImageRemove = NO;
                    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:picker animated:YES completion:NULL];
                }
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

/*
 Open PECropViewController automattically when image selected.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image.size.height < 250 ||  image.size.width < 250) {
        [Utility showAlertMessage:@"" withTitle:kAlertMinimumImageSize];
        return;
    }
    self.selectedImage = image;
    DLog(@"%s, Selected Profile image Size:%@",__FUNCTION__ ,NSStringFromCGSize(image.size));
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    
    if (croppedImage.size.height < 250 ||  croppedImage.size.width < 250) {
        [Utility showAlertMessage:@"" withTitle:kAlertMinimumImageSize];
        return;
    }
    /*
     NSData *data = UIImagePNGRepresentation(self.selectedImage);
     DLog(@"Real Photo galary image from size in MB :%.2f",(float)data.length/1024.0f/1024.0f);*/
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imgProfilePicture.image = croppedImage;
    self.selectedImage = croppedImage;
    DLog(@"%s, Profile image Size After Cropping:%@",__FUNCTION__ ,NSStringFromCGSize(self.selectedImage.size));
    
    /* NSData *data1 = UIImagePNGRepresentation(self.selectedImage);
     DLog(@"Real Photo galary image from size in MB :%.2f",(float)data1.length/1024.0f/1024.0f);*/
    
    [self updateProfilePictureApiCall];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.selectedImage;
    
    UIImage *image = self.selectedImage;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - Base64 conversion

- (NSString*)base64forData:(NSData*) theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

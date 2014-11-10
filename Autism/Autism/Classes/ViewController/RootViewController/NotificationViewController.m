//
//  NotificationViewController.m
//  Autism
//
//  Created by Dipak on 6/10/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationCell.h"
#import "Notification.h"
#import "Utility.h"

#import "ActivityDetailViewController.h"
#import "MyEventsViewController.h"
#import "ProfileShowViewController.h"
#import "ProviderDetailViewController.h"
#import "QADetailViewController.h"

#define kTableViewCellHieght 60


@interface NotificationViewController () <NotificationCellDelegate, ActivityDetailViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *notificationsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) UINavigationItem *nav1;
@property(weak,nonatomic)ActivityDetailViewController *activityView;

@end

@implementation NotificationViewController

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
    
    [self getNotificationsApiCall];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getNotificationsApiCall) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    if (!IS_IPHONE_5) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Cancel"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(cancelButtonPressed:)];
    
    self.nav1.rightBarButtonItem = flipButton;
    
    self.navigationItem.hidesBackButton = YES;
    //self.navigationController.navigationItem.hidesBackButton = YES;
    //self.navigationItem.hidesBackButton = YES;
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{

    return self.notificationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString*cellId = @"cell";
    
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        
        cell = [NotificationCell cellFromNibNamed:@"NotificationCell"];
    }
    [cell configureCell:[self.notificationsArray objectAtIndex:indexPath.row]];
    cell.delegate = self;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}


#pragma mark -UITableview delegates

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Notification *notification = [self.notificationsArray objectAtIndex:indexPath.row];
    ;
    [self showViewAcccordingToNotification:notification];
}

- (void)showViewAcccordingToNotification:(Notification*)notification
{
    if ([[Utility getValidString:notification.notificationType] isEqualToString:@"MemberActivity"]) {
        
        ActivityDetailViewController *activityVC = [[ActivityDetailViewController alloc]initWithNibName:@"ActivityDetailViewController" bundle:nil];
        [activityVC setDelegate:self];
        activityVC.activityID = notification.notificationTypeID;
        
        NSInteger checkActivityId = [activityVC.activityID intValue];
        
        if (checkActivityId == 0) {
            
            return;
        }
        else{
            
            [self.navigationController pushViewController:activityVC animated:YES];
         }

    }else if ([[Utility getValidString:notification.notificationType] isEqualToString:@"Member"]) {
        ProfileShowViewController *profileVC = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
        profileVC.parentViewControllerName = kTitleNotifications;
        profileVC.otherUserId = [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID];
        
        [self.navigationController pushViewController:profileVC animated:YES];
        
    }else if ([[Utility getValidString:notification.notificationType] isEqualToString:@"MemberQuestion"]) {
        
        QADetailViewController *detail = [[QADetailViewController alloc]initWithNibName:@"QADetailViewController" bundle:nil];
        detail.parentViewControllerName = kTitleNotifications;
        detail.strGetQuestionId = notification.notificationTypeID;
        
        DLog(@"strGetQuestionId %@",detail.strGetQuestionId);
        DLog(@"strGetQuestionId %@",notification.notificationTypeID);
        
        [self.navigationController pushViewController:detail animated:YES];
        
    }else if ([[Utility getValidString:notification.notificationType] isEqualToString:@"Provider"]) {
        ProviderDetailViewController *providerVC = [[ProviderDetailViewController alloc] initWithNibName:@"ProviderDetailViewController" bundle:nil];
        providerVC.providerId = notification.notificationTypeID;
        
        NSInteger checkProviderId = [providerVC.providerId intValue];
        
        DLog(@"ProviderDetail%@",providerVC.providerId);
        DLog(@"notification.notificationTypeID%@",notification.notificationTypeID);
        
    if (checkProviderId == 0) {
           return;
        }
     else{
           [self.navigationController pushViewController:providerVC animated:YES];
          }
        
    }else if ([[Utility getValidString:notification.notificationType] isEqualToString:@"Events"]) {
        MyEventsViewController *eventVC = [[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
        eventVC.parentViewControllerName = kTitleNotifications;
        eventVC.strEventId =  notification.notificationTypeID;
        
        DLog(@"Events %@",eventVC.strEventId);
        DLog(@"Events notification.notificationTypeID: %@",notification.notificationTypeID);
        
        [self.navigationController pushViewController:eventVC animated:YES];
    }
}

- (void)getNotificationsApiCall
{
    DLog(@"%s",__FUNCTION__);
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
    appdel.badgeCount = 0;
    
    NSDictionary *requestParameter = @{
                                        @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
                                               };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_GetNotificationList];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,requestUrl,requestParameter);
    
    [serviceManager executeServiceWithURL:requestUrl andParameters:requestParameter forTask:kTaskGetNotificationList completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s,%@ api \n response:%@",__FUNCTION__,requestUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.notificationsArray = [parsingManager parseResponse:response forTask:task];
              /*  for (Notification *notification in self.notificationsArray) {
                    DLog(@"notificationId:%@ \n userID:%@ \n userName:%@ \n notificationTypeID:%@ \n notificationKey2:%@ \n notificationText:%@ \n notificationTime: %@ \n notificationType: %@, \n notificationKey3:%@, \n notificationKey3ID:%@",notification.notificationId,notification.userID, notification.userName, notification.notificationTypeID, notification.notificationKey2, notification.notificationText, notification.notificationTime, notification.notificationType, notification.notificationKey3, notification.notificationKey3ID);
                }*/
                dispatch_async(dispatch_get_main_queue(),^{
                    [self.tableView reloadData];
                    self.tableView.hidden  = NO;
                    self.notificationLabel.hidden = YES;
                });
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.notificationLabel.hidden = NO;
                self.tableView.hidden  = YES;
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else{
                DLog(@"Error:%@",error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
    }];
    [self.refreshControl endRefreshing];
}

//TODO Remove
-(void)resizeView
{
    //long tableHeight = self.notificationsArray.count * kTableViewCellHieght;
    long tableHeight = 1 * kTableViewCellHieght + 44;
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height =  tableHeight >= 320 ? 320 : tableHeight;
    self.tableView.frame = tableFrame;
    //tableView = self.tableView.frame.size.height;
   
    self.preferredContentSize = CGSizeMake(300, 300);
   // DLog(@"self.tableView.frame: %@ \n ViewFrame:%@",NSStringFromCGRect(self.tableView.frame), NSStringFromCGRect(self.view.frame));
    [self.tableView reloadData];
}

#pragma - NotificationCellDelegateDelegate

- (void)notificationDeletedSuccessfully {
    DLog(@"%s",__FUNCTION__);
    [self getNotificationsApiCall];
}

- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forNotification:(Notification *)notifcation{
    DLog(@"%s",__FUNCTION__);
    if ([hashType isEqualToString:kHotWordHashtag] && [Utility getValidString:hotWorldID].length > 0) {
        ProfileShowViewController *profileVC = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
        profileVC.parentViewControllerName = kTitleNotifications;
        profileVC.otherUserId = hotWorldID;
        if (![hotWorldID isEqualToString:[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]])
            profileVC.profileType =  kProfileTypeOther;
        [self.navigationController pushViewController:profileVC animated:YES];
    } else {
        [self showViewAcccordingToNotification:notifcation];
    }
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma - ActivityDetailViewControllerDelegate

- (void)activtyDeleted {
    [self getNotificationsApiCall];
}

-(void)userLikeActivitySuccessfully
{
}

@end

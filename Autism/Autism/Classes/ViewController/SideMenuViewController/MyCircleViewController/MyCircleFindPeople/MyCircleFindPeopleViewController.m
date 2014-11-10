//
//  MyCircleFindPeopleViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MyCircleFindPeopleViewController.h"
#import "CustomMyPeopleCell.h"
#import "ProfileShowViewController.h"
#import "Utility.h"

@interface MyCircleFindPeopleViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)  NSArray *arrMemberInCircle;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;

@property (strong, nonatomic) IBOutlet UITableView *tableMyPeople;
@end

@implementation MyCircleFindPeopleViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedApiCallNotification:) name:kFindPeopleApiCAllFromProfileViewController object:nil];
    
    
    self.lblNoRecordFound.hidden = YES;
    [self getPeopleInCircle];
    //Set up view for other user
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        self.tableMyPeople.frame = self.view.frame;
        self.navigationController.navigationBarHidden = YES;
        self.tableMyPeople.contentInset = UIEdgeInsetsMake(40, 0, 88, 0); //values passed are - top, left, bottom, right

    } else {
        self.otherMemberId = @"";
        if (!IS_IPHONE_5) {
            self.tableMyPeople.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
        }
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getPeopleInCircle) forControlEvents:UIControlEventValueChanged];
    [self.tableMyPeople addSubview:self.refreshControl];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPeopleInCircle];
    if ([self isMovingToParentViewController])
    {
        DLog(@"isMovingToParentViewController");
    }
    DLog(@"parentViewController:%@",NSStringFromClass([self.parentViewController class]));
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getPeopleInCircle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFindPeopleApiCAllFromProfileViewController object:nil];
}


#pragma mark - Service Manager Methods

- (void)getPeopleInCircle
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if ([self.profileType isEqualToString:kProfileTypeOther] && [Utility getValidString:self.otherMemberId].length < 1) {
        DLog(@"Can not perform %@ api for other user beacuse other member id not exist",WEB_URL_MemberInCircle);
        return;
    }
    
    NSDictionary *memberInCircleParams = @{
                                             @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"other_member_id": [self.profileType isEqualToString:kProfileTypeOther] ? self.otherMemberId : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
                                             };


    NSString *strMemberUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_MemberInCircle];
    DLog(@"%s Performing %@ api \n with parameter :%@",__FUNCTION__,strMemberUrl, memberInCircleParams);

    [serviceManager executeServiceWithURL:strMemberUrl andParameters:memberInCircleParams forTask:kTaskMemberInCircle completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n Response :%@",__FUNCTION__,strMemberUrl, response);

        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            _arrMemberInCircle = [parsingManager parseResponse:response forTask:task];
           
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableMyPeople reloadData];
                });
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                if ([self.profileType isEqualToString:kProfileTypeOther]) {
                    self.arrMemberInCircle = nil;
                     self.lblNoRecordFound.hidden = NO;
                }
                else{
                    self.lblNoRecordFound.hidden = NO;
                    self.lblNoRecordFound.text = @"You haven't added any people yet.";
                 }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableMyPeople reloadData];
                });
            }
         else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
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

#pragma mark -tableview datasource

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrMemberInCircle count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    CustomMyPeopleCell *cell = [self.tableMyPeople dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell =[CustomMyPeopleCell cellFromNibNamed:@"CustomMyPeopleCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configureCell:[_arrMemberInCircle objectAtIndex:[indexPath row]]];
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}


#pragma mark-  tableview delegates

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomMyPeopleCell *cell = (CustomMyPeopleCell *)[self.tableMyPeople cellForRowAtIndexPath:indexPath];
    
    ProfileShowViewController *otherUser = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
    
    otherUser.profileImage = cell.imageURL;
    otherUser.strUserName = cell.userName;
    otherUser.strCity = cell.userCity;
    otherUser.strLocalAuthority = cell.locationAuthority;
    otherUser.otherUserId = cell.userId;
    
    if ([otherUser.otherUserId isEqualToString:[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]])
    {
        otherUser.profileType = @"my";
    }
  else{
        otherUser.profileType = kProfileTypeOther;
     }
   [[appDelegate rootNavigationController] pushViewController:otherUser animated:YES];
}


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    DLog(@"parentViewController:%@",NSStringFromClass([parent class]));

}

#pragma Api Call Notification
- (void)receivedApiCallNotification:(NSNotification *)notification
{
    DLog("Get %@ From Profile View",notification.name);
    if (notification.name) {
   [self getPeopleInCircle];
    }
}

@end

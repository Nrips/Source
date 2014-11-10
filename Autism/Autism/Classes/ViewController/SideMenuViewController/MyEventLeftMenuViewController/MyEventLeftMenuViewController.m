//
//  MyEventLeftMenuViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 5/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MyEventLeftMenuViewController.h"
#import "CustomEventDetailCell.h"
#import "MyEventsViewController.h"
#import "Utility.h"

typedef enum
{
    kAttendEvent,
    kCreatedEvent
}ButtonActionEvent;

@interface MyEventLeftMenuViewController () <MyEventsViewDelegate>

{
    ButtonActionEvent currentActionEvent;
    NSString *attendIdEventString;
    NSString *createdIdEventString;
}

@property (nonatomic,strong) NSArray *eventDetailArray;
@property (nonatomic,strong) NSMutableArray *eventIdFetch;
@property (strong, nonatomic) IBOutlet UIButton *btnAttendEvent;
@property (strong, nonatomic) IBOutlet UIButton *btnCreatedEvent;
@property (strong, nonatomic) IBOutlet UITableView *tableEventDetails;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;


@property (nonatomic,retain) UIRefreshControl *refreshControl;
- (IBAction)myEventShown:(id)sender;

@end

@implementation MyEventLeftMenuViewController

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
    DLog(@"%s",__FUNCTION__);
    
    self.lblNoRecordFound.hidden = YES;

    if (!IS_IPHONE_5) {
               self.tableEventDetails.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
            }

    
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        //TODO Apply better approch
         //*> Navigation Isssue
        //[self updateViewForNotificationScreen];
         self.title = @"Event";
    }
    
    
    
    if ([self.parentViewControllerName isEqualToString:kCallerViewQADetail]||[self.parentViewControllerName isEqualToString:kCallerViewHelpful]||[self.parentViewControllerName isEqualToString:kCallerViewReply]) {
        //TODO Apply better approch
        self.baseImageView.hidden = YES;
        self.btnAttendEvent.hidden =YES;
        self.btnCreatedEvent.hidden = YES;
        self.title = @"Event";
        if (IS_IPHONE_5)
           {
              self.tableEventDetails.frame = CGRectMake(0,63,320,503);
            }
        else{
             self.tableEventDetails.frame = CGRectMake(0,63,320,417);
           }
        //*> Navigation Isssue
        //[self updateViewForNotificationScreen];
    }
else {
    
    //Set up view for other user
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        //createdIdEventString = @"1002";
        self.title = @"Events";
        self.baseImageView.hidden = YES;
        self.btnAttendEvent.hidden =YES;
        self.btnCreatedEvent.hidden = YES;
        if (IS_IPHONE_5) {
            self.tableEventDetails.frame = CGRectMake(0,63,320,503);
           

            }
        else{
              self.tableEventDetails.frame = CGRectMake(0,63,320,417);

             }
        
    } else {
        self.otherMemberId = @"";
        self.title = @"My Events";
        self.lblNoRecordFound.text = @"No Record Found";
    }
    
    }
    
    // Do any additional setup after loading the view.
    self.eventIdFetch = [[NSMutableArray alloc] init];
    self.eventDetailArray = [[NSMutableArray alloc] init];
    
    
//    if (!IS_IPHONE_5) {
//        self.tableEventDetails.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
//    }

    
    UIColor *altcolor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"light-gray-full-bg.fw.png"]];
    [self.tableEventDetails setBackgroundColor:altcolor];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(sendIdGetEventDetails) forControlEvents:UIControlEventValueChanged];
    [self.tableEventDetails addSubview:self.refreshControl];
    
    [self sendIdGetEventDetails];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateViewForNotificationScreen
{
    CGRect frame;
    
    frame = self.baseImageView.frame;
    frame.origin.y -= 64;
    self.baseImageView.frame = frame;
    
    frame = self.lblNoRecordFound.frame;
    frame.origin.y -= 64;
    self.lblNoRecordFound.frame = frame;
    
    frame = self.tableEventDetails.frame;
    frame.origin.y -= 64;
    self.tableEventDetails.frame = frame;
    
    frame = self.btnAttendEvent.frame;
    frame.origin.y -= 64;
    self.btnAttendEvent.frame = frame;
    
    frame = self.btnCreatedEvent.frame;
    frame.origin.y -= 64;
    self.btnCreatedEvent.frame = frame;
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


- (IBAction)myEventShown:(id)sender {
    currentActionEvent = (int)[sender tag];
    switch (currentActionEvent) {
        case kAttendEvent:
            createdIdEventString = @"1001";
            [self.baseImageView setImage:[UIImage imageNamed:@"attending-events.png"]];
            self.lblNoRecordFound.text = @"No Record Found";
            [self sendIdGetEventDetails];
            break;
            case kCreatedEvent:
            createdIdEventString = @"1002";
             [self.baseImageView setImage:[UIImage imageNamed:@"created-events.png"]];
             self.lblNoRecordFound.hidden = YES;
             self.lblNoRecordFound.text = @"You haven't added any events yet.";

             [self sendIdGetEventDetails];
        default:
            break;
    }
}

#pragma mark -Service method

-(void) sendIdGetEventDetails
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if ([self.profileType isEqualToString:kProfileTypeOther] && [Utility getValidString:self.otherMemberId].length < 1) {
        DLog(@"Can not perform %@ for other user beacuse other member id not exist",WEb_URL_GetEventDetail);
        return;
    }
    
    
    NSDictionary *eventDictionary = [NSDictionary new];
    if ([createdIdEventString isEqualToString:@"1002"]|| [self.profileType isEqualToString:kProfileTypeOther]) {
        
        eventDictionary = @{ @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                             @"other_member_id": [self.profileType isEqualToString:kProfileTypeOther] ? self.otherMemberId : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                             @"type" : @"my_event"};
    } else {
        eventDictionary = @{ @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                             @"other_member_id": [self.profileType isEqualToString:kProfileTypeOther] ? self.otherMemberId : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                             @"type" : @"attend_event"};
                  }
    
    NSString *strEventDetail = [NSString stringWithFormat:@"%@%@",BASE_URL,WEb_URL_GetEventDetail] ;
    DLog(@"%s Performing %@ api \n with parameter :%@",__FUNCTION__, strEventDetail, eventDictionary);

    [serviceManager executeServiceWithURL:strEventDetail andParameters:eventDictionary forTask:kTaskGetEventDetails completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n Response :%@",__FUNCTION__, strEventDetail,response);

        if (!error && response) {
            NSDictionary *dict =[NSDictionary new];
            dict = (NSDictionary*)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.eventDetailArray = [parsingManager parseResponse:response forTask:task];
                self.lblNoRecordFound.hidden = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableEventDetails reloadData];
                });
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                
                    if ([self.profileType isEqualToString:kProfileTypeOther]) {
                        self.lblNoRecordFound.hidden = NO;
                        self.lblNoRecordFound.text = @"This member has not created any events yet";
                        self.eventDetailArray = nil;

                    } else {
                        self.lblNoRecordFound.hidden = NO;
                        self.lblNoRecordFound.text = @"No Record Found";
                        self.eventDetailArray = nil;

                    }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableEventDetails reloadData];
                });
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
                }
        }
        else
        {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    [self.refreshControl endRefreshing];
}

#pragma mark -Tableview Datasource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventDetailArray count];
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellEventID = @"cell";
    
    CustomEventDetailCell *cell = [self.tableEventDetails dequeueReusableCellWithIdentifier:cellEventID];
    
    if (!cell) {
        cell = [CustomEventDetailCell cellFromNibNamed:@"CustomEventDetailCell"];
    }
    
    [cell configureCell:[self.eventDetailArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - tableview Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomEventDetailCell *cell = (CustomEventDetailCell *)[self.tableEventDetails cellForRowAtIndexPath:indexPath];
    MyEventsViewController *eventVC = [[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    [eventVC setDelegate:self];
    eventVC.strEventId = cell.eventIdPass;
    eventVC.strLocation = cell.eventLocation;
    [self.navigationController pushViewController:eventVC animated:YES];
}

#pragma mark - MyEventView delegate
- (void)didReloadMyEventView
{
    [self sendIdGetEventDetails];
}

@end

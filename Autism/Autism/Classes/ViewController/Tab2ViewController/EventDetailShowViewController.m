//
//  EventDetailShowViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Neuron Solutions. All rights reserved.
//

#import "EventDetailShowViewController.h"
#import "CustomEventDetailCell.h"
#import "EventsDetail.h"
#import "MyEventsViewController.h"
#import "MFSideMenu.h"
#import "SVPullToRefresh.h"

@interface EventDetailShowViewController ()
{
    BOOL         isInitialPageCount;
    BOOL         isApplyfilter;
    NSInteger    currentPageNumber;
    NSInteger    totalPageCount;
}

@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
@property (nonatomic,strong) NSMutableArray *eventDetailArray;
@property (nonatomic,strong) NSMutableArray *eventIdFetch;
@property (nonatomic,strong) NSString *eventIdPass;
@property (nonatomic,retain) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *dataSource;


@end

@implementation EventDetailShowViewController

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
    DLog(@" ");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    self.eventDetailArray = [NSMutableArray new];
    
    if (!IS_IPHONE_5) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    
    //TODO Check Network Status
   [self sendIdGetEventDetails];
    self.title = @"Event Detail";
    self.eventIdFetch =[[NSMutableArray alloc] init];
    self.eventDetailArray =[[NSMutableArray alloc] init];
    self.eventIdPass =[[NSString alloc] init];
    
    UIColor *altcolor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"light-gray-full-bg.fw.png"]];
   [self.tableView setBackgroundColor:altcolor];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(sendIdGetEventDetails) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    isInitialPageCount = NO;
    __weak EventDetailShowViewController *weakSelf = self;
    
    // *************setup infinite scrolling***********
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma svmethods
- (void)insertRowAtBottom {
    __weak EventDetailShowViewController *weakSelf = self;
    if (currentPageNumber < totalPageCount) {
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.tableView beginUpdates];
            currentPageNumber += 1;
            //[self callFindPeopleService:self.industryId andTopics:self.topicId];
            [self sendIdGetEventDetails];
            
            DLog(@"current page %ld",(long)currentPageNumber);
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            
            [weakSelf.tableView endUpdates];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        });
    }
    else
    {
        DLog(@"No more pages to load");
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
    }
}


#pragma mark -Service method
-(void) sendIdGetEventDetails
{
    NSString *strEventDetail;
    NSDictionary *memberIdDict =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]};
    //NSString *strEventDetail = [NSString stringWithFormat:@"%@%@",BASE_URL,WEb_URL_GetEventDetail];
    
    if (!isInitialPageCount) {
        strEventDetail = [NSString stringWithFormat:@"%@%@",BASE_URL,WEb_URL_GetEventDetail];
        currentPageNumber = 1;
       }
    else
     {
        strEventDetail = [NSString stringWithFormat:@"%@%@/Event_page/%ld",BASE_URL,WEb_URL_GetEventDetail,(long)currentPageNumber];
     }
    
    DLog(@"Performing %@ api \n with Parameter:%@",strEventDetail, memberIdDict);
    [serviceManager executeServiceWithURL:strEventDetail andParameters:memberIdDict forTask:kTaskGetEventDetails completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s Performing %@ api \n response :%@",__FUNCTION__,strEventDetail, response);
        if (!error && response) {
            
            self.dataSource = [parsingManager parseResponse:response forTask:task];
            
            if (!isInitialPageCount) {
                [self.eventDetailArray removeAllObjects];
                [self.eventDetailArray addObjectsFromArray:self.dataSource];
            }
            else
            {
                [self.eventDetailArray addObjectsFromArray:self.dataSource];
            }
            DLog(@"DataSource ...... %@",self.dataSource);

            
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.lblNoRecordFound.hidden = YES;
                        isInitialPageCount = YES;
                        totalPageCount = [[response objectForKey:@"total_pages"] integerValue];
                        [self.tableView reloadData];
                  });
                }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                     [appDelegate userAutismSessionExpire];
                   }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                    self.eventDetailArray = nil;
                    self.lblNoRecordFound.hidden = NO;
               dispatch_async(dispatch_get_main_queue(), ^{
                        if (!isInitialPageCount) {
                            [self.tableView reloadData];
                           }
                        else if (isApplyfilter)
                        {
                            [self.tableView reloadData];
                        }
                    });
                 }
            else{
                    DLog(@"%s Error:%@",__FUNCTION__,error);
                    [appDelegate showSomeThingWentWrongAlert:@""];
                }
        }
    }];
 [self.refreshControl endRefreshing];
}

#pragma mark -Tableview Datasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.eventDetailArray count];
    
    //return 8;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellEventID = @"cell";
    
    CustomEventDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellEventID];
    
    if (!cell) {
        
        cell = [CustomEventDetailCell cellFromNibNamed:@"CustomEventDetailCell"];
    }
    
    [cell configureCell:[self.eventDetailArray objectAtIndex:indexPath.row]];
    //self.eventIdPass = cell.stringID;
    
    return cell;
}

#pragma mark - tableview Delegates

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomEventDetailCell *cell = (CustomEventDetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    MyEventsViewController *eventVC = [[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    
    eventVC.strEventId = cell.eventIdPass;
    eventVC.strLocation = cell.eventLocation;
    
    [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
    [[appDelegate rootNavigationController] pushViewController:eventVC animated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

@end

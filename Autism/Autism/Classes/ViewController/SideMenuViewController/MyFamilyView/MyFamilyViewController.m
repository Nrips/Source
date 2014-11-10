//
//  MyFamilyViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/13/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "MyFamilyViewController.h"
#import "FamilyListCell.h"
#import "ReportToAWMView.h"
#import "Utility.h"
#import "AddMemberViewController.h"


@interface MyFamilyViewController () <ReportToAWMViewDelegate, FamilyListCellDelegate>
@property (nonatomic, strong) ReportToAWMView *reportToAWMView;

@property (strong, nonatomic) IBOutlet UITableView *myFamilyTable;
@property (strong, nonatomic) NSArray *memberInFamilyArray;
@property (weak, nonatomic) IBOutlet UIButton *addFamilyButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
- (IBAction)addFamilyAction:(id)sender;

@end

@implementation MyFamilyViewController

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
    //Set up view for other user
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        self.title = @"Family";
        self.addFamilyButton.hidden = YES;
        self.myFamilyTable.frame = self.view.frame;
    } else {
        self.otherMemberId = @"";
        self.title = @"My Family";
        self.addFamilyButton.hidden = NO;
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getFamilyList) forControlEvents:UIControlEventValueChanged];
    [self.myFamilyTable addSubview:self.refreshControl];
    
    if (!IS_IPHONE_5) {
        self.myFamilyTable.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    // Do any additional setup after loading the view.
    [self getFamilyList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getFamilyList];
    self.lblNoRecordFound.hidden = YES;
    
}

- (IBAction)addFamilyAction:(id)sender {
    AddMemberViewController *addFamilyVc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddMemberViewController"];
    [self.navigationController pushViewController:addFamilyVc animated:YES];
}

#pragma mark ReportToAWMViewMethods

- (void)reportToAWMMemeberId:(NSString*)memberId
{
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y - 150;
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:frame];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeFamily;
    self.reportToAWMView.selectedQuestionId = memberId;
    [self.view addSubview:self.reportToAWMView];
}

- (void)reportToAWMVDSuccessfullySubmitted {
    [self.reportToAWMView removeFromSuperview];
    [self getFamilyList];
}

#pragma mark - Service Methods

- (void)getFamilyList
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if ([self.profileType isEqualToString:kProfileTypeOther] && [Utility getValidString:self.otherMemberId].length < 1) {
        DLog(@"Can not perform %@ for other user beacuse other member id not exist",Web_Url_GetFamilyList);
        return;
    }
    
    NSDictionary *getFamilyListParameter = @{
                                            @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"other_member_id": [self.profileType isEqualToString:kProfileTypeOther] ?self.otherMemberId : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
                                           };
    NSString *getFamilyListUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_Url_GetFamilyList];
    
    DLog(@"%s Performing %@ Api \n with Parameter:%@",__FUNCTION__,getFamilyListUrl, getFamilyListParameter);
    
    [serviceManager executeServiceWithURL:getFamilyListUrl andParameters:getFamilyListParameter forTask:kTaskGetFamilyList completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api Familyresponse:%@",__FUNCTION__,getFamilyListUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
           
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                DLog(@"%s %@ Api Familyresponse:%@",__FUNCTION__,getFamilyListUrl, response);
                
                self.lblNoRecordFound.hidden = YES;
                self.memberInFamilyArray = [parsingManager parseResponse:response forTask:task];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.myFamilyTable reloadData];
                });
            } if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                
                if ([self.profileType isEqualToString:kProfileTypeOther]) {
                    
                    self.lblNoRecordFound.hidden = NO;
                    self.memberInFamilyArray = nil;
                    
                 }
                else {
                     self.memberInFamilyArray = nil;
                    self.lblNoRecordFound.hidden = NO;
                    self.lblNoRecordFound.text = @"No Record Found";
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.myFamilyTable reloadData];
                });
            } else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
                
            }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
                [appDelegate userAutismSessionExpire];
            }
        }
        else{
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];
    [self.refreshControl endRefreshing];
}



# pragma mark -TableViewDataSource and Delegates

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.memberInFamilyArray count];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId =@"cell";
    
    FamilyListCell *cell = [self.myFamilyTable dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [FamilyListCell cellFromNibNamed:@"FamilyListCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.delegate = self;
    cell.profileType = self.profileType;
    cell.otherMemberId = self.otherMemberId;
    [cell configureCell:[self.memberInFamilyArray objectAtIndex:indexPath.row]];
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark- memberinfamily delegate methods
- (void)reloadTableDataAfterDeletion
{
    [self getFamilyList];
}


@end

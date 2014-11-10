//
//  FindPeopleViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/24/14.


#import "FindPeopleViewController.h"
#import "PersonInFinder.h"
#import "CustomTextField.h"
#import "CustomLabel.h"
#import "CustomPeopleView.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "MyStoryViewController.h"
#import "ProfileShowViewController.h"
#import "OtherLocalAuthorityViewController.h"
#import "Utility.h"
#import "FindPeopleHeaderView.h"
#import "SVPullToRefresh.h"

@interface FindPeopleViewController ()
<UIPickerViewDataSource,UIPickerViewDelegate,OtherLocalDelegate,FindPeopleHeaderViewDelegate>
{
    CustomTextField *txtLocalArea;
    CustomTextField *txtemail;
    CustomTextField *txtName;
    CustomTextField *txtCity;
    
    BOOL         isInitialPageCount;
    BOOL         isApplyfilter;
    NSInteger    currentPageNumber;
    NSInteger    totalPageCount;
}

@property (nonatomic, strong) NSMutableArray *localAuthorityArray;
@property (nonatomic, strong) NSDictionary *otherLocalAuthoritydic;

@property (nonatomic, strong) NSMutableArray *personInFinderArray;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) NSString *localAuthority;
@property(nonatomic, strong) UITextField *activeTextField;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSString *strName;
@property (nonatomic, strong) NSString *strEmail;
@property (nonatomic, strong) NSString *strLocalAuthority;
@property (nonatomic, strong) NSString *strCity;
@property (strong, nonatomic) NSMutableArray *dataSource;




@property(nonatomic,strong)FindPeopleHeaderView *findVc;

@end

@implementation FindPeopleViewController

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
    
    self.personInFinderArray = [NSMutableArray new];

    //Add Observer for reciveing Notification when user tapped on menu button
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedHideKeyboardNotification:) name:kHideKeyboardFromFindPeopleViewController object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedApiCallNotification:) name:kFindPeopleApiCAllFromProfileViewController object:nil];
    
    //[self setupFeildsPeople];
      [self setupPicker];
    

     //self.findVc = [[FindPeopleHeaderView alloc]init];
    self.localAuthority = [[NSString alloc]init];
    
    self.lblNoRecordFound.hidden = YES;
    
    if (!IS_IPHONE_5) {
        self.tableShowPeople.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
     }
    
    [self getLocalAuthorityData];
    [self searchAction];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventValueChanged];
    [self.tableShowPeople addSubview:self.refreshControl];

    [txtLocalArea setText:kTitleSelect];
    
    isInitialPageCount = NO;
    __weak FindPeopleViewController *weakSelf = self;
    
    // *************setup infinite scrolling***********
    [self.tableShowPeople addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self searchAction];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self searchAction];
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self resignFirstResponders];
}


-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideKeyboardFromFindPeopleViewController object:nil];
    
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kFindPeopleApiCAllFromProfileViewController object:nil];
}

#pragma svmethods
- (void)insertRowAtBottom {
    __weak FindPeopleViewController *weakSelf = self;
    if (currentPageNumber < totalPageCount) {
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.tableShowPeople beginUpdates];
            currentPageNumber += 1;
            [self searchAction];
            DLog(@"current page %ld",(long)currentPageNumber);
            [weakSelf.tableShowPeople reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            
            [weakSelf.tableShowPeople endUpdates];
            [weakSelf.tableShowPeople.infiniteScrollingView stopAnimating];
        });
    }
    else
    {
        DLog(@"No more pages to load");
        [weakSelf.tableShowPeople.infiniteScrollingView stopAnimating];
    }
}





-(void) setupFeildsPeople
{
    //[self.view sendSubviewToBack:_imag];
    
    //    self.baseImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    //    [self.baseImageView setImage:[UIImage imageNamed:@"findproviders-findpeoples.png"]];
    //    [_imag addSubview:self.baseImageView];
    
    
    
   CustomLabel *nameLabel =[[CustomLabel alloc] initWithFrame:CGRectMake(5, 33, 140, 21)];
    nameLabel.text =@"Name";
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor colorWithRed: 64/255.0 green:0/255.0 blue:128/255.0 alpha:1.0];
    

    [_imag addSubview:nameLabel];
    
    txtName = [[CustomTextField alloc] initWithFrame:CGRectMake(5, 120, 140, 30)];

    [self.view addSubview:txtName];
    

    CustomLabel *emailLabel =[[CustomLabel alloc] initWithFrame:CGRectMake(170, 33, 140, 21)];
    emailLabel.text = @"Email";
    emailLabel.font = [UIFont systemFontOfSize:15];
    emailLabel.textColor = [UIColor colorWithRed: 64/255.0 green:0/255.0 blue:128/255.0 alpha:1.0];
    [_imag addSubview:emailLabel];
    
    txtemail =[[CustomTextField alloc] initWithFrame:CGRectMake(170, 120, 140, 30)];
    [self.view addSubview:txtemail];
    
    
    CustomLabel *cityLabel =[[CustomLabel alloc] initWithFrame:CGRectMake(5, 96, 140, 21)];
    cityLabel.font = [UIFont systemFontOfSize:15];
    cityLabel.textColor = [UIColor colorWithRed: 64/255.0 green:0/255.0 blue:128/255.0 alpha:1.0];
    cityLabel.text =@"Town or City";
    [_imag addSubview:cityLabel];
    
    txtCity =[[CustomTextField alloc] initWithFrame:CGRectMake(5, 183, 140, 30)];
    [self.view addSubview:txtCity];
    
    
    
    CustomLabel *localAreaLabel =[[CustomLabel alloc] initWithFrame:CGRectMake(170, 96, 140, 21)];
    localAreaLabel.font = [UIFont systemFontOfSize:15];
    localAreaLabel.textColor = [UIColor colorWithRed: 64/255.0 green:0/255.0 blue:128/255.0 alpha:1.0];
    localAreaLabel.text = @"Local Authority";
    [_imag addSubview:localAreaLabel];
    
    txtLocalArea =[[CustomTextField alloc] initWithFrame:CGRectMake(170, 183, 140, 30)];
    txtLocalArea.userInteractionEnabled = NO;
    [self.view addSubview:txtLocalArea];
    
    UIButton *btnLocalAuth =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnLocalAuth setFrame:CGRectMake(291, 191,15 , 12)];
    UIImage *localAuthImage = [UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnLocalAuth setBackgroundImage:localAuthImage forState:UIControlStateNormal];
    //[btnLocalAuth addTarget:self action:@selector(showLocalAuthorityPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLocalAuth];
    
    UIButton *containerBtnLocalAuth =[UIButton buttonWithType:UIButtonTypeCustom];
    [containerBtnLocalAuth setFrame:CGRectMake(173, 188,133 , 30)];
    
    [containerBtnLocalAuth addTarget:self action:@selector(showLocalAuthorityPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:containerBtnLocalAuth];

    
    
    UIButton *btnSearch =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setFrame:CGRectMake(10, 230,300 , 35)];
    UIImage *searchImage = [UIImage imageNamed:@"big-signin-blank.fw.png"];
    [btnSearch setBackgroundImage:searchImage forState:UIControlStateNormal];
    [btnSearch setTitle:@"Search" forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSearch];
    
    
    self.baseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216+44)];
    UIToolbar *topBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 44)];
    UIBarButtonItem *dontBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneAction:)];
    dontBtn.tintColor = appUIGreenColor;
    topBar.items = [NSArray arrayWithObject:dontBtn];
    [self.baseView addSubview:topBar];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 216)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.baseView addSubview:self.pickerView];
    [self.view addSubview:self.baseView];
}

-(void)setupPicker
{
    self.baseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216+44)];
    UIToolbar *topBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 44)];
    UIBarButtonItem *dontBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneAction:)];
    dontBtn.tintColor = appUIGreenColor;
    topBar.items = [NSArray arrayWithObject:dontBtn];
    [self.baseView addSubview:topBar];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 216)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.baseView addSubview:self.pickerView];
    [self.view addSubview:self.baseView];

}


- (void)showLocalAuthorityPicker
{
    [self showPicker];
    
}

-(void)showPickerOnClick
{
    [self showPicker];
}

-(void) showPicker {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height - self.baseView.frame.size.height, self.baseView.frame.size.width, self.baseView.frame.size.height)];
        
    }];
    [self.pickerView reloadAllComponents];
}

-(void) hidePicker {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216+44)];
    }];
}

-(void)pickerDoneAction:(id)sender {
    if ( [txtLocalArea.text isEqualToString:@""]) {
        txtLocalArea.text = (self.localAuthorityArray.count > 0) ?  [self.localAuthorityArray firstObject] : @"";
    }
   
    [self hidePicker];
    
}

#pragma mark- Service methods
- (void)searchAction
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    //TODO add Conditons and status code
    NSString *localAuthorityArea = @"";
    if (![[Utility getValidString:txtLocalArea.text] isEqualToString:kTitleSelect]) {
        localAuthorityArea = [Utility getValidString:txtLocalArea.text];
    }
    NSString *strSearchUrl;
    NSDictionary *searchParams =@{
                                      @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                      @"memberName": @"",
                                      @"memberEmail":@"",
                                      @"memberCity": @"",
                                      @"memberAuthority":@"",
                                      
                                      };
    
    //NSString *strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetAndSearchPeople];
    
    if (!isInitialPageCount) {
        strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetAndSearchPeople];
        currentPageNumber = 1;
    }
    else
    {
        strSearchUrl = [NSString stringWithFormat:@"%@%@/Member_page/%ld",BASE_URL,WEB_URL_GetAndSearchPeople,(long)currentPageNumber];
    }
    
    
    //DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,strSearchUrl, searchParams);
    [serviceManager executeServiceWithURL:strSearchUrl andParameters:searchParams forTask:kTaskGetSearchPeople completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n Response:%@",__FUNCTION__,strSearchUrl,response);
        
        if (!error && response) {
            
            self.dataSource = [parsingManager parseResponse:response forTask:task];
            
            if (!isInitialPageCount) {
                [self.personInFinderArray removeAllObjects];
                [self.personInFinderArray addObjectsFromArray:self.dataSource];
            }
            else
            {
                [self.personInFinderArray addObjectsFromArray:self.dataSource];
            }
            DLog(@"DataSource ...... %@",self.dataSource);
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.lblNoRecordFound.hidden = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    isInitialPageCount = YES;
                    totalPageCount = [[response objectForKey:@"total_pages"] integerValue];
                    [self.tableShowPeople reloadData];
                    
                });
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.lblNoRecordFound.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.personInFinderArray = nil;
                    [self.tableShowPeople reloadData];
                });
            }else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
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


-(void)clickOnSearchButton:(NSString *)nameString emailString:(NSString *)email cityString:(NSString *)city localAuthorityString:(NSString *)localAuthority
{
    self.strCity           = city;
    self.strEmail          = email;
    self.strLocalAuthority = localAuthority;
    self.strName           = nameString;
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    //TODO add Conditons and status code
    NSString *localAuthorityArea = @"";
    if (![[Utility getValidString:txtLocalArea.text] isEqualToString:kTitleSelect]) {
        localAuthorityArea = [Utility getValidString:txtLocalArea.text];
    }
    
    NSDictionary *searchParams =@{
                                  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"memberName": nameString,
                                  @"memberEmail": email,
                                  @"memberCity": city,
                                  @"memberAuthority":localAuthority,
                                  };
    
    NSString *strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetAndSearchPeople];
    
    //DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,strSearchUrl, searchParams);
    [serviceManager executeServiceWithURL:strSearchUrl andParameters:searchParams forTask:kTaskGetSearchPeople completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n Response:%@",__FUNCTION__,strSearchUrl,response);
        
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.lblNoRecordFound.hidden = YES;
                self.personInFinderArray = [parsingManager parseResponse:response forTask:task];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableShowPeople reloadData];
                });
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.lblNoRecordFound.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.personInFinderArray = nil;
                    [self.tableShowPeople reloadData];
                });
    
   /* NSString *strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetAndSearchPeople];
    
    if (!isInitialPageCount) {
        strSearchUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetAndSearchPeople];
        currentPageNumber = 1;
    }
    else
    {
        strSearchUrl = [NSString stringWithFormat:@"%@%@/page/%ld",BASE_URL,WEB_URL_GetAndSearchPeople,(long)currentPageNumber];
    }
    
    
    //DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,strSearchUrl, searchParams);
    [serviceManager executeServiceWithURL:strSearchUrl andParameters:searchParams forTask:kTaskGetSearchPeople completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n Response:%@",__FUNCTION__,strSearchUrl,response);
        
        if (!error && response) {
            
            self.dataSource = [parsingManager parseResponse:response forTask:task];
            
            if (!isInitialPageCount) {
                [self.personInFinderArray removeAllObjects];
                [self.personInFinderArray addObjectsFromArray:self.dataSource];
            }
            else
            {
                [self.personInFinderArray addObjectsFromArray:self.dataSource];
            }
            DLog(@"DataSource ...... %@",self.dataSource);
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.lblNoRecordFound.hidden = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    isInitialPageCount = YES;
                    totalPageCount = [[response objectForKey:@"total_pages"] integerValue];
                    [self.tableShowPeople reloadData];
                    
                });
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.lblNoRecordFound.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.personInFinderArray = nil;
                    [self.tableShowPeople reloadData];
                });*/

            }else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
                
            }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
                [appDelegate userAutismSessionExpire];
            }
        }
        else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:@""];
        }
    }];
}



- (void)getLocalAuthorityData {
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_LocalAuthority];
    //DLog(@"%s Performing :%@ Api",__FUNCTION__,strUrl);

    [serviceManager executeServiceWithURL:strUrl forTask:kTaskGetLocalAuthority completionHandler:^(id response, NSError *error, TaskType task) {
        //DLog(@"%s Performing :%@ Api \n with Response : %@",__FUNCTION__,strUrl,response);
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.localAuthorityArray = [[NSMutableArray alloc]init];
                NSArray *array = [parsedData valueForKey:@"data"];
                
                self.localAuthorityArray  = [[NSMutableArray alloc] initWithCapacity:array.count+1];
                for (NSDictionary *localAuthDic in array) {
                    [self.localAuthorityArray addObject:[localAuthDic valueForKey:@"mla_name"]];
                }
                
                self.localAuthorityArray = [NSMutableArray arrayWithArray:self.localAuthorityArray];
                [self.localAuthorityArray insertObject:kTitleSelect atIndex:0];
                [txtLocalArea setText:[self.localAuthorityArray objectAtIndex:0]];

                [self.localAuthorityArray addObject:@"Others"];
                [self.pickerView reloadAllComponents];
                
                [self getOtherLocalAuthorityData];

            });
        }
    }];
}

-(void)getOtherLocalAuthorityData {
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *strOtherLocalAuthcity = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_OtherLocalAuthority];
    //DLog(@"%s %@ Api ",__FUNCTION__,strOtherLocalAuthcity);
    [serviceManager executeServiceWithURL:strOtherLocalAuthcity forTask:kTaskGetOtherLocalAuthority completionHandler:^(id response, NSError *error, TaskType task) {
        //DLog(@"%s Performing :%@ Api \n with Response : %@",__FUNCTION__,strOtherLocalAuthcity,response);
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.otherLocalAuthoritydic = parsedData;
            });
        }
    }];
}




#pragma mark - tableview datasource

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger ) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.personInFinderArray count];
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId =@"cell";
    
    CustomPeopleView *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [CustomPeopleView cellFromNibNamed:@"CustomPeopleView"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell configureCell:[self.personInFinderArray objectAtIndex:indexPath.row]];
    
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}


#pragma mark -UITableview delegates

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomPeopleView *cell = (CustomPeopleView *)[self.tableShowPeople cellForRowAtIndexPath:indexPath];
    
    ProfileShowViewController *profileVC = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
    
     profileVC.profileImage = cell.imageURL;
     profileVC.strUserName = cell.userName;
     profileVC.strCity = cell.userCity;
     profileVC.strLocalAuthority = cell.locationAuthority;
     profileVC.otherUserId = cell.userId;
     profileVC.profileType = kProfileTypeOther;
     profileVC.parentViewControllerName = kCallerViewFindPeople;
     profileVC.isMemberAlreadyCircle = cell.isCheckIncircle;
     profileVC.isMemeberBlocked = cell.isMemeberBlocked;

    [[appDelegate rootNavigationController] pushViewController:profileVC animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 173.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    self.findVc = [[FindPeopleHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 173)];
    self.findVc.delegate = self;
    
    self.findVc.txtCity.text           = self.strCity;
    self.findVc.txtMail.text           = self.strEmail;
    self.findVc.txtName.text           = self.strName;
    
    if (self.strLocalAuthority == nil || [self.strLocalAuthority isKindOfClass:[NSNull class]])
         self.findVc.txtLocalAuthority.text = kTitleSelect;
    else
         self.findVc.txtLocalAuthority.text = self.strLocalAuthority;
    
    return self.findVc;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
        return [self.localAuthorityArray count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.localAuthorityArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
        if (row == [self.localAuthorityArray count]-1) {
            [self hidePicker];
            OtherLocalAuthorityViewController *otherAuthVc = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherLocalAuthorityViewController"];
            [otherAuthVc setDelegate:self];
            [otherAuthVc setSelectedTitle:txtLocalArea.text];
            [otherAuthVc setDictionary:self.otherLocalAuthoritydic];
            
            UINavigationController *nav = [[UINavigationController alloc]
                                           
                                           initWithRootViewController:otherAuthVc];

            [[appDelegate rootNavigationController] presentViewController:nav animated:YES completion:^{}];
            
        }
        else {
            [txtLocalArea setText:[self.localAuthorityArray objectAtIndex:row]];
            
          //[cell setValueInLocalAuthority:[self.localAuthorityArray objectAtIndex:row]];

            self.localAuthority  =  [self.localAuthorityArray objectAtIndex:row];
            [self.findVc setLocalAuthorityValue:self.localAuthority];

        }
    
}


#pragma mark - OtherLocalDelegate

-(void)didSelectedLocalAuthority:(NSString *)localAuthority {
    
    [txtLocalArea setText:localAuthority];
    self.localAuthority = localAuthority;
    [self.findVc setLocalAuthorityValue:self.localAuthority];
}


#pragma mark - TextFeild Delegates
-(void)assignActiveTextField:(UITextField*) textField
{
    self.activeTextField = textField;
}

-(void)tappedOnView:(id)sender
{
    [self.view endEditing:YES];
    [self resignFirstResponders];
}

#pragma mark - HideKeyboardNotification

- (void)receivedHideKeyboardNotification:(NSNotification *)notification
{
    DLog("Get %@ From RootVC",notification.name);
    if (notification.name) {
        [self resignFirstResponders];
    }
}

-(void)resignFirstResponders
{
    if ([self.activeTextField isFirstResponder]) {
        [self.activeTextField resignFirstResponder];
    }
}

- (void)receivedApiCallNotification:(NSNotification *)notification
{
    DLog("Get %@ From Profile View",notification.name);
    if (notification.name) {
        [self searchAction];
    }
}

@end

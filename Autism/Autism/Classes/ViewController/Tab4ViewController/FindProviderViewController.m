//
//  FindProviderViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/24/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "FindProviderViewController.h"
#import "FindProviderCell.h"
#import "OtherLocalAuthorityViewController.h"
#import "Utility.h"
#import "ProviderDetailViewController.h"
#import "ServiceViewController.h"
#import "FindProvider.h"

typedef enum {
    PickerServiceCategory,
    PickerLocalAuthority
    
}Picker;

@interface FindProviderViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,OtherLocalDelegate,UITextFieldDelegate>
{
    Picker currentPicker;
    BOOL isCheckProvider;
    NSString *categoryIdString;
    float providerLabelHeight;
    float rowHeight;
}

@property (weak, nonatomic) IBOutlet UITableView *findProviderTableView;
@property (nonatomic, strong) NSMutableArray *personInFinderArray;
@property(nonatomic,strong) NSMutableArray* arrCategory;
@property(nonatomic,strong) NSMutableArray *arrCategoryID;
@property (nonatomic,strong) NSMutableArray *localAuthorityArray;
@property (nonatomic,strong) NSDictionary *otherLocalAuthoritydic;
@property(nonatomic,strong) NSMutableArray *arrProviderName;
@property(nonatomic,strong) NSArray *arrProviderService;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
@property (strong ,nonatomic) UIFont* providerFont;


@property(nonatomic,strong) NSMutableArray* arrAllCategory;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITextField *activeTextField;

@end

@implementation FindProviderViewController

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
    DLog(@"");

    //Add Observer for reciveing Notification when user tapped on menu button
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedHideKeyboardNotification:) name:kHideKeyboardFromFindProviderViewController object:nil];
    
    if (IS_IPHONE_5) {
        CGRect frame = self.findProviderTableView.frame;
        frame.size.height +=88;
        self.findProviderTableView.frame = frame;
    }

    self.title = @"Find Providers";

    self.providerFont = [UIFont systemFontOfSize:13];
    self.lblNoRecordFound.hidden = YES;
    self.txtProviderName.text = self.providerNameString;
    self.txtServiceCategory.text = self.serviceCategoryString;
    categoryIdString = self.serviceCategoryId;
    [self getProviderData];
    [self getOtherLocalAuthorityData];
    [self setupPicker];
    [self getLocalAuthorityData];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getProviderData) forControlEvents:UIControlEventValueChanged];
    [self.findProviderTableView addSubview:self.refreshControl];

  
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];

    

    self.txtCityorTown.delegate = self;
    self.txtLocalAuthorityArea.delegate = self;
    self.txtProviderName.delegate = self;
    self.txtServiceCategory.delegate = self;
    
    [self.txtLocalAuthorityArea setText:kTitleSelect];
    [self.txtServiceCategory setText:kTitleSelect];
    
    
     //For set ProviderName and ServiceCategory from MyCircleFindprovider
    if ([self.parentViewType isEqualToString:kCallerMyCircleProvider]) {
        
        self.txtProviderName.text = self.providerNameString;
        self.txtServiceCategory.text = self.serviceCategoryString;
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self resignFirstResponders];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideKeyboardFromFindProviderViewController object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:[FindProviderViewController class] name:kHideKeyboardFromFindProviderViewController object:nil];
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


- (void) showPicker {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height - self.baseView.frame.size.height, self.baseView.frame.size.width, self.baseView.frame.size.height)];
        
    }];
    [self.pickerView reloadAllComponents];
}

- (void) hidePicker {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.baseView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216+44)];
    }];
}

- (void)pickerDoneAction:(id)sender
{
    if (currentPicker == PickerServiceCategory && [self.txtServiceCategory.text isEqualToString:@""]) {
        self.txtServiceCategory.text = (self.arrCategory.count > 0) ?  [self.arrCategory firstObject] : @"";
        categoryIdString = (self.arrCategoryID.count > 0) ?  [self.arrCategoryID firstObject] : @"";
    }
    else if (currentPicker == PickerLocalAuthority && [self.txtLocalAuthorityArea.text isEqualToString:@""]){
        self.txtLocalAuthorityArea.text = (self.localAuthorityArray.count > 0) ?  [self.localAuthorityArray firstObject] : @"";
    }
    [self hidePicker];
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (currentPicker == PickerServiceCategory) {
      return [self.arrCategory count];
    }
    else {
        return [self.localAuthorityArray count];
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (currentPicker == PickerServiceCategory) {
        return [self.arrCategory objectAtIndex:row];
    }
    else {
        return [self.localAuthorityArray objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (currentPicker == PickerServiceCategory) {
        
        [self.txtServiceCategory setText:[self.arrCategory objectAtIndex:row]];
        categoryIdString = [self.arrCategoryID objectAtIndex:row];

    }
    else {
        if (row == [self.localAuthorityArray count]-1) {
            [self hidePicker];
            OtherLocalAuthorityViewController *otherAuthVc = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherLocalAuthorityViewController"];
            [otherAuthVc setDelegate:self];
            [otherAuthVc setSelectedTitle:self.txtLocalAuthorityArea.text];
            [otherAuthVc setDictionary:self.otherLocalAuthoritydic];
            UINavigationController *nav = [[UINavigationController alloc]
                                           
                                           initWithRootViewController:otherAuthVc];

            
            [[appDelegate rootNavigationController] presentViewController:nav animated:YES completion:^{}];
        }
        else {
            [self.txtLocalAuthorityArea setText:[self.localAuthorityArray objectAtIndex:row]];
        }
    }
}


- (void)didSelectedLocalAuthority:(NSString *)localAuthority {
    
    [self.txtLocalAuthorityArea setText:localAuthority];
}

#pragma mark - service methods
- (void)getLocalAuthorityData {
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }

    NSString *strUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_LocalAuthority];
    DLog(@"%s Performing :%@ Api",__FUNCTION__,strUrl);

    [serviceManager executeServiceWithURL:strUrl forTask:kTaskGetLocalAuthority completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ Api \n response:%@",__FUNCTION__,strUrl, response);
        if (!error && response) {
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
                [self.localAuthorityArray addObject:@"Others"];
                [self.txtLocalAuthorityArea setText:[self.localAuthorityArray objectAtIndex:0]];
                [self.pickerView reloadAllComponents];
                [self getServicecategory];
               
            });
        }
    }];
}

- (void)getOtherLocalAuthorityData {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *strOtherLocalAuthcity = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_OtherLocalAuthority];
    DLog(@"%s Performing :%@ Api",__FUNCTION__,strOtherLocalAuthcity);
    [serviceManager executeServiceWithURL:strOtherLocalAuthcity forTask:kTaskGetOtherLocalAuthority completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ Api \n response:%@",__FUNCTION__,strOtherLocalAuthcity, response);
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.otherLocalAuthoritydic = parsedData;
                
            });
        }
    }];
}

-(void)getServicecategory {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *serviceCategoryUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ServiceProviderCategory];
    DLog(@"%s Performing :%@ Api",__FUNCTION__,serviceCategoryUrl);
    [serviceManager executeServiceWithURL:serviceCategoryUrl forTask:kTaskProviderCategory completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api \n response:%@",__FUNCTION__,serviceCategoryUrl, response);
        
        if (!error && response) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            NSMutableArray *catArray = [[parsedData objectForKey:@"data"] valueForKey:@"sc_name"];
            NSMutableArray *catIdArray = [[parsedData objectForKey:@"data"] valueForKey:@"sc_id"];
            self.arrCategory =  [[NSMutableArray alloc] initWithCapacity:catArray.count+1];
            self.arrCategoryID =  [[NSMutableArray alloc] initWithCapacity:catIdArray.count+1];
            self.arrCategory = [NSMutableArray arrayWithArray:catArray];
            self.arrCategoryID = [NSMutableArray arrayWithArray:catIdArray];;
            [self.arrCategory insertObject:kTitleSelect atIndex:0];
            [self.arrCategoryID insertObject:@"" atIndex:0];
            [self.txtServiceCategory setText:[self.arrCategory objectAtIndex:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.pickerView reloadAllComponents];
                
                //For set ProviderName and ServiceCategory from MyCircleFindprovider
                
                if ([self.parentViewType isEqualToString:kCallerMyCircleProvider]) {
                    
                    self.txtProviderName.text = self.providerNameString;
                    self.txtServiceCategory.text = self.serviceCategoryString;
                }

            });
        }
    }];
 }



- (void)getProviderData
{
    
    NSString *localAuthorityArea = @"";
    if (![[Utility getValidString:self.txtLocalAuthorityArea.text] isEqualToString:kTitleSelect]) {
        localAuthorityArea = [Utility getValidString:self.txtLocalAuthorityArea.text];
    }
   NSDictionary *findProviderParameter =@{
                                            @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"keywordProvider": [Utility getValidString:self.txtProviderName.text].length > 0 ? [Utility getValidString:self.txtProviderName.text] : @"" ,
                                            @"keywordCity":[Utility getValidString:self.txtCityorTown.text].length > 0 ? [Utility getValidString:self.txtCityorTown.text] : @"",
                                            @"localAuthorityProvider": localAuthorityArea,
                                            @"categoryProvider":[Utility getValidString:categoryIdString].length > 0 ? [Utility getValidString:categoryIdString] : @"",
                                            @"providerCheck": [NSString stringWithFormat:@"%d",isCheckProvider],
                                            
                                            };
    NSString *findProviderUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_FindProvider];
    DLog(@"%s Performing %@ Api \n with Parameter:%@",__FUNCTION__,findProviderUrl, findProviderParameter);
    
    [serviceManager executeServiceWithURL:findProviderUrl andParameters:findProviderParameter forTask:kTaskFindProvider completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api response:%@",__FUNCTION__,findProviderUrl, response);

        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
             DLog(@"Response of Findprovider:%@",response);
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.lblNoRecordFound.hidden = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.personInFinderArray = [parsingManager parseResponse:response forTask:task];
                    [self.findProviderTableView reloadData];
                                    });
            }if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.lblNoRecordFound.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.personInFinderArray = nil;
                    [self.findProviderTableView reloadData];
                });
            }else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            
            }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
               
                [appDelegate userAutismSessionExpire];
            }
        }
        
        else{
            
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:@""];
         }
        
      }];
    [self.refreshControl endRefreshing];
}

#pragma mark - tableview datasource


- (NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.personInFinderArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.personInFinderArray objectAtIndex:section]) {
        FindProvider *provider = [self.personInFinderArray objectAtIndex:section];
        return provider.providerServices.count;
    } else {
        return 0;
    }
    
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId =@"cell";
    
   FindProviderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [FindProviderCell cellFromNibNamed:@"FindProviderCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configureCellAtIndexPath:indexPath :[self.personInFinderArray objectAtIndex:indexPath.section]];
    cell.lblCategory.backgroundColor = [UIColor colorWithRed:170/255.0f green:36/255.0f blue:137/255.0f alpha:1.0f];
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
   FindProviderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    if (cell == nil) {
        cell = [FindProviderCell cellFromNibNamed:@"FindProviderCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell configureHeader:[self.personInFinderArray objectAtIndex:section]];
    return  cell;
    
}


-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    FindProvider *provider  = [self.personInFinderArray objectAtIndex:[indexPath section]];
    providerLabelHeight = [self calculateMessageStringHeight:provider.providerDescription];
    rowHeight =  providerLabelHeight + ProviderDetail_LABEL_YAXIS ;
    rowHeight += SERVICECELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(236,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.providerFont} context:nil];
    return textRect.size.height;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceViewController *providerVC = [[ServiceViewController alloc] initWithNibName:@"ServiceViewController" bundle:nil];
    [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
    [[appDelegate rootNavigationController] pushViewController:providerVC animated:YES];
    
}

-(IBAction)checkProviderAction:(id)sender {
    if (!isCheckProvider) {
        [self.BtnCheckProvider setImage:[UIImage imageNamed:@"checkbox-enable.fw.png"] forState:UIControlStateNormal];
        isCheckProvider = YES;
    }
    else {
        [self.BtnCheckProvider setImage:[UIImage imageNamed:@"checkbox-disable.fw.png"] forState:UIControlStateNormal];
        isCheckProvider = NO;
    }
}

- (IBAction)searchProviderButtonPressed:(id)sender
{
    [self getProviderData];
}

- (IBAction)showServiceCategory:(id)sender
{
    currentPicker = PickerServiceCategory;
    [self showPicker];
}


- (IBAction)showLocalAuthorityPicker:(id)sender
{
    currentPicker = PickerLocalAuthority;
    [self showPicker];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

-(void)tappedOnView:(id)sender
{
    [self.view endEditing:YES];
    [self resignFirstResponders];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark - HideKeyboardNotification

- (void)receivedHideKeyboardNotification:(NSNotification *)notification
{
    DLog("Get %@ From RootVC",notification.name);
    if (notification.name) {
        [self resignFirstResponders];
    }
}

- (void)resignFirstResponders
{
    if ([self.activeTextField isFirstResponder]) {
        [self.activeTextField resignFirstResponder];
    }
}

@end

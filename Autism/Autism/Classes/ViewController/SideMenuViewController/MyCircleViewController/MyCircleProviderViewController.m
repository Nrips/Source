//
//  FindProvidersViewController.m
//  Autism
//
//  Created by Neuron Solutions on 5/19/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MyCircleProviderViewController.h"
#import "CustomTextField.h"
#import "Utility.h"
#import "ProvidersIncircleCell.h"
#import "FindProviderViewController.h"
#import "ProviderDetailViewController.h"


@interface MyCircleProviderViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate, ProvidersIncircleCellDelegate>
{
    NSString *stateIdString;
}
@property (weak, nonatomic) IBOutlet UIButton *searchNowButton;
@property (weak, nonatomic) IBOutlet UIButton *serviceContainerButton;
@property (weak, nonatomic) IBOutlet UIButton *pickerButton;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceProvider;
@property (strong, nonatomic)IBOutlet CustomTextField *txtProvider;
@property (strong, nonatomic)IBOutlet UILabel *lblNoRecordFound;
- (IBAction)searchEvent:(id)sender;

@property (strong, nonatomic) IBOutlet  CustomTextField *txtCategory;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *arrCategory;
@property (nonatomic, strong) NSMutableArray *arrCategoryID;
@property (nonatomic, strong) NSArray *providerInCircleArray;


- (IBAction)categoryPickerEvent:(id)sender;
@end

@implementation MyCircleProviderViewController

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
    
    self.lblNoRecordFound.hidden = YES;
    self.providerInCircleArray = [NSArray new];
     self.txtCategory.delegate = self;
    [self.txtCategory setText:kTitleSelect];

    
    //Set up view for other user
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        self.searchNowButton.hidden = YES;
        self.serviceContainerButton.hidden = YES;
        self.pickerButton.hidden = YES;
        self.lblServiceCategory.hidden = YES;
        self.lblServiceProvider.hidden = YES;
        self.tableProvider.frame = self.view.frame;
        self.navigationController.navigationBarHidden = YES;

        self.tableProvider.contentInset = UIEdgeInsetsMake(40, 0, 88, 0); //values passed are - top, left, bottom, right
        
    } else {
        self.otherMemberId = @"";
        if (!IS_IPHONE_5) {
            self.tableProvider.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
        }
        [self getServicecategory];
        [self setupPicker];
    }
   
    // Do any additional setup after loading the view from its nib.
    [self getProviderInCircle];
    
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getProviderInCircle) forControlEvents:UIControlEventValueChanged];
    [self.tableProvider addSubview:self.refreshControl];
    self.txtProvider.delegate = self;
    [self.txtCategory setText:kTitleSelect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        self.navigationController.navigationBarHidden = NO;
    }
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

-(void)tappedOnView:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Call

- (void)getProviderInCircle
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if ([self.profileType isEqualToString:kProfileTypeOther] && [Utility getValidString:self.otherMemberId].length < 1) {
        DLog(@"Can not perform %@ for other user beacuse other member id not exist",WEB_URL_ProviderInCirlce);
        return;
    }
    NSDictionary *providerInCircleParams = @{
                                           @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           @"other_member_id": [self.profileType isEqualToString:kProfileTypeOther] ? self.otherMemberId : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
                                           };
    NSString *providerInCircleUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_ProviderInCirlce];
    
    DLog(@"%s, Performing %@ Api \n with Parameter:%@",__FUNCTION__, providerInCircleUrl, providerInCircleParams);
    
    [serviceManager executeServiceWithURL:providerInCircleUrl andParameters:providerInCircleParams forTask:kTaskProviderInCircle completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n Response :%@",__FUNCTION__,providerInCircleUrl, response);

        self.providerInCircleArray = [parsingManager parseResponse:response forTask:task];
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
           if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.lblNoRecordFound.hidden = YES;

                    [self.tableProvider reloadData];
                });
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                if ([self.profileType isEqualToString:kProfileTypeOther]) {
                    
                    self.providerInCircleArray = nil;
                    self.lblNoRecordFound.hidden = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableProvider reloadData];
                    });
                 }
                else{
                    self.lblNoRecordFound.hidden = NO;
                    self.lblNoRecordFound.text = @"You haven't added any providers yet.";
                    self.providerInCircleArray = nil;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableProvider reloadData];
                    });
                }
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

#pragma mark - Call service category API

-(void)getServicecategory {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSString *serviceCategoryUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ServiceProviderCategory];
    
    [serviceManager executeServiceWithURL:serviceCategoryUrl forTask:kTaskProviderCategory completionHandler:^(id response, NSError *error, TaskType task) {
        
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            DLog(@"Parsed Data/Category Provider In Circle \n %@",parsedData);
            self.arrCategory = [[parsedData objectForKey:@"data"] valueForKey:@"sc_name"];
            self.arrCategory = [NSMutableArray arrayWithArray:self.arrCategory];
            //[self.arrCategory insertObject:kTitleSelect atIndex:0];
            self.arrCategoryID = [[parsedData objectForKey:@"data"] valueForKey:@"sc_id"];
            DLog(@"Category Id %@",self.arrCategoryID);
            dispatch_async(dispatch_get_main_queue(), ^{

            [self.pickerView reloadAllComponents];
            });            
        }
    }];
}

- (IBAction)categoryPickerEvent:(id)sender {
    [self showPicker];
}

#pragma mark- picker opening/closing methods

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
    if ([self.txtCategory.text isEqualToString:@""]) {
        self.txtCategory.text = (self.arrCategory.count > 0) ?  [self.arrCategory firstObject] : @"";
        stateIdString = (self.arrCategoryID.count > 0) ?  [self.arrCategoryID firstObject] : @"";
    }
    [self hidePicker];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.arrCategory count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.arrCategory objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [self.txtCategory setText:[self.arrCategory objectAtIndex:row]];
    stateIdString = [NSString stringWithFormat:@"%@",[self.arrCategoryID objectAtIndex:row]];
}

#pragma mark- UITextfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"Provider count %d",self.providerInCircleArray.count);
    return self.providerInCircleArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    ProvidersIncircleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [ProvidersIncircleCell cellFromNibNamed:@"ProvidersIncircleCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configureCell:[self.providerInCircleArray objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (IBAction)searchEvent:(id)sender {
    FindProviderViewController *provider = [self.storyboard instantiateViewControllerWithIdentifier:@"FindProviderViewController"];
    provider.providerNameString = self.txtProvider.text;
    provider.serviceCategoryString = self.txtCategory.text;
    provider.serviceCategoryId = stateIdString;
    provider.parentViewType = kCallerMyCircleProvider;
    [[appDelegate rootNavigationController]pushViewController:provider animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProvidersIncircleCell *cell = (ProvidersIncircleCell *)[self.tableProvider cellForRowAtIndexPath:indexPath];
    ProviderDetailViewController *detail = [[ProviderDetailViewController alloc]initWithNibName:@"ProviderDetailViewController" bundle:nil];
    
    detail.providerId = cell.providerId;
    
  //[self.navigationController pushViewController:detail animated:YES];
  [[appDelegate rootNavigationController]pushViewController:detail animated:YES];
   
}

- (void)providerAddedSuccessFully {
    [self getProviderInCircle];
}

@end

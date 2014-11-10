//
//  FbUpdateViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/11/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "FbUpdateViewController.h"
#import "CustomTextField.h"
#import "OtherLocalAuthorityViewController.h"
#import "Utility.h"

typedef enum {
    PickerRole,
    PickerLocalAuthority
    
}Picker;


@interface FbUpdateViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,OtherLocalDelegate,UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    UITextField *activeTextField;
    Picker currentPicker;
    BOOL isCheckTerms;
    
    NSMutableString *strRoleId;


}
- (IBAction)backButtonPressed:(id)sender;
- (void)showLocalAuthorityPicker;
- (void)showRolePicker;
- (void)submitData;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong)  CustomTextField *txtRole;
@property (nonatomic, strong)  CustomTextField *txtLocalAuthority;
@property (nonatomic, strong)  CustomTextField *txtCity;
@property (nonatomic, strong)  CustomTextField *txtPinCode;


@property (nonatomic, strong) NSMutableArray *roleArray;
@property (nonatomic, strong) NSMutableArray *localAuthorityArray;
@property (nonatomic, strong) NSDictionary *otherLocalAuthorityArray;
@property (nonatomic, strong) NSMutableArray *idArray;
@property (nonatomic, strong) NSMutableArray *roleidArray;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UIButton *btnCheckTerms;
@property (nonatomic, strong) UIButton *btnCheckPrivacy;

@property (nonatomic, strong) NSString *strIsAGreed;
@property (nonatomic, strong) NSString *strIsNews;


@end

@implementation FbUpdateViewController


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
    [self setupFeilds];
    /*
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.delegate = self;
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    */
   	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self getLocalAuthorityData];
    [self getRoleData];
    [self getOtherLocalAuthorityData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark IBAction methods.

- (IBAction)backButtonPressed:(id)sender {
    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
    appdel.doNotShowLoginPop = YES;
    [appDelegate clearDefaultValues];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private methods.

- (void)showLocalAuthorityPicker
{
    if ([self.txtCity isFirstResponder]) {
        [self.txtCity resignFirstResponder];
    }
    else if ([self.txtPinCode isFirstResponder])
    {
        [self.txtPinCode resignFirstResponder];
    }
    currentPicker = PickerLocalAuthority;
    [self.scrollView setContentOffset:CGPointMake(0, 160) animated:YES];
    [self showPicker];
    
}

- (void)showRolePicker
{
    currentPicker = PickerRole;
    [self.scrollView setContentOffset:CGPointMake(0, 220) animated:YES];
    [self showPicker];
}

- (void)submitData {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (self.txtCity.text.length > 0 && self.txtLocalAuthority.text.length > 0 && self.txtRole.text.length > 0 && self.txtPinCode.text > 0) {
        
        if (![userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]) {
            [Utility showAlertMessage:@"Member Id is blank." withTitle:@"Error"];
            return;
        }
        NSDictionary *fbUpdateParameters =@{
                                            @"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"m_city_id" : self.txtCity.text,
                                            @"m_local_authority": self.txtLocalAuthority.text,
                                            @"m_mr_id" : strRoleId,
                                            @"m_pincode" :self.txtPinCode.text,
                                            @"m_is_news_send" : isCheckTerms ? @"1" : @"0",
                                            @"device_id" : [userDefaults objectForKey:DEVICE_ID] ? [userDefaults objectForKey:DEVICE_ID] :@"",
                                            @"certification_type" : [appDelegate certifcateType]

                                            };
        
        NSString *fbUpdateUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_FBUpdateLogin];
        
        DLog(@"%s Performing %@ api \n with Parameter :%@",__FUNCTION__,fbUpdateUrl, fbUpdateParameters);
        
        [serviceManager executeServiceWithURL:fbUpdateUrl andParameters:fbUpdateParameters forTask:kTaskSignUp completionHandler:^(id response, NSError *error, TaskType task) {
            
            DLog(@"%s Performing %@ api \n Response :%@",__FUNCTION__,fbUpdateUrl, response);

            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = response;
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    NSDictionary *dataDict = [response objectForKey:@"data"];
                    
                    if (![dataDict valueForKey:@"member_id"]) {
                        [Utility showAlertMessage:@"There are some problem on server side" withTitle:@"Sign Up Error!"];
                        return ;
                    }
                    [userDefaults setObject:[dataDict valueForKey:@"member_id"] forKey:KEY_USER_DEFAULTS_USER_ID];
                    [userDefaults setObject:[dataDict valueForKey:@"member_role"] forKey:KEY_USER_DEFAULTS_USER_ROLE];
                    DLog(@"%@",[userDefaults dictionaryRepresentation]);
                    [userDefaults setObject:[dataDict valueForKey:@"login_name"] forKey:KEY_USER_DEFAULTS_USER_NAME];
                    [userDefaults setObject:[dataDict valueForKey:@"login_name"] forKey:KEY_USER_DEFAULTS_USER_ROLE];
                    [userDefaults setObject: ([dataDict valueForKey:@"member_image"] ? [dataDict valueForKey:@"member_image"] : @"") forKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL];
                    
                    [appDelegate initRootViewController];
                }
                else
                {
                    [Utility showAlertMessage:@"Facebook Login failed." withTitle:@"Error"];
                }
            }else {
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [Utility showAlertMessage:kAlertMessageSomethingWrong withTitle:@"Error"];
            }
        }];
    }
    else
    {
        DLog(@"error occured");
    }
}

/*
-(void)tappedOnView:(id)sender {
    
    [self.view endEditing:YES];
    if (activeTextField) {
        [activeTextField resignFirstResponder];
    }
    [self hidePicker];
}
*/
-(void)setupFeilds
{
    
    UILabel  *lblCity = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 180, 30)];
    lblCity.text = @"City";
    [self.view addSubview:lblCity];
    
    self.txtCity = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 95, 280, 30)];
    self.txtCity.placeholder = @"Enter City";
    self.txtCity.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.txtCity];
    
    UILabel  *lblPinCode = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 180, 30)];
    lblPinCode.text = @"Post Code";
    [self.view addSubview:lblPinCode];
    
    self.txtPinCode = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 170, 280, 30)];
    self.txtPinCode.placeholder = @"Enter Post Code";
    self.txtPinCode.returnKeyType = UIReturnKeyDefault;
    [self.view addSubview:self.txtPinCode];
    
    
    
    
    UILabel  *lblLocalAuthority = [[UILabel alloc] initWithFrame:CGRectMake(20,225, 300, 30)];
    lblLocalAuthority.text = @"Local Authority Area";
    [self.view addSubview:lblLocalAuthority];
    
    self.txtLocalAuthority = [[CustomTextField alloc] initWithFrame:CGRectMake(20,255, 280, 30)];
    self.txtLocalAuthority.placeholder = @"Local Authority Area";
    self.txtLocalAuthority.userInteractionEnabled = NO;
    [self.view addSubview:self.txtLocalAuthority];
    
    UIButton *btnLocalAuth = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLocalAuth.frame = CGRectMake(260, 255, 30, 30);
    UIImage *buttonImageLocal = [UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnLocalAuth setImage:buttonImageLocal forState:UIControlStateNormal];
    [btnLocalAuth addTarget:self action:@selector(showLocalAuthorityPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLocalAuth];
    
    
    
    
    UILabel  * lblRole = [[UILabel alloc] initWithFrame:CGRectMake(20,310,300,30)];
    lblRole.text = @"Role";
    [self.view addSubview:lblRole];
    
    self.txtRole = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 340, 280, 30)];
    self.txtRole.placeholder = @"Enter Role";
    self.txtRole.userInteractionEnabled = NO;
    [self.view addSubview:self.txtRole];
    
    UIButton *btnRoleDrop = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRoleDrop.frame = CGRectMake(260, 340, 30, 30);
    UIImage *buttonImage = [UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnRoleDrop setImage:buttonImage forState:UIControlStateNormal];
    [btnRoleDrop addTarget:self action:@selector(showRolePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRoleDrop];
    
    self.btnCheckTerms = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCheckTerms.frame = CGRectMake(20, 390, 20, 20);
    
    UIImage *buttonImageCheckTerms = [UIImage imageNamed:@"checkbox-disable.fw.png"];
    [self.btnCheckTerms setImage:buttonImageCheckTerms forState:UIControlStateNormal];
    [self.btnCheckTerms addTarget:self action:@selector(checkTerms:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnCheckTerms];

    
    UILabel  * lblNews = [[UILabel alloc] initWithFrame:CGRectMake(45, 380, 270, 50)];
    lblNews.text = @"Yes, please send me news about Autism West Midlands and the online community.";
    lblNews.numberOfLines = 0;
    [lblNews setFont:[UIFont systemFontOfSize:13]];
    [lblNews setLineBreakMode:UILineBreakModeCharacterWrap];
    [self.view addSubview:lblNews];

    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmit.frame = CGRectMake(20, 433, 280, 40);
    [btnSubmit setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIImage *img =[UIImage imageNamed:@"purple-bg.fw.png"];
    [btnSubmit setBackgroundImage:img forState:UIControlStateNormal];
    [btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
    UIColor *btnClor  =[UIColor whiteColor];
    [btnSubmit setTitleColor:btnClor forState:UIControlStateNormal];
    btnSubmit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnSubmit addTarget:self action:@selector(submitData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSubmit];
    
    self.txtRole.delegate=self;
    self.txtLocalAuthority.delegate =self;
    self.txtCity.delegate =self;
    self.txtPinCode.delegate =self;
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 570)];
    
    
    self.baseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216+44)];
    UIToolbar *topBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 44)];
    UIBarButtonItem *donetBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneAction:)];
    topBar.items = [NSArray arrayWithObject:donetBtn];
    donetBtn.tintColor = appUIGreenColor;
    [self.baseView addSubview:topBar];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 216)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.baseView addSubview:self.pickerView];
    
    [self.view addSubview:self.baseView];
    
}


-(void)checkTerms:(id)sender  {
    
    if (!isCheckTerms) {
        [self.btnCheckTerms setImage:[UIImage imageNamed:@"checkbox-enable.fw.png"] forState:UIControlStateNormal];
        isCheckTerms = YES;
    }
    
    else {
        [self.btnCheckTerms setImage:[UIImage imageNamed:@"checkbox-disable.fw.png"] forState:UIControlStateNormal];
        isCheckTerms = NO;
    }
}


-(void)tappedOnScrollView:(id)sender {
    
    if (activeTextField) {
        [activeTextField resignFirstResponder];
    }
    [self hidePicker];
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

- (void)pickerDoneAction:(id)sender {
    
    if (currentPicker == PickerRole && [self.txtRole.text isEqualToString:@""]) {
        self.txtRole.text = (self.roleArray.count > 0) ?  [self.roleArray firstObject] : @"";
        strRoleId = (self.roleidArray.count > 0) ?  [self.roleidArray firstObject] : @"";
    }
    else if(currentPicker == PickerLocalAuthority && [self.txtLocalAuthority.text isEqualToString:@""]) {
       self.txtLocalAuthority.text = (self.localAuthorityArray.count > 0) ?  [self.localAuthorityArray firstObject] : @"";
    }
    [self hidePicker];
}

#pragma mark - OtherLocalDelegate

-(void)didSelectedLocalAuthority:(NSString *)localAuthority {
    
    [self.txtLocalAuthority setText:localAuthority];
}


#pragma mark - Service Manager

-(void) getLocalAuthorityData {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_LocalAuthority];
    DLog(@"%s Performing :%@ Api",__FUNCTION__,strUrl);

    [serviceManager executeServiceWithURL:strUrl forTask:kTaskGetLocalAuthority completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api  \n with response : %@",__FUNCTION__,strUrl,response);
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.localAuthorityArray = [[NSMutableArray alloc]init];
                NSArray *array = [parsedData valueForKey:@"data"];
                for (NSDictionary *localAuthDic in array) {
                    [self.localAuthorityArray addObject:[localAuthDic valueForKey:@"mla_name"]];
                }
                [self.localAuthorityArray addObject:@"Others"];
                [self.pickerView reloadAllComponents];
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
     DLog(@"%s Performing :%@ Api",__FUNCTION__,strOtherLocalAuthcity);
    [serviceManager executeServiceWithURL:strOtherLocalAuthcity forTask:kTaskGetOtherLocalAuthority completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api  \n with response : %@",__FUNCTION__,strOtherLocalAuthcity,response);
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.otherLocalAuthorityArray = parsedData;
                
            });
        }
    }];
}

-(void) getRoleData
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSString *strRole= [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_Role];
    DLog(@"%s Performing :%@ Api",__FUNCTION__,strRole);
    [serviceManager executeServiceWithURL:strRole forTask:kTaskGetRole completionHandler:^(id response, NSError *error, TaskType task) {
        
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            DLog(@"%s %@ api  \n with response : %@",__FUNCTION__,strRole,response);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.roleArray = [[NSMutableArray alloc]init];
                NSArray *array = [parsedData valueForKey:@"data"];
                for (NSDictionary *localAuthDic in array) {
                    [self.roleArray addObject:[localAuthDic valueForKey:@"mr_name"]];
                    
                }
                self.roleidArray = [array valueForKey:@"mr_id"];
                [self.pickerView reloadAllComponents];
            });
        }
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (currentPicker == PickerRole) {
        return [self.roleArray count];
    }
    else {
        return [self.localAuthorityArray count];
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (currentPicker == PickerRole) {
        return [self.roleArray objectAtIndex:row];
    }
    else {
        return [self.localAuthorityArray objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (currentPicker == PickerRole) {
        [self.txtRole setText:[self.roleArray objectAtIndex:row]];
        
        strRoleId = [[NSMutableString alloc]init];
        strRoleId =  [self.roleidArray objectAtIndex:row];
        
    }
    else {
        if (row == [self.localAuthorityArray count]-1) {
            [self hidePicker];
            OtherLocalAuthorityViewController *otherAuthVc = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherLocalAuthorityViewController"];
            [otherAuthVc setDelegate:self];
            [otherAuthVc setSelectedTitle:self.txtLocalAuthority.text];
            [otherAuthVc setDictionary:self.otherLocalAuthorityArray];
            
            UINavigationController *nav = [[UINavigationController alloc]
                                           
                                           initWithRootViewController:otherAuthVc];
            [self presentViewController:nav animated:YES completion:^{}];
        }
        else {
            [self.txtLocalAuthority setText:[self.localAuthorityArray objectAtIndex:row]];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.txtCity) {
        [self.txtPinCode becomeFirstResponder];
    }
    else if (textField == self.txtPinCode) {
        [self.txtPinCode resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self hidePicker];
    activeTextField = textField;
}

@end

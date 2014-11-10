//
//  JoinUsViewController.m
//  Autism
//
//  Created by Vikrant Jain on 1/27/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "JoinUsViewController.h"
#import "CustomTextField.h"
#import "OtherLocalAuthorityViewController.h"
#import "SignInViewController.h"
#import "Utility.h"
#import "PECropViewController.h"

typedef enum {
    PickerRole,
    PickerLocalAuthority
    
}Picker;

@interface JoinUsViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,OtherLocalDelegate, PECropViewControllerDelegate>{
    
    UITextField *activeTextField;
    Picker currentPicker;
    BOOL isCheckTerms;
    BOOL isCheckPrivacy;
}

@property (nonatomic, strong) NSData *compressedImageData;
@property (nonatomic, strong) UIImage *compressedUIImage;

@property (nonatomic, strong) NSURL* localUrl;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) CustomTextField *txtName;
@property (nonatomic,strong) CustomTextField *txtRole;
@property (nonatomic,strong) CustomTextField *txtPassword;
@property (nonatomic,strong) CustomTextField *txtConfirmPassText;
@property (nonatomic,strong) CustomTextField *txtEmail;
@property (nonatomic,strong) CustomTextField *txtLastName;
@property (nonatomic,strong) CustomTextField *txtLocalAuthority;
@property (nonatomic,strong) CustomTextField *txtCity;
@property (nonatomic,strong) CustomTextField *txtPostCode;

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImageView *userImageView;

@property (nonatomic, strong) NSMutableArray *roleArray;
@property (nonatomic, strong) NSMutableArray *roleIDArray;
@property (nonatomic, strong) NSMutableArray *localAuthorityArray;
@property (nonatomic, strong) NSDictionary *otherLocalAuthoritydic;
@property (nonatomic, strong) NSMutableArray *roleIdArray;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UIButton *btnCheckTerms;
@property (nonatomic, strong) UIButton *btnCheckPrivacy;

@property (nonatomic, strong) NSMutableArray *roleIdStr;
@property (nonatomic, strong) NSString *strRoleId;

@property (strong, nonatomic) NSString *base64StringFromProfileImage;

- (IBAction)backAction:(id)sender;

@end

@implementation JoinUsViewController


#pragma mark - View Controller Life Cycle Methods

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
    
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    
    self.compressedUIImage = [[UIImage alloc] init];

    [self getLocalAuthorityData];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Register notification when the keyboard will be show
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	// Remove keyboard notification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Private Methods

-(void)tappedOnView:(id)sender {
    
    [self.view endEditing:YES];
    
    if (activeTextField) {
        [activeTextField resignFirstResponder];
    }
    [self hidePicker];
}

-(void) setupFeilds
{
    
    UITapGestureRecognizer *tapOnScroll = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnScrollView:)];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView addGestureRecognizer:tapOnScroll];
    
    
    UILabel  * lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 180,30)];
    lblFirstName.text = @"First Name";
    [self.scrollView addSubview:lblFirstName];
    
    self.txtName = [[CustomTextField alloc] initWithFrame:CGRectMake(120, 30, 180, 30)];
    self.txtName.placeholder = @"Enter Name";
    self.txtName.returnKeyType = UIReturnKeyNext;
    [self.scrollView addSubview:self.txtName];
    
    
    
    UILabel  * lblLastName = [[UILabel alloc] initWithFrame:CGRectMake(120, 60, 180, 30)];
    lblLastName.text = @"Last Name";
    [_scrollView addSubview:lblLastName];
    
    self.txtLastName = [[CustomTextField alloc] initWithFrame:CGRectMake(120, 90, 180, 30)];
    self.txtLastName.placeholder = @"Enter Last Name";
    self.txtLastName.returnKeyType = UIReturnKeyNext;
    [self.scrollView addSubview:self.txtLastName];
    
    
    
    UILabel  * lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 300, 30)];
    lblEmail.text = @"Email";
    [_scrollView addSubview:lblEmail];
    
    self.txtEmail = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 150, 280, 30)];
    self.txtEmail.placeholder = @"Enter Email";
    self.txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtEmail.returnKeyType = UIReturnKeyNext;
    [self.scrollView addSubview:self.txtEmail];
    
    
    
    UILabel  * lblPassword = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 300, 30)];
    lblPassword.text = @"Password";
    [_scrollView addSubview:lblPassword];
    
    self.txtPassword = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 210, 280, 30)];
    self.txtPassword.placeholder = @"Enter Password";
    self.txtPassword.returnKeyType = UIReturnKeyNext;
    self.txtPassword.secureTextEntry = YES;
    [self.scrollView addSubview:self.txtPassword];
    
    
    
    UILabel  * lblConfirmPass = [[UILabel alloc] initWithFrame:CGRectMake(20, 240, 300, 30)];
    lblConfirmPass.backgroundColor = [UIColor clearColor];
    lblConfirmPass.textColor=[UIColor blackColor];
    lblConfirmPass.text = @"Confirm Password";
    [self.scrollView addSubview:lblConfirmPass];
    
    
    self.txtConfirmPassText = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 270, 280, 30)];
    self.txtConfirmPassText.placeholder = @"Confirm Password";
    self.txtConfirmPassText.returnKeyType = UIReturnKeyNext;
    self.txtConfirmPassText.secureTextEntry = YES;
    [self.scrollView addSubview:self.txtConfirmPassText];
    
    
    
    UILabel  * lblCity = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 300, 30)];
    lblCity.text = @"Town or City";
    [self.scrollView addSubview:lblCity];
    
    self.txtCity = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 330, 280, 30)];
    self.txtCity.placeholder = @"Enter Town or City";
    self.txtCity.returnKeyType = UIReturnKeyNext;
    [self.scrollView addSubview:self.txtCity];
    
    
    
    
    UILabel  * lblPostCode = [[UILabel alloc] initWithFrame:CGRectMake(20, 360, 300, 30)];
    lblPostCode.text = @"Post Code";
    [self.scrollView addSubview:lblPostCode];
    
    self.txtPostCode = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 390, 280, 30)];
    self.txtPostCode.placeholder = @"Enter Post Code";
    self.txtPostCode.returnKeyType = UIReturnKeyDefault;
    [self.scrollView addSubview:self.txtPostCode];
    

    UILabel  * lblLocalAuthority = [[UILabel alloc] initWithFrame:CGRectMake(20, 420, 300, 30)];
    lblLocalAuthority.text = @"Local Authority Area";
    [self.scrollView addSubview:lblLocalAuthority];
    
    self.txtLocalAuthority = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 450, 280, 30)];
    self.txtLocalAuthority.placeholder = @"Select Local Authority Area";
    self.txtLocalAuthority.userInteractionEnabled = NO;
    [self.scrollView addSubview:self.txtLocalAuthority];
    
    UIButton *btnLocalAuth = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLocalAuth.frame = CGRectMake(260, 450, 30, 30);
    UIImage *buttonImageLocal = [UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnLocalAuth setImage:buttonImageLocal forState:UIControlStateNormal];
    [btnLocalAuth addTarget:self action:@selector(showLocalAuthorityPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnLocalAuth];
    
    UILabel  * lblRole = [[UILabel alloc] initWithFrame:CGRectMake(20, 480, 300, 30)];
    lblRole.text = @"Role";
    [self.scrollView addSubview:lblRole];
    
    self.txtRole = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 510, 280, 30)];
    self.txtRole.placeholder = @"Select Role";
    self.txtRole.userInteractionEnabled = NO;
    [self.scrollView addSubview:self.txtRole];
    
    UIButton *btnRoleDrop = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRoleDrop.frame = CGRectMake(260, 510, 30, 30);
    UIImage *buttonImage = [UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnRoleDrop setImage:buttonImage forState:UIControlStateNormal];
    [btnRoleDrop addTarget:self action:@selector(showRolePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnRoleDrop];
    
    
    
    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 95,95)];
    [self.userImageView.layer setBorderColor: [[UIColor colorWithRed:196/255.0f green:196/255.0f blue:196/255.0f alpha:1.0f] CGColor]];
    [self.userImageView.layer setBorderWidth: 2.0];
    self.userImageView.layer.cornerRadius = 4;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.userImageView.image = [UIImage imageNamed:@"avatar-140.png"];
    [self.userImageView setUserInteractionEnabled:YES];

    [self.scrollView addSubview:self.userImageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapOnImage:)];
    [self.userImageView addGestureRecognizer:singleTap];
    
    
    
    
    UIButton *btnTerms = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTerms.frame = CGRectMake(50, 540, 270, 30);
    [btnTerms setTitle:@"Terms and conditions" forState:UIControlStateNormal];
    [btnTerms setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnTerms.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_scrollView addSubview:btnTerms];
    
    self.btnCheckTerms = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCheckTerms.frame = CGRectMake(20, 545, 20, 20);
    
    UIImage *buttonImageCheckTerms = [UIImage imageNamed:@"checkbox-disable.fw.png"];
    [self.btnCheckTerms setImage:buttonImageCheckTerms forState:UIControlStateNormal];
    [self.btnCheckTerms addTarget:self action:@selector(checkTerms:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:self.btnCheckTerms];
    
    
    
    
    
    UIButton *btnPrivacy = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPrivacy.frame = CGRectMake(50, 580, 270, 30);
    [btnPrivacy setTitle:@"Privacy Policy" forState:UIControlStateNormal];
    [btnPrivacy setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnPrivacy.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnPrivacy addTarget:self action:@selector(privacyPolicyAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:btnPrivacy];
    
    self.btnCheckPrivacy = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCheckPrivacy.frame = CGRectMake(20, 585, 20, 20);
    UIImage *buttonImage2 = [UIImage imageNamed:@"checkbox-disable.fw.png"];
    [self.btnCheckPrivacy setImage:buttonImage2 forState:UIControlStateNormal];
    
    [self.btnCheckPrivacy addTarget:self action:@selector(checkPrivacy:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:self.btnCheckPrivacy];
    
    isCheckPrivacy = isCheckTerms = 0;
    
    
    
    
    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmit.frame = CGRectMake(60, 635, 200, 30);
    [btnSubmit setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIImage *mybtnSubmitImage =[UIImage imageNamed:@"big-signin-blank.fw.png"];
    [btnSubmit setBackgroundImage:mybtnSubmitImage forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
    btnSubmit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnSubmit addTarget:self action:@selector(submitData:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:btnSubmit];
    
    
    
    self.txtName.delegate = self;
    self.txtRole.delegate = self;
    self.txtPassword.delegate = self;
    self.txtConfirmPassText.delegate = self;
    self.txtEmail.delegate =self;
    self.txtLastName.delegate =self;
    self.txtLocalAuthority.delegate =self;
    self.txtCity.delegate =self;
    self.txtPostCode.delegate = self;
    
    if (!IS_IPHONE_5) {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 850)];
    }
    else
    {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 800)];
    }
    
    
    
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

-(void)privacyPolicyAction
{
   NSString *url = @"https://connect.autismwestmidlands.org.uk/index.php/site/privacypolicy";
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url ]];
}


#pragma mark - UI Methods

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) singleTapOnImage:(id)sender {
    
    if (activeTextField) {
        [activeTextField resignFirstResponder];
    }
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select image from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:
                            @"Camera",
                            @"Photo Gallery",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

-(void) tappedOnScrollView:(id)sender {
    
    if (activeTextField) {
        [activeTextField resignFirstResponder];
    }
    [self hidePicker];
}


-(void) showRolePicker
{
    currentPicker = PickerRole;
    [self.scrollView setContentOffset:CGPointMake(0, 220) animated:YES];
    [self showPicker];
}


-(void) showLocalAuthorityPicker
{
    currentPicker = PickerLocalAuthority;
    [self.scrollView setContentOffset:CGPointMake(0, 160) animated:YES];
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
    if (currentPicker == PickerRole && [self.txtLocalAuthority.text isEqualToString:@""]) {
        self.txtRole.text = (self.roleArray.count > 0) ?  [self.roleArray firstObject] : @"";
        self.strRoleId = (self.roleIDArray.count > 0) ?  [self.roleIDArray firstObject] : @"";
    }
    else {
        self.txtLocalAuthority.text = (self.localAuthorityArray.count > 0) ?  [self.localAuthorityArray firstObject] : @"";
    }
    
    [self hidePicker];
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


- (void)checkPrivacy:(id)sender {
    
    if (!isCheckPrivacy) {
        [self.btnCheckPrivacy setImage:[UIImage imageNamed:@"checkbox-enable.fw.png"] forState:UIControlStateNormal];
        isCheckPrivacy = YES;
    }
    
    else {
        [self.btnCheckPrivacy setImage:[UIImage imageNamed:@"checkbox-disable.fw.png"] forState:UIControlStateNormal];
        isCheckPrivacy = NO;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                    
                case 0: {
                    self.selectedImage = nil;
                    self.userImageView.image = [UIImage imageNamed:@"avatar-140.png"];
                }
                    break;
                case 1: {
                    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:picker animated:YES completion:NULL];
                }
                    break;
                case 2: {
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



/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Picking Image from Camera/ Library
    [picker dismissViewControllerAnimated:YES completion:^{}];
    self.selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (!self.selectedImage)
    {
        return;
    }
    
    // Adjusting Image Orientation
    NSData *data = UIImagePNGRepresentation(self.selectedImage);
    UIImage *tmp = [UIImage imageWithData:data];
    UIImage *fixed = [UIImage imageWithCGImage:tmp.CGImage
                                         scale:self.selectedImage.scale
                                   orientation:self.selectedImage.imageOrientation];
    self.selectedImage = fixed;
    [self.userImageView setImage:self.selectedImage];
    
    [self compressForUpload:self.selectedImage :0.3];
    
    
    self.localUrl = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
}*/

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
    self.userImageView.image = croppedImage;
    self.selectedImage = croppedImage;
    DLog(@"%s, Profile image Size After Cropping:%@",__FUNCTION__ ,NSStringFromCGSize(self.selectedImage.size));
    
   /* NSData *data1 = UIImagePNGRepresentation(self.selectedImage);
    DLog(@"Real Photo galary image from size in MB :%.2f",(float)data1.length/1024.0f/1024.0f);*/
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Action methods

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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([activeTextField isFirstResponder]) {
        [activeTextField resignFirstResponder];
    }
    if (textField == self.txtName) {
        [self.txtLastName becomeFirstResponder];
    }
    else if (textField == self.txtLastName) {
        [self.txtEmail becomeFirstResponder];
    }
    else if (textField == self.txtEmail) {
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField == self.txtPassword) {
        [self.txtConfirmPassText becomeFirstResponder];
    }
    else if (textField == self.txtConfirmPassText) {
        [self.txtCity becomeFirstResponder];
    }  else if (textField == self.txtCity) {
        [self.txtPostCode becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
    [self hidePicker];
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
        DLog(@"%s Performing :%@ Api \n Response : %@",__FUNCTION__,strUrl,response);
        if (!error && response) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.localAuthorityArray = [[NSMutableArray alloc]init];
                NSArray *array = [parsedData valueForKey:@"data"];
                for (NSDictionary *localAuthDic in array) {
                    [self.localAuthorityArray addObject:[localAuthDic valueForKey:@"mla_name"]];
                }
                [self.localAuthorityArray addObject:@"Others"];
                [self.pickerView reloadAllComponents];
                
                [self getRoleData];
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
        DLog(@"%s Performing :%@ Api \n Response : %@",__FUNCTION__,strOtherLocalAuthcity,response);
        if (!error && response) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.otherLocalAuthoritydic = parsedData;
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
        DLog(@"%s Performing :%@ Api \n Response : %@",__FUNCTION__,strRole,response);

        if (!error && response) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.roleArray = [[NSMutableArray alloc]init];
                self.roleIDArray = [[NSMutableArray alloc] init];
                NSArray *array = [parsedData valueForKey:@"data"];
                for (NSDictionary *localAuthDic in array) {
                    [self.roleArray addObject:[localAuthDic valueForKey:@"mr_name"]];
                }
                self.roleIdArray = [array valueForKey:@"mr_id"];
                [self.pickerView reloadAllComponents];
                
                [self getOtherLocalAuthorityData];
            });
        }
    }];
}

- (void)submitData:(id)sender {
    
    // DLog(@"Image size %lu",(unsigned long)[self.compressedImageData length]/1024);
    
    
    
    
    //    const unsigned char *bytes = [self.compressedImageData bytes];
    //    NSUInteger length = [self.compressedImageData length];
    
    
    
    //NSString *strData = [UIImagePNGRepresentation(self.selectedImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    //    NSString *newStr =[[NSString alloc] initWithData:self.compressedImageData encoding:NSASCIIStringEncoding];
    //
    //
    //
    //
    //    NSDictionary *signUpParameters =@{@"u_login_name":ObjectOrNull(self.txtName.text) ,
    //                                      @"m_last_name" : ObjectOrNull(self.txtLastName.text),
    //                                      @"u_email" : ObjectOrNull(self.txtEmail.text),
    //                                      @"u_password" : ObjectOrNull(self.txtPassword.text),
    //                                      @"m_city_id" : ObjectOrNull(self.txtCity.text),
    //                                      @"m_local_authority": ObjectOrNull(self.txtLocalAuthority.text),
    //                                      @"m_mr_id" : ObjectOrNull(self.strRoleId),
    //                                      @"m_is_aggreed" : ObjectOrNull(self.strIsAGreed),
    //                                      @"m_is_news_send" : ObjectOrNull(self.strIsNews),
    //                                      @"userPostImage" : ObjectOrNull(self.compressedImageData)
    //
    //                                      };
    //
    //    DLog(@"%@",self.compressedImageData);
    
    //DLog(@"%@",signUpParameters);
    
    
    
    
    
    
    //    if (![self NSStringIsValidName:self.txtName.text])
    //    {
    //        [self alertStatus:@"Enter only alphabets" :@"Invalid Name"];
    //    }
    //    else if (![self NSStringIsValidName:self.txtLastName.text])
    //    {
    //        [self alertStatus:@"Enter only alphabets" :@"Invalid LastName"];
    //    }
    //    else if (![self NSStringIsValidEmail:self.txtEmail.text])
    //    {
    //        [self alertStatus:@"Enter valid email" :@"Error"];
    //    }
    //    else if ([self.txtPassword.text length] < 6)
    //    {
    //        [self alertStatus:@"Password should have 6 characters atleast" :@"Error"];
    //    }
    //    else if (![self.txtPassword.text isEqualToString:self.txtConfirmPassText.text]) {
    //
    //        [self alertStatus:@"Password didn't match" :@"error"];
    //    }
    //    else if ([self.txtCity.text isEqualToString:@""]|| [self.txtLocalAuthority.text isEqualToString:@""]||[self.txtRole.text isEqualToString:@""])
    //    {
    //        [self alertStatus:@"Fill all the field" :@"Error"];
    //    }
    //
    //
    //
    //
    //
    //   else{
    //
    //        DLog(@"Image size %lu",(unsigned long)[self.compressedImageData length]/1024);
    //
    //       NSDictionary *signUpParameters =@{@"u_login_name":ObjectOrNull(self.txtName.text) ,
    //                                         @"m_last_name" : ObjectOrNull(self.txtLastName.text),
    //                                         @"u_email" : ObjectOrNull(self.txtEmail.text),
    //                                         @"u_password" : ObjectOrNull(self.txtPassword.text),
    //                                         @"m_city_id" : ObjectOrNull(self.txtCity.text),
    //                                         @"m_local_authority": ObjectOrNull(self.txtLocalAuthority.text),
    //                                         @"m_mr_id" : ObjectOrNull(self.strRoleId),
    //                                         @"m_is_aggreed" : ObjectOrNull(self.strIsAGreed),
    //                                         @"m_is_news_send" : ObjectOrNull(self.strIsNews),
    //                                         @"userPostImage" : ObjectOrNull(self.compressedImageData)
    //
    //                                         };
    //        //DLog(@"%@",signUpParameters);
    
    //NSString *strnew =[[NSString alloc] initWithData:self.compressedImageData encoding:NSASCIIStringEncoding];
    
    
    
    
    
    //       NSDictionary *signUpParameters =@{@"userPostImage": self.compressedImageData};
    //
    //
    //
    //    NSString *strSignUpUrl = [NSString stringWithFormat:@"http://autism.neuroninc.com/index.php/api/Activity/PostImage"];
    //
    //        [serviceManager executeServiceWithURL:strSignUpUrl andParameters:signUpParameters forTask:kTaskSignUp completionHandler:^(id response, NSError *error, TaskType task) {
    //
    //        }];
    
    
    
    //Validate text fields and show alert
    
    if (self.selectedImage) {
        self.base64StringFromProfileImage = [self base64forData:UIImagePNGRepresentation(self.selectedImage)];
    }
    
    if (self.txtName.text.length < 1) {
        [Utility showAlertMessage:@"Please enter First Name." withTitle:@"First Name can not be blank."];
    } else if (self.txtLastName.text.length < 1) {
        [Utility showAlertMessage:@"Please enter Last Name." withTitle:@"Last Name can not be blank."];
    } else if (self.txtEmail.text.length < 1) {
        [Utility showAlertMessage:@"Please enter email." withTitle:@"Your Email can not be blank."];
    } else if (self.txtPassword.text.length < 1) {
        [Utility showAlertMessage:@"Please enter Password." withTitle:@"Password can not be blank."];
    }
    else if (self.txtConfirmPassText.text.length < 1) {
        [Utility showAlertMessage:@"Confirm Password didn't match" withTitle:@"Password can not be blank."];
    }
    else if (self.txtCity.text.length < 1) {
        [Utility showAlertMessage:@"Please enter Town/City." withTitle:@"Town or City can not be blank."];
    }
    else if (self.txtPostCode.text.length < 1) {
        [Utility showAlertMessage:@"Please enter Postcode." withTitle:@"Postcode can not be blank."];
    }
    else if (self.txtLocalAuthority.text.length < 1) {
        [Utility showAlertMessage:@"Please select Local Authority Area." withTitle:@"Local Authority Area can not be blank."];
    } else if (!isCheckTerms) {
        [Utility showAlertMessage:@"You must agree to these conditions in order to join the site." withTitle:@" Accept terms and conditions."];
    }
    else if (self.txtRole.text.length < 1 || !self.strRoleId) {
        [Utility showAlertMessage:@"Role Authority Area." withTitle:@"Role can not be blank."];
    } else if (![Utility NSStringIsValidName:self.txtName.text])
    {
        [Utility showAlertMessage:@"Enter only alphabets" withTitle:@"Invalid Name"];
    }
    else if (![Utility NSStringIsValidName:self.txtLastName.text])
    {
        [Utility showAlertMessage:@"Enter only alphabets"  withTitle:@"Invalid LastName"];
    }
    else if (![Utility NSStringIsValidEmail:self.txtEmail.text])
    {
        [Utility showAlertMessage:@"Enter valid email" withTitle:@"Error"];
    }
    else if ([self.txtPassword.text length] < 6)
    {
        [Utility showAlertMessage:@"Password should have atleast 6 characters." withTitle:@"Error"];
    }
    else if (![self.txtPassword.text isEqualToString:self.txtConfirmPassText.text]) {
        [Utility showAlertMessage:@"Password did not match" withTitle:@"Error"];
    } else{
        
        if (![appDelegate isNetworkAvailable])
        {
            [Utility showNetWorkAlert];
            return;
        }
        NSDictionary *signUpParameters =@{@"m_name": self.txtName.text,
                                          @"m_last_name" : self.txtLastName.text,
                                          @"u_email" : self.txtEmail.text,
                                          @"u_password" : self.txtPassword.text,
                                          @"u_confirm_password":self.txtConfirmPassText.text,
                                          @"m_city_id" : self.txtCity.text,
                                          @"m_pincode":self.txtPostCode.text,
                                          @"m_local_authority": self.txtLocalAuthority.text,
                                          @"m_mr_id" : self.strRoleId,
                                          @"m_is_aggreed" : isCheckTerms ? @"1" : @"0",
                                          @"m_is_news_send" : isCheckPrivacy ? @"1" : @"0",
                                          @"userPostImage" : self.base64StringFromProfileImage ? self.base64StringFromProfileImage : @""
                                          };
        
        NSString *strSignUpUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_SignUp];
       // DLog(@"signUpParameters:%@",signUpParameters);
        DLog(@"%s, Performing %@ api",__FUNCTION__,strSignUpUrl);
        
        [serviceManager executeServiceWithURL:strSignUpUrl andParameters:signUpParameters forTask:kTaskSignUp completionHandler:^(id response, NSError *error, TaskType task) {
            DLog(@"%s, Performing %@ api \n Response:%@",__FUNCTION__,strSignUpUrl,response );
            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    
                    [Utility showAlertMessage:@"Please check your email to activate your account. If you cannot find this email, please check your Junk Mail folder." withTitle:@"Regiestered Succesfully"];
                    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
                    appdel.signUpCompleted = YES;
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                } else {
                    if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                        [Utility showAlertMessage:@"Required field is empty."withTitle:@"Error"];
                    } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"] && [[dict valueForKey:@"data"] valueForKey:@"u_email"] != nil) {
                        [Utility showAlertMessage:@"This email is already registered." withTitle:[dict objectForKey:@"Registration Failed"]];
                    }
                }
            } else
            {
                DLog(@"%s, Error:%@",__FUNCTION__, error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }];
    }
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


- (UIImage *)compressForUpload:(UIImage *)original :(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.compressedImageData =  UIImagePNGRepresentation(compressedImage);
    //[self base64forData:self.compressedImageData];
    [self gzipDeflate:self.compressedImageData];
    return compressedImage;
}

#pragma mark - gZip compression method
- (NSData *)gzipInflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

- (NSData *)gzipDeflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = (unsigned)[data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = [compressed length] - strm.total_out ;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

     
//    @catch (NSException * e) {
//        DLog(@"Exception: %@", e);
//        [self alertStatus:@"Enter all the field." :@"Error!"];
//    }
//    

    




#pragma mark - UIPickerViewDataSource 

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
        
        self.strRoleId = [self.roleIdArray objectAtIndex:row];
        

        DLog(@"Selected Role:%@",[self.roleArray objectAtIndex:row]);
    }
    else {
        if (row == [self.localAuthorityArray count]-1) {
            [self hidePicker];
            OtherLocalAuthorityViewController *otherAuthVc = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherLocalAuthorityViewController"];
            [otherAuthVc setDelegate:self];
            [otherAuthVc setSelectedTitle:self.txtLocalAuthority.text];
            [otherAuthVc setDictionary:self.otherLocalAuthoritydic];
            
            UINavigationController *nav = [[UINavigationController alloc]
                                           
                                           initWithRootViewController:otherAuthVc];
            [self presentViewController:nav animated:YES completion:^{}];
        }
        else {
            [self.txtLocalAuthority setText:[self.localAuthorityArray objectAtIndex:row]];
        }
    }
}

#pragma mark KeyBoard Show/Hide Delegate

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint txtFieldOrigin = activeTextField.frame.origin;
    CGFloat txtFieldHeight = activeTextField.frame.size.height;
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height + txtFieldHeight + 25;
    if (!CGRectContainsPoint(visibleRect, txtFieldOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, txtFieldOrigin.y - 30);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - OtherLocalDelegate

-(void)didSelectedLocalAuthority:(NSString *)localAuthority {
    
    [self.txtLocalAuthority setText:localAuthority];
}

@end

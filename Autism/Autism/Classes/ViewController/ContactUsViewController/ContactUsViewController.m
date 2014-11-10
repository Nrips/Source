//
//  ContactUsViewController.m
//  Autism
//
//  Created by Dipak on 5/26/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ContactUsViewController.h"
#import "UIPlaceHolderTextView.h"
#import "CustomTextField.h"
#import "Utility.h"

@interface ContactUsViewController () <UITextFieldDelegate, UITextViewDelegate,MFMailComposeViewControllerDelegate>

{
      UIWebView *mCallWebview;
}

@property (weak, nonatomic) IBOutlet CustomTextField *nameTxtField;
@property (weak, nonatomic) IBOutlet CustomTextField *emailTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *messageTextView;
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet UIButton *btnPhone;
@property (strong, nonatomic) IBOutlet UIButton *btnEmail;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;

- (IBAction)sendMessageButtonPressed:(id)sender;
- (IBAction)callEvent:(id)sender;
- (IBAction)emailSendEvent:(id)sender;
@end

@implementation ContactUsViewController

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
    self.activeTextField.delegate = self;
    self.messageTextView.layer.borderColor = [UIColor colorWithRed:46/255.0f green:180/255.0f blue:189/255.0f alpha:1.0f].CGColor;
    self.messageTextView.layer.borderWidth = 1.5f;
    self.messageTextView.layer.cornerRadius = 4;
    self.messageTextView.placeholder = @"Enter your message here";
    
    self.lblAddress.textAlignment = NSTextAlignmentCenter;

    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	// Register notification when keyboard will be show
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
    
	// Register notification when keyboard will be hide
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

// To remove keyboard notification
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)sendMessageButtonPressed:(id)sender
{
    [self performContactUsApi];
}

- (IBAction)callEvent:(id)sender {
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel:01214507582"];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
    if (!mCallWebview)
        mCallWebview = [[UIWebView alloc] init];
    
    [mCallWebview loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

- (IBAction)emailSendEvent:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Mail Alert" message:@"Email cannot be configured. Go to iPhone settings and configure your mail account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }else {
        
        NSArray *toRecipents = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@",self.btnEmail.titleLabel.text]];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:toRecipents];
        //[picker setSubject:subject];
        //[picker setMessageBody:body isHTML:YES];
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}
#pragma mark - Mailcomposer Delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            DLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            DLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            DLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.activeTextField isFirstResponder]) {
        [self.activeTextField resignFirstResponder];
    }
    if (textField == self.nameTxtField) {
        [self.emailTextField becomeFirstResponder];
    }
    else if (textField == self.emailTextField) {
        [self.subjectTextField becomeFirstResponder];
    }
    /*else if (textField == self.subjectTextField) {
        [self.messageTextView becomeFirstResponder];
    }*/
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {
    if (textView == self.messageTextView) {
        [self.messageTextView resignFirstResponder];
        [self performContactUsApi];
    }
    return YES;
}

-(void)tappedOnView:(id)sender {
    
    [self.view endEditing:YES];
    if ([self.activeTextField isFirstResponder]) {
        [self.activeTextField resignFirstResponder];
    }
    if ([self.messageTextView isFirstResponder]) {
        [self.messageTextView resignFirstResponder];
    }
}

#pragma mark KeyBoard Show/Hide Delegate

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.messageTextView isFirstResponder]) {
        CGRect frame = self.view.frame;
        frame.origin.y = frame.origin.y - 120;
        self.view.frame = frame;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect frame = self.view.frame;
    if (frame.origin.y != 0) {
        frame.origin.y = 0;
        self.view.frame = frame;
    }
}

- (void)performContactUsApi
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if ([Utility getValidString:self.nameTxtField.text].length < 1) {
        [Utility showAlertMessage:@"Please fill all the fields" withTitle:@"Name is empty."];
        return;
    } else if ([Utility getValidString:self.emailTextField.text].length < 1) {
        [Utility showAlertMessage:@"Please fill all the fields" withTitle:@"Email is empty."];
        return;
    } else if (![Utility NSStringIsValidEmail:[Utility getValidString:self.emailTextField.text]]) {
        [Utility showAlertMessage:@"" withTitle:@"Email is not a valid email address."];
        return;
    }
    else if ([Utility getValidString:self.subjectTextField.text].length < 1) {
        [Utility showAlertMessage:@"Please fill all the fields" withTitle:@"Subject is empty."];
        return;
    }else if ([Utility getValidString:self.messageTextView.text].length < 1) {
        [Utility showAlertMessage:@"Please fill all the fields" withTitle:@"Message is empty."];
        return;
    }
    NSDictionary *contactUsParameter = @{
                                              @"name": [Utility getValidString:self.nameTxtField.text],
                                              @"email": [Utility getValidString:self.emailTextField.text],
                                              @"subject": [Utility getValidString:self.subjectTextField.text],
                                              @"message": [Utility getValidString:self.messageTextView.text],
                                              };
    
    NSString *contactUsUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_ContactUs];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,contactUsUrl,contactUsParameter);
    
    [serviceManager executeServiceWithURL:contactUsUrl andParameters:contactUsParameter forTask:kTaskContactUs completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,contactUsUrl, response);

        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"We will respond to you as soon as possible." withTitle:@"Thank you for contacting us."];
                self.nameTxtField.text = @"";
                self.emailTextField.text = @"";
                self.subjectTextField.text = @"";
                self.messageTextView.text = @"";
            }
            else{
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
    }];
}

@end

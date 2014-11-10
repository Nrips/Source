//
//  SignInViewController.m
//  Autism
//
//  Created by Vikrant Jain on 1/24/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "SignInViewController.h"
#import "RootViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "Utility.h"


@interface SignInViewController ()<UITextFieldDelegate>
{
}

@property (weak, nonatomic) IBOutlet UILabel *incorrectUserNameAndPwdLabel;
@property(nonatomic , strong) IBOutlet UITextField *txtActive;
@property (strong, nonatomic) IBOutlet CustomTextField *txtEmail;
@property (strong, nonatomic) IBOutlet CustomTextField *txtPassword;

@property (strong, nonatomic) IBOutlet UIButton *rememberMeButton;

@property(strong,nonatomic)NSString *strchek;



- (IBAction)cancelEvent:(id)sender;
- (IBAction)rememberMeButtonTapped:(id)sender;
- (IBAction)forgotPasswordButtonTapped:(id)sender;
- (IBAction)signInEvent:(id)sender;

@end



@implementation SignInViewController


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
	// Do any additional setup after loading the view.
    //[self.incorrectUserNameAndPwdLabel setHidden:YES];
   
    // set Remember me from userdefault stored value
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kRememberMeFlag] isEqualToString:@"YES"])
	{
		self.rememberMeButton.selected = YES;
		self.txtEmail.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUserEmailUserDefault];
        self.txtPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPasswordUserDefault];
	}
    [self textFieldColorSet];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Button's Action Methods

- (IBAction)cancelEvent:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)rememberMeButtonTapped:(id)sender {
    self.rememberMeButton.selected = !self.rememberMeButton.selected;
}

- (IBAction)forgotPasswordButtonTapped:(id)sender
{
    [self.txtActive resignFirstResponder];
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    //Build Changes - Set Url according to
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://connectautism.neuroninc.com/index.php/auth/login/forgot"]];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://whatall.com/index.php/auth/login/forgot"]];
}


- (IBAction)signInEvent:(id)sender {
   
    [userDefaults setObject:([self.rememberMeButton isSelected] ? @"YES" : @"NO") forKey:kRememberMeFlag];
   
    if ([userDefaults objectForKey:kRememberMeFlag] && [[userDefaults objectForKey:kRememberMeFlag] isEqualToString:@"YES"])
    {
        [userDefaults setObject:self.txtEmail.text forKey:kUserEmailUserDefault];
        [userDefaults setObject:self.txtPassword.text forKey:kUserPasswordUserDefault];
    }
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (![Utility NSStringIsValidEmail:self.txtEmail.text])
    {
        [Utility showAlertMessage:@"Enter valid email " withTitle:@"Invalid E-mail"];

    }
    else if ([self.txtPassword.text length] < 6)
    {
        [Utility showAlertMessage:@"Password should have 6 characters atleast" withTitle:@"Error"];
    }
    
    else{
      
        NSDictionary *signInParameters =@{ @"u_email" : self.txtEmail.text,
                                           @"u_password" : self.txtPassword.text,
                                           @"device_id" : [userDefaults objectForKey:DEVICE_ID] ? [userDefaults objectForKey:DEVICE_ID] :@"",
                                           @"certification_type" : [appDelegate certifcateType]
                                           };
        NSString *signInUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_Login];
        //Build Changes - Always comment with parameter log
       
        DLog(@"Performing %@ api, \n with parameter:%@",signInUrl,signInParameters);
        
        DLog(@"Performing %@ api",signInUrl);
        [serviceManager executeServiceWithURL:signInUrl andParameters:signInParameters forTask:kTaskLogin completionHandler:^(id response, NSError *error, TaskType task) {

            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                
                DLog(@"%@ api \n response:%@",signInUrl,response);
                
                if ([[dict objectForKey:@"success"] boolValue]) {
                    
                    NSArray *ArrayId = [[NSArray alloc]init];
                    ArrayId = [dict objectForKey:@"data"];
                    DLog(@"%@",ArrayId);
                    self.strchek = [ArrayId valueForKey:@"member_id"];
                    
                    [userDefaults setBool:YES forKey:@"isUserLogin"];
              
                    [userDefaults setObject:self.strchek forKey:KEY_USER_DEFAULTS_USER_ID];
                    [userDefaults setObject:[ArrayId valueForKey:@"member_role"] forKey:KEY_USER_DEFAULTS_USER_ROLE];
                    
                    [userDefaults setObject:[ArrayId valueForKey:@"login_name"] forKey:KEY_USER_DEFAULTS_USER_NAME];
                    [userDefaults setObject:[ArrayId valueForKey:@"member_city"] forKey:KEY_USER_DEFAULTS_USER_City];
                    [userDefaults setObject: ([ArrayId valueForKey:@"member_image"] ? [ArrayId valueForKey:@"member_image"]  : @"") forKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL];
                     [userDefaults setObject:[ArrayId valueForKey:@"member_local_authority"] forKey:KEY_USER_DEFAULTS_USER_LocalAuthority];
                    
                 
                   
                    [userDefaults synchronize];
                    [appDelegate initRootViewController];
                    DLog(@"User login successfully");
                } else {
                    NSString * loginMsg = [dict objectForKey:@"message"];
                    
                    if ([loginMsg isEqualToString:@"Username or password is incorrect"])
                    {
                        [Utility showAlertMessage:@"Email and Password did not match" withTitle:@"Error"];
                        //[self.incorrectUserNameAndPwdLabel setHidden:NO];
                    }
                    
                    else  if ([loginMsg isEqualToString:@"Account Not activated"])
                    {
                        [Utility showAlertMessage:loginMsg withTitle:@"Error"];
                    }
                    else  if ([loginMsg isEqualToString:@"Member Not activated/blocked"])
                    {
                        [Utility showAlertMessage:loginMsg withTitle:@"Error"];
                    }
                }
            } else
            {
                DLog(@"error:%@",error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }];
    }
   
    //[appDelegate initRootViewController];
}

#pragma mark - TestField Methods

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.phase == UITouchPhaseBegan) {
        
        [_txtEmail resignFirstResponder];
        [_txtPassword resignFirstResponder];
        
    }
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.txtActive = textField;
    return YES;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
 {
      [textField resignFirstResponder];
      return YES;
}


-(void) textFieldColorSet
{
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 10)];
    [_txtEmail setLeftViewMode:UITextFieldViewModeAlways];
    [_txtEmail setLeftView:spacerView];
    
    
    UIView *spacerViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 10)];
    [_txtPassword setLeftViewMode:UITextFieldViewModeAlways];
    [_txtPassword setLeftView:spacerViewPassword];
    
    
    _txtEmail.delegate =self;
    _txtPassword.delegate =self;
    
}

@end

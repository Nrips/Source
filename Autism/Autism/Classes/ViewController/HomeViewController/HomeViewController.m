//
//  HomeViewController.m
//  Autism
//
//  Created by Vikrant Jain on 1/24/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "HomeViewController.h"
#import "SignInViewController.h"
#import "JoinUsViewController.h"
#import "AppDelegate.h"
#import "FbUpdateViewController.h"
#import "RootViewController.h"
#import "MyStoryViewController.h"
#import "Utility.h"


@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *logoImag;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImag;

@property (nonatomic, strong) NSMutableArray *idArray;
@property (nonatomic, strong)UIActivityIndicatorView *spinner;

@end

@implementation HomeViewController


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
    DLog(@"%s",__FUNCTION__);
    if (!IS_IPHONE_5) {
        [self.bannerImag setFrame:CGRectMake(0, 91, 320,218 )];
        [self.bannerImag setImage:[UIImage imageNamed:@"home-banner-640-436.png"]];
        [self.logoImag setFrame:CGRectMake(81, 35, 157,42 )];
        [self.logoImag setImage:[UIImage imageNamed:@"home-logo314-84.png"]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setHidden:NO];
   
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserLogin"])
    {
        //[appSharedData showCustomLoaderWithTitle:@"" message:@"Loading..."];
    }

}

-(void)viewDidDisappear:(BOOL)animated
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserLogin"]){
        //[appSharedData removeLoadingView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([appDelegate signUpCompleted]) {
        AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
        appdel.signUpCompleted = NO;
        [self showSinInView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSinInView{
    SignInViewController*signInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
    [self presentViewController:signInVC animated:YES completion:nil];
}

- (void)getFBUserFromSession:(FBSession *)session
{
    [FBSession setActiveSession:session];
    [[[FBRequest alloc] initWithSession:session graphPath:@"me"] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)           {
         if (!error) {
             
             NSDictionary *fbData =  @{        @"id" : (user.id ? user.id : @"") ,
                                               @"email" : ([user valueForKey:@"email"] ? [user valueForKey:@"email"] : @""),
                                               @"last_name" : (user.last_name ? user.last_name : @"") ,
                                               @"username" : (user.username  ? user.username : @""),
                                               @"first_name" : (user.first_name ? user.first_name :@""),
                                               @"device_id" : [userDefaults objectForKey:DEVICE_ID] ? [userDefaults objectForKey:DEVICE_ID] :@"",
                                               @"certification_type" : [appDelegate certifcateType]
                                               
                                               };
             
             NSString *strSignUpUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_FBLogin];
             DLog(@"%s, Performing %@ api \n with parameter:%@",__FUNCTION__, strSignUpUrl,fbData);

             [serviceManager executeServiceWithURL:strSignUpUrl andParameters:fbData forTask:kTaskFbdata completionHandler:^(id response, NSError *error, TaskType task) {
                 DLog(@"%s, %@ api \n Response :%@",__FUNCTION__, strSignUpUrl,response);

                 if (!error) {
                     NSDictionary *dict = [[NSDictionary alloc]init];
                     dict = (NSDictionary *)response;
                     
                     NSLog(@"fb login response%@",response);
                     
                     NSArray *idArray = [dict objectForKey:@"data"];
                     NSLog(@"fb login response%@",idArray);

                     
                     if (![idArray valueForKey:@"member_id"]) {
                         DLog(@"Server not provide member Id");
                         return ;
                     }
                     
                      [userDefaults setBool:YES forKey:@"isUserLogin"];
                     
                     [userDefaults setObject:[idArray valueForKey:@"member_id"] forKey:KEY_USER_DEFAULTS_USER_ID];
                     
                     if ([[idArray valueForKey:@"already"] boolValue] == YES)
                      {
                         
                         [userDefaults setObject:[idArray valueForKey:@"member_role"] forKey:KEY_USER_DEFAULTS_USER_ROLE];
                         
                         [userDefaults setObject:[idArray valueForKey:@"login_name"] forKey:KEY_USER_DEFAULTS_USER_NAME];
                         [userDefaults setObject:[idArray valueForKey:@"member_city"] forKey:KEY_USER_DEFAULTS_USER_City];
                         [userDefaults setObject: ([idArray valueForKey:@"member_image"] ? [idArray valueForKey:@"member_image"]  : @"") forKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL];
                         
                         [userDefaults setObject:[idArray valueForKey:@"member_local_authority"] forKey:KEY_USER_DEFAULTS_USER_LocalAuthority];

                         UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                         activityIndicator.alpha = 1.0;
                         activityIndicator.center = CGPointMake(160, 360);
                         activityIndicator.hidesWhenStopped = NO;
                         [activityIndicator performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:5.0];
                         [activityIndicator startAnimating];
                         
                         [appDelegate initRootViewController];
                     }
                     else if ([[idArray valueForKey:@"already"] boolValue] == NO)
                     {
                         FbUpdateViewController *fbUpdateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FbUpdateViewController"];
                         //fbUpdateViewController.view.frame = CGRectMake(0,200, 320, 568);
                         
                         UINavigationController *nav = [[UINavigationController alloc]
                                                        
                                                        initWithRootViewController:fbUpdateViewController];
                         [self presentViewController:nav animated:YES completion:nil];
                         
                     }
                 } else {
                     DLog(@"%s Error:%@",__FUNCTION__,error);
                 }
             }];
         }
         else {
             
             AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
             if (appdel.doNotShowLoginPop)
                 return ;
             DLog(@"Error:%@",error);
             
              [appDelegate clearDefaultValues];
             
             [Utility showAlertMessage:@"Please go to to privacy setting. Select facebook and enable toggle button to green." withTitle:@"Facebook Alert"];
         }
     }];
}



- (IBAction)loginWithFb:(id)sender
{
    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
    appdel.doNotShowLoginPop = NO;
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    [self.view setUserInteractionEnabled:NO];

    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        [self.view setUserInteractionEnabled:YES];

        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[//@"basic_info"
                                                           @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
          // DLog(@"session:%@ \n errorrrrrr------:%@, \n localizedDescription:-----%@",session,error, error.localizedDescription);
             [self getFBUserFromSession:session];
             [self.view setUserInteractionEnabled:YES];
         }];
    }
}


- (IBAction)signIn:(id)sender {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    [self showSinInView];
}

- (IBAction)joinUs:(id)sender {
   
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    JoinUsViewController *joinVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JoinUsViewController"];
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:joinVC];
    [self presentViewController:nav animated:YES completion:nil];
}

@end

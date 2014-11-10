//
//  AppDelegate.m
//  Autism
//
//  Created by Haider on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FbUpdateViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "RootViewController.h"
#import "HomeViewController.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "Utility.h"

@interface AppDelegate ()

@property (nonatomic, assign) BOOL isPostDeviceIDApiCallSuccess;
@property (nonatomic, assign) BOOL isAppLaunching;


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.isPushNotificationsEnable = NO;
    self.isPostDeviceIDApiCallSuccess = NO;
    self.isAppLaunching = YES;
    self.isLogoutRequestPending = NO;
    self.isNeedToSetRequestPriority = YES;
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    [self setCertifacteType];
    
    //Track Network Status
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.isNetworkAvailable = (status == AFNetworkReachabilityStatusNotReachable) ? NO:YES;
        
        DLog(@"Network Reachability: %@, \n status:%d", AFStringFromNetworkReachabilityStatus(status), status);
        if (self.isNetworkAvailable && self.isLogoutRequestPending) {
            [self logoutApiCall];
        }
        if (self.isNetworkAvailable && !self.isAppLaunching && !self.isPostDeviceIDApiCallSuccess) {
            [self postAppVersionAndDeviceIDApiCall];
        }
    }];

    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    //[self clearDefaultValues];
    
    // Let the device know we want to receive push notifications

    // Register for notification according to iOS versions
    if (IOS_Version >= 8.0)
    {
        //[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
      
        //[[UIApplication sharedApplication] registerForRemoteNotifications];

    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
   
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Untitled-1.png"] forBarMetrics:UIBarMetricsDefault];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
   
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			DLog(@"Launched from push notification: %@", dictionary);
            [self showAlertAfterRemoteNotification:dictionary];
		}
	}

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserLogin"])
    {
        [self performSelector:@selector(initRootViewController) withObject:nil afterDelay:0];
    }
    else
    {
        // Create a LoginUIViewController instance where we will put the login button
        HomeViewController *customLoginViewController =[[HomeViewController alloc] init];
        self.customLoginViewController = customLoginViewController;
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self saveAPNsSetting];
    [FBSession.activeSession handleDidBecomeActive];

    if(self.isUserLoggedIn && [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]){
        [self getNotificationCountApiCall];
    }
    self.isAppLaunching = NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:application.applicationIconBadgeNumber];
    self.badgeCount = application.applicationIconBadgeNumber;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //[self clearNotifications:application];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[self clearNotifications:application];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   
    // Facebook SDK * pro-tip *
    // if the app is going away, we close the session object; this is a good idea because
    // things may be hanging off the session, that need releasing (completion block, etc.) and
    // other components in the app may be awaiting close notification in order to do cleanup
    
    //[FBSession.activeSession close];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSString *deviceID = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([Utility getValidString:deviceID].length > 0) {
        [self postAppVersionAndDeviceIDApiCall];
    }
    [userDefaults setObject:deviceID forKey:DEVICE_ID];
	DLog(@"DeviceID is: %@", deviceID);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	DLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    DLog(@"Received notification: %@", userInfo);
    [self showAlertAfterRemoteNotification:userInfo];
}

-(void)initRootViewController
{
    
    [appSharedData removeLoadingView];
    
    self.isUserLoggedIn = YES;
    UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    
    MFSideMenuContainerViewController *container = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MFSideMenuContainerViewController"];
    
    self.rootNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RootNavigationController"];
    
    UIViewController *leftSideMenuViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"LeftSideMenuViewController"];
    
    [container setLeftMenuViewController:leftSideMenuViewController];
    [container setCenterViewController:self.rootNavigationController];
    
    self.window.rootViewController = container;
    
}


- (void)clearNotifications:(UIApplication *)application{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:application.applicationIconBadgeNumber];
    self.badgeCount = application.applicationIconBadgeNumber;
}

-(void)clearDefaultValues
{
    DLog(@"Clear user defaults values");
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    [userDefaults setObject:@"" forKey:KEY_USER_DEFAULTS_USER_ID];
    [userDefaults setObject:@"" forKey:KEY_USER_DEFAULTS_USER_NAME];
    [userDefaults setObject:@"" forKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL];
    [userDefaults setObject:@"" forKey:KEY_USER_DEFAULTS_USER_ROLE];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
            DLog(@"facebook cookies delete");
        }
    }
}

-(void)setCertifacteType
{
    //Build Changes
    //Configure certifcate type before uploading build acording to build
    self.certifcateType = kCertificateDistribution;
    DLog(@"CertifcateType:%@",self.certifcateType);

//kCertificateDevelopment
//kCertificateDistribution
//kCertificateAppStore
}

-(void)showHomeScreen {
    
    self.signUpCompleted = NO;
    [self.rootNavigationController popToRootViewControllerAnimated:NO];
    UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    HomeViewController *home = [mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.window.rootViewController presentViewController:home animated:YES completion:nil];
}


-(void)userAutismSessionExpire
{
    self.isUserLoggedIn = NO;
    [appDelegate showHomeScreen];
    [appDelegate clearDefaultValues];
    [Utility showAlertMessage:@"Your current session is expired please login again." withTitle:@"Session Expired!!"];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)showSomeThingWentWrongAlert:(NSString*)message {
    if (self.someThingWentWrongAlert.isVisible)
        return;

     self.someThingWentWrongAlert = [[UIAlertView alloc] initWithTitle:kAlertMessageSomethingWrong message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [self.someThingWentWrongAlert show];
}

- (void)showNetWorkAlert
{
    if (self.networkAlert.isVisible)
        return;
    
    self.networkAlert = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [self.networkAlert show];
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    if (self.autismAlert.isVisible)
        return;
    self.autismAlert =  [[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil];
     [self.autismAlert show];
}


#pragma mark-  Push Notification Methods

- (void)showAlertAfterRemoteNotification:(NSDictionary*)userInfo {
    DLog(@"%s, APNS:%@", __FUNCTION__, userInfo);
    if([userInfo objectForKey:@"aps"])
    {
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        long count = [[aps objectForKey:@"badge"] integerValue];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
        self.badgeCount = count;
    }
}



// |isPushNotificationsEnable| check application accepts push notifications or not
- (void)saveAPNsSetting
{
    BOOL isPushNotificationsEnable;
     if (IOS_Version >= 8.0)
     {
         //isPushNotificationsEnable =  [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];

     } else
     {
         //isPushNotificationsEnable = [[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone ? NO:YES;

     }
    self.nextUpdateTimeForAPNs = isPushNotificationsEnable ? 5*60 : 60;
    //self.nextUpdateTimeForAPNs = isPushNotificationsEnable ? 60 : 60;

}

#pragma mark-  Service methods

- (void)getNotificationCountApiCall
{
    DLog(@"%s",__FUNCTION__);
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *getNotificationParameter = @{
                                               @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
                                               };
    
    NSString *getNotificationUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_GetNotificationCount];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,getNotificationUrl,getNotificationParameter);
    
    [serviceManager executeServiceWithURL:getNotificationUrl andParameters:getNotificationParameter forTask:kTaskGetNotificationCount completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,getNotificationUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                long count = [[dict objectForKey:@"notification_count"] integerValue];
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
                self.badgeCount = count;
                DLog(@"badgeCount:%ld",(long)self.badgeCount);
                
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    
}

- (void)postAppVersionAndDeviceIDApiCall
{
    DLog(@"%s",__FUNCTION__);
    if (![appDelegate isNetworkAvailable] || [Utility getValidString:[userDefaults objectForKey:DEVICE_ID]].length < 1)
        return;
    
    NSDictionary *requestParameter = @{
                                       @"device_id":[userDefaults objectForKey:DEVICE_ID] ? [userDefaults objectForKey:DEVICE_ID] :@"",
                                       @"version_no" : [Utility getValidString:[Utility appVersion]]
                                       };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_ApplicationDownload];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,requestUrl, requestParameter);
    
    [serviceManager executeServiceWithURL:requestUrl andParameters:requestParameter forTask:kTaskPushApplicationDownload completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s,%@ api \n response:%@",__FUNCTION__,requestUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.isPostDeviceIDApiCallSuccess = YES;
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    
}

-(void)logoutApiCall
{

    if (!(([Utility getValidString:self.loggedInMemberID].length) > 0 && [userDefaults objectForKey:DEVICE_ID] && [appDelegate certifcateType]))
        return;
    NSDictionary *logoutApiParameter = @{  @"member_id": self.loggedInMemberID,
                                           @"device_id": [userDefaults objectForKey:DEVICE_ID] ? [userDefaults objectForKey:DEVICE_ID] :@"",
                                           @"certification_type" : [appDelegate certifcateType]
                                           };
    
    
    self.isLogoutRequestPending = NO;
    self.loggedInMemberID = @"";
    
    NSString *logoutApiUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_Logout];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__, logoutApiUrl, logoutApiParameter);
    
    [serviceManager executeServiceWithURL:logoutApiUrl andParameters:logoutApiParameter forTask:kTaskLogout completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,logoutApiUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                DLog(@"User logout Successfully");
                
            }else {
            }
        }else{
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

-(void)signin
{    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
else{
        
        NSDictionary *signInParameters =@{ @"u_email" : [userDefaults stringForKey:kUserEmailUserDefault],
                                           @"u_password" :[userDefaults stringForKey: kUserPasswordUserDefault],
                                           @"device_id" : [userDefaults objectForKey:DEVICE_ID] ? [userDefaults objectForKey:DEVICE_ID] :@"",
                                           @"certification_type" : [appDelegate certifcateType]
                                           };
        NSString *signInUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_Login];
        //Build Changes - Always comment with parameter log
        // DLog(@"Performing %@ api, \n with parameter:%@",signInUrl,signInParameters);
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
}


@end

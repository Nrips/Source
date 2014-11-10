//
//  RootViewController.m
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "FbUpdateViewController.h"
#import "AppDelegate.h"
#import "MKNumberBadgeView.h"
#import "Utility.h"
#import "WYPopoverController.h"
#import "NotificationViewController.h"
#import "Notification.h"
#import "FindPeopleViewController.h"
#import "FindProviderViewController.h"

#import "Tab3ViewController.h"

@interface RootViewController ()<WYPopoverControllerDelegate, NotificationViewControllerDelegate>
{
      UIButton *btnNotification;
      UIButton *btnMenu;
      BOOL btnCheck;
      WYPopoverController *notificationListPopoverController;
}

@property (nonatomic, strong) UINavigationController *tab1NavController;
@property (nonatomic, strong) UINavigationController *tab2NavController;
@property (nonatomic, strong) UINavigationController *tab3NavController;
@property (nonatomic, strong) UINavigationController *tab4NavController;

@property(nonatomic,strong) HomeViewController *homeView;

@property (weak, nonatomic) IBOutlet UIButton *btnTab1;
@property (weak, nonatomic) IBOutlet UIButton *btnTab2;
@property (weak, nonatomic) IBOutlet UIButton *btnTab3;
@property (weak, nonatomic) IBOutlet UIButton *btnTab4;
@property (strong) MKNumberBadgeView *notificationBadgeView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) Notification *notification;
@property (nonatomic, strong) AppDelegate *appDel;

- (IBAction)notificationButtonPressed:(id)sender;
- (IBAction)tabBtnAction:(id)sender;
@end

@implementation RootViewController

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
    
    self.appDel = [[UIApplication sharedApplication] delegate];
    DLog(@"%s",__FUNCTION__);
    
    [self.appDel addObserver:self forKeyPath:@"badgeCount" options:NSKeyValueObservingOptionNew context:nil];
    [self.appDel addObserver:self forKeyPath:@"isUserLoggedIn" options:NSKeyValueObservingOptionNew context:nil];

    [self performSelectorOnMainThread:@selector(scheduleTimer) withObject:nil waitUntilDone:NO];

    self.navigationController.navigationBarHidden = YES;
    
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView setFrame:CGRectMake(0,0, 320 , 64)];
    UIImage *image =[UIImage imageNamed:@"top-bar-bg.fw.png"];
    imgView.image = image;
    [self.view addSubview:imgView];
    
    
    UIImageView *imgViewLogo = [[UIImageView alloc] init];
    [imgViewLogo setFrame:CGRectMake(103, 22, 114, 30)]; 
    UIImage *imageLogo =[UIImage imageNamed:@"autism_logo.png"];
    imgViewLogo.image = imageLogo;
    [self.view addSubview:imgViewLogo];
    
    
    UIButton *buttonMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonMenu.frame = CGRectMake(3, 23, 40, 34);
    [buttonMenu setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [buttonMenu addTarget:self action:@selector(sideMenuEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonMenu];
    

    UIImageView *personImgView = [[UIImageView alloc] init];
    [personImgView setFrame:CGRectMake(263, 23, 50, 34)];
    UIImage *personImg =[UIImage imageNamed:@"notification.png"];
    personImgView.image = personImg;
    [self.view addSubview:personImgView];
    
    self.notificationBadgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(262,
                                                                                     5,
                                                                                     74,
                                                                                     40)];
    self.notificationBadgeView.hideWhenZero = YES;

    [self.view addSubview:self.notificationBadgeView];
    [self updateBadgeCount];
    [self getNotificationCountApiCall];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(255, 20, 60, 38);
    //[button setImage:[UIImage imageNamed:@"notification.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(notificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    self.tab4NavController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tab4NavigationController"];
    [self.tab4NavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width, self.rootView.frame.size.height)];
    [self.tab4NavController.view setHidden:YES];
    [self.rootView addSubview:self.tab4NavController.view];
    
    self.tab3NavController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tab3NavigationController"];
    [self.tab3NavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width, self.rootView.frame.size.height)];
    [self.tab3NavController.view setHidden:YES];
    [self.rootView addSubview:self.tab3NavController.view];
    
    
    
    self.tab2NavController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tab2NavigationController"];
    [self.tab2NavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width, self.rootView.frame.size.height)];
    [self.tab2NavController.view setHidden:YES];
    [self.rootView addSubview:self.tab2NavController.view];
    
    self.tab1NavController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tab1NavigationController"];
    [self.tab1NavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width, self.rootView.frame.size.height)];
    [self.tab1NavController.view setHidden:YES];
    [self.rootView addSubview:self.tab1NavController.view];
    
    [self tabBtnAction:self.btnTab1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [ super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}



-(void) viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //TODO search better option
    //[appDelegate removeObserver:self forKeyPath:@"badgeCount"];
    //[appDelegate removeObserver:self forKeyPath:@"isUserLoggedIn"];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isUserLoggedIn"] )
    {
        [self userLoggedOut];
    }
    if ([keyPath isEqualToString:@"badgeCount"] )
    {
        [self updateBadgeCount];
    }
}


- (void)scheduleTimer
{
	assert([NSThread isMainThread]);
    
	if (self.timer && [self.timer isValid])
	{
		[self.timer invalidate];
	}
    
    DLog(@"nextUpdateTimeForAPNs: %f", [appDelegate nextUpdateTimeForAPNs]);
	self.timer = [NSTimer scheduledTimerWithTimeInterval:[appDelegate nextUpdateTimeForAPNs]
												  target:self
												selector:@selector(getNotificationCountApiCall)
												userInfo:nil
												 repeats:NO];
}


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
        DLog(@"%s,%@ api \n response:%@",__FUNCTION__,getNotificationUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                dispatch_async(dispatch_get_main_queue(),^{
                    long count = [[dict objectForKey:@"notification_count"] integerValue];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
                    [self updateBadgeCount];
                });
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else{
                DLog(@"Error:%@",error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
    }];
    [self performSelectorOnMainThread:@selector(scheduleTimer) withObject:nil waitUntilDone:NO];

}

- (IBAction)tabBtnAction:(id)sender {
    
    [self.tab1NavController.view setHidden:YES];
    [self.tab2NavController.view setHidden:YES];
    [self.tab3NavController.view setHidden:YES];
    [self.tab4NavController.view setHidden:YES];

    switch ([sender tag]) {
        case 1:
        {
            [self.tab1NavController.view setHidden:NO];
            
            [_btnTab1 setImage: [UIImage imageNamed:@"home-active.fw.png"] forState:UIControlStateNormal];
            [_btnTab2 setImage: [UIImage imageNamed:@"event.fw.png"] forState:UIControlStateNormal];
            [_btnTab3 setImage: [UIImage imageNamed:@"q+a.fw.png"] forState:UIControlStateNormal];
            [_btnTab4 setImage: [UIImage imageNamed:@"find.fw.png"] forState:UIControlStateNormal];
            self.appDel.strKeyboardHideNotificationName =  kHideKeyboardFromPostViewController;

        }
            break;
            
        case 2:
        {
            [self.tab2NavController.view setHidden:NO];
            
            [_btnTab2 setImage: [UIImage imageNamed:@"event-menu-active.png"] forState:UIControlStateNormal];
            
            [_btnTab1 setImage: [UIImage imageNamed:@"home.fw.png"] forState:UIControlStateNormal];
            [_btnTab3 setImage: [UIImage imageNamed:@"q+a.fw.png"] forState:UIControlStateNormal];
            [_btnTab4 setImage: [UIImage imageNamed:@"find.fw.png"] forState:UIControlStateNormal];
        }

            
            break;
            
        case 3:
            [self.tab3NavController.view setHidden:NO];
            
            [_btnTab3 setImage: [UIImage imageNamed:@"q+a-active.fw.png"] forState:UIControlStateNormal];
            
            [_btnTab1 setImage: [UIImage imageNamed:@"home.fw.png"] forState:UIControlStateNormal];
            [_btnTab2 setImage: [UIImage imageNamed:@"event.fw.png"] forState:UIControlStateNormal];
            [_btnTab4 setImage: [UIImage imageNamed:@"find.fw.png"] forState:UIControlStateNormal];

            self.appDel.strKeyboardHideNotificationName = kHideKeyboardFromTab3ViewController;

            break;
            
        case 4:
            [self.tab4NavController.view setHidden:NO];
            
            [_btnTab4 setImage: [UIImage imageNamed:@"find-active.fw.png"] forState:UIControlStateNormal];
            
            [_btnTab1 setImage: [UIImage imageNamed:@"home.fw.png"] forState:UIControlStateNormal];
            [_btnTab3 setImage: [UIImage imageNamed:@"q+a.fw.png"] forState:UIControlStateNormal];
            [_btnTab2 setImage: [UIImage imageNamed:@"event.fw.png"] forState:UIControlStateNormal];
 
            self.appDel.strKeyboardHideNotificationName =  self.appDel.isFindPeopleTabSelected ? kHideKeyboardFromFindPeopleViewController : kHideKeyboardFromFindProviderViewController;
            
            break;
            
        default:
            break;
    }
}

-(void)sideMenuEvent:(id)sender
{
   [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
    
    //Post Keyboard hiding notification
    DLog(@"KeyboardHideNotificationName:%@",self.appDel.strKeyboardHideNotificationName);
    [[NSNotificationCenter defaultCenter] postNotificationName:self.appDel.strKeyboardHideNotificationName object:nil];
}


-(void)updateBadgeCount
{
    //Notification Badge

    //Code For Testing Purpose
   /* if ([UIApplication sharedApplication].applicationIconBadgeNumber > 9) {
        
        self.notificationBadgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(265,
                                                                                         5,
                                                                                         74,
                                                                                         40)];
        
    } else {
         self.notificationBadgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(262,
                                                                                          5,
                                                                                          74,
                                                                                          40)];

     }*/
    
    //self.notificationBadgeView.value = 11;
    self.notificationBadgeView.value = [UIApplication sharedApplication].applicationIconBadgeNumber;

    DLog(@"Notification badge count:%lu",(unsigned long)self.notificationBadgeView.value);
}

- (void)userLoggedOut
{
    if (self.timer && [self.timer isValid])
	{
		[self.timer invalidate];
        self.timer = nil;
	}
    [appDelegate removeObserver:self forKeyPath:@"badgeCount"];
    [appDelegate removeObserver:self forKeyPath:@"isUserLoggedIn"];
}



#pragma mark - NotificationListPopoverMethods

- (IBAction)notificationButtonPressed:(id)sender {
    
    UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    
    NotificationViewController *notificationVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    notificationVC.delegate = self;
    notificationVC.title = @"Notifications";
    
    [UIView animateWithDuration:1.00
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                         [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
                     }];
    [[appDelegate rootNavigationController] pushViewController:notificationVC animated:NO];
    
}

- (void)close:(id)sender
{
    [notificationListPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:notificationListPopoverController];
        [self showSelecticatedController];
    }];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    notificationListPopoverController.delegate = nil;
    notificationListPopoverController = nil;
}

- (void)notificationCellDidSelectedNotification:(Notification*)notification
{
    self.notification = notification;
    //[self close:nil];
}

- (void)showSelecticatedController
{
    
}
@end

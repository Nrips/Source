//
//  AppDelegate.h
//  Autism
//
//  Created by Haider on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "RootViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PostViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, assign) BOOL isNetworkAvailable;
@property (nonatomic, assign) BOOL isNeedToSetRequestPriority;
@property (nonatomic, assign) BOOL isLogoutRequestPending;
@property (nonatomic, assign) BOOL isFindPeopleTabSelected;
@property (nonatomic, strong) NSString *loggedInMemberID; // Store memberId if login call not successful
@property (nonatomic, strong) NSString *strKeyboardHideNotificationName; //Its value indicate in which controller post Notifcation for keybord hiding
@property (nonatomic, strong) NSString *strApiCallNotificationName;
@property(strong,nonatomic)NSString *strchek;


@property (nonatomic, strong) PostViewController *sendMessageVC;
@property (nonatomic, strong) PostViewController *sendDetailMessageVC;
@property (nonatomic, strong) PostViewController *postUpdateToOtherVC;
@property (nonatomic, strong) PostViewController *postVC;
@property (nonatomic, strong) NSMutableArray *memberListArray;

@property (nonatomic, strong) UIAlertView *someThingWentWrongAlert;
@property (nonatomic, strong) UIAlertView *networkAlert;
@property (nonatomic, strong) UIAlertView *autismAlert;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *rootNavigationController;
@property (strong, nonatomic) HomeViewController *customLoginViewController;
@property (nonatomic) BOOL signUpCompleted;
@property (nonatomic) BOOL doNotShowLoginPop;
@property (nonatomic) BOOL isPostUploadTaskRunning;
@property (nonatomic) BOOL isPostUploadInboxMessageTaskRunning;
@property (nonatomic) BOOL isPostUploadOtherTaskRunning;
@property (nonatomic) BOOL isPostUploadMyTaskRunning;
@property (nonatomic) BOOL isPostAddPhotosTaskRunning;

@property (nonatomic, assign) NSInteger badgeCount;
@property (strong, nonatomic) NSString *certifcateType;
@property (nonatomic) BOOL isUserLoggedIn;
@property (nonatomic, assign) NSTimeInterval nextUpdateTimeForAPNs;

@property (weak, nonatomic) NSString *strActivityId;

- (void)clearDefaultValues;
- (void)initRootViewController;
- (void)showHomeScreen;
- (void)showSomeThingWentWrongAlert:(NSString*)message;
- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title;
- (void)showNetWorkAlert;
- (void)userAutismSessionExpire;
@end

//
//  HomeViewController.h
//  Autism
//
//  Created by Vikrant Jain on 1/24/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<FacebookSDK/FacebookSDK.h>

@interface HomeViewController : UIViewController



@property (strong, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutlet UIButton *btnJoinUs;
@property (strong, nonatomic) IBOutlet UIButton *btnfbSignIn;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (void)getFBUserFromSession:(FBSession *)session;
- (IBAction)signIn:(id)sender;
- (void)showSinInView;
@end

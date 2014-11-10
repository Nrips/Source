//
//  ProfileShowViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/25/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
@protocol ProfileShowViewControllerDelegate<NSObject>

@optional
- (void)updateUsersProfileImage:(UIImage *)image;

@end

@interface ProfileShowViewController : UIViewController

@property (nonatomic,weak) id<ProfileShowViewControllerDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnMyStory;
@property (strong, nonatomic) IBOutlet UIButton *btnMyFamily;
@property (strong, nonatomic) IBOutlet UIButton *MyCircle;
@property (strong, nonatomic) IBOutlet UIButton *MyEvents;
@property (strong, nonatomic) IBOutlet UIButton *btnMyQA;
@property (strong, nonatomic) IBOutlet UIButton *BtnPostUpdate;
@property (strong, nonatomic) IBOutlet UIButton *BtnMyRecentActivity;


@property (strong, nonatomic) IBOutlet UIButton *BtnOtherPostUpdate;
@property (strong, nonatomic) IBOutlet UIButton *BtnAddToCircle;
@property (strong, nonatomic) IBOutlet UIButton *BtnSendMessage;
@property (strong, nonatomic) IBOutlet UIButton *BtnBlockMember;

@property (strong, nonatomic) IBOutlet UIButton *btnMyPicture;
@property (strong, nonatomic) IBOutlet MyImageView *imgProfilePicture;
@property (nonatomic,strong) IBOutlet UITableView *tablePostActivity;

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblCity;
@property (strong, nonatomic) IBOutlet UILabel *lblRole;


@property(nonatomic,strong) NSString *profileImage;
@property(nonatomic,strong) NSString *strUserName;
@property(nonatomic,strong) NSString *strAllUserMemberKey;
@property (strong, nonatomic) NSString *profileType;
@property (strong, nonatomic) NSString *strCity;
@property (strong, nonatomic) NSString *strLocalAuthority;
@property(nonatomic,strong) NSString *otherUserId;
@property (strong, nonatomic) NSString *strNameRole;
@property (nonatomic) BOOL isMemberAlreadyCircle;
@property (nonatomic) BOOL isMemeberBlocked;
@property (nonatomic, strong) NSString *parentViewControllerName;


- (IBAction)mystoryEvent:(id)sender;
- (IBAction)myFamilyEvent:(id)sender;
- (IBAction)mycircleEvent:(id)sender;
- (IBAction)myEventsAction:(id)sender;
- (IBAction)myPictureEvent:(id)sender;

@end

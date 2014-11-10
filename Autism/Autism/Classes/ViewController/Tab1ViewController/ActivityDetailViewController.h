//
//  ActivityDetailViewController.h
//  Autism
//
//  Created by Dipak on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTweetLabel.h"

@protocol ActivityDetailViewControllerDelegate <NSObject>
- (void)activtyDeleted;
- (void)userLikeActivitySuccessfully;
- (void)activityChanges:(NSString *)activityMemberId :(NSString *)activityId:(BOOL)isLike :(BOOL)isHug:(BOOL)isInCircle:(BOOL)isBolkMember:(BOOL)isReportAwm;

@optional
-(void)replyButtonPressed :(NSString *)activityID buttonState:(BOOL)selected;

@end
@interface ActivityDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) id <ActivityDetailViewControllerDelegate>delegate;
@property(nonatomic, strong)  NSString *activityID;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *commentTime;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSArray *activityTagArray;
@property (strong, nonatomic) NSString *activityMemberid;
@property (nonatomic,strong) NSMutableArray *imagesArray;


@property(nonatomic,strong) NSString *attachLinkUrl;
@property(nonatomic,strong) NSString *attachLinkThumbnailImageUrl;

@property(nonatomic,strong) NSString *videoUrl;
@property(nonatomic,strong) NSString *videoThumbnailImageUrl;
@property(nonatomic,strong) NSString *AttachVideoUrl;
@property (nonatomic, strong)NSString*parentViewControllerName;


@property(nonatomic,strong) NSString *wallPostUserName;
@property(nonatomic,strong) NSString *wallPostuserId;
@property(nonatomic) BOOL isWallPost;

@property (nonatomic) BOOL isSelfActivity;


@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIButton *btncomment;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) IBOutlet UIButton *btnHug;

@property (strong, nonatomic) IBOutlet STTweetLabel *lblHeaderComment;

@property(nonatomic) BOOL isMemberActivityLike;
@property(nonatomic) BOOL isMemberActivityHug;

@property(nonatomic,assign) BOOL likeValue;
@property(nonatomic,assign) BOOL hugValue;
@property(nonatomic,assign) BOOL isLike;
@property(nonatomic,assign) BOOL isHug;

@property(nonatomic)BOOL isMemberActivityReported;
@property (nonatomic)BOOL isMemberAlreadyInCircle;
@property(nonatomic) BOOL isMemeberBlocked;

@property(nonatomic,strong) NSString *strMessage;
@property(nonatomic,strong) NSString *strActivityId;
@property(nonatomic,strong) NSString *activityMemberId;


- (IBAction)likeAction:(id)sender;
- (IBAction)hugAction:(id)sender;
- (IBAction)shareAction:(id)sender;

@end

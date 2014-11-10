//
//  ActivityDetailHeaderViewCell.h
//  Autism
//
//  Created by Neuron Solutions on 9/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTweetLabel.h"
#import "MyImageView.h"
#import "ActivityDetails.h"

@protocol ActivityDetailHeaderViewCellDelegate <NSObject>

-(void)commentButtonPressed :(NSString *)activityID buttonState:(BOOL)selected;
-(void)clickOnShare:(NSString*)activityID;
-(void)clickOnLike:(NSString*)activityID;
-(void)clickOnhug:(NSString*)activityID;
-(void)clickOnMemeberName:(NSString*)activityID;
-(void)videoPlayButtonPressedWithUrl:(NSString*)videoUrl;
-(void)showReportToAWMViewWithReportID:(NSString*)reportID;
-(void)activityDeletedFromActivityView;
-(void)memberSuccessfullyBlocked:(BOOL)isBlockMember;
-(void)memberSuccessfullyAddedInCircle:(BOOL)isInCircle;
-(void)memberSuccessfullyLike:(BOOL)isLikevalue;
-(void)memberSuccessfullyHug:(BOOL)isHug;

@end

@interface ActivityDetailHeaderViewCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *arrayImages;
    
}
// For set value on header view
-(void)passHeaderValue:(NSString*)strName time:(NSString *)strActivitPostTime activityDetail:(NSString *)activityDetail
          activityID:(NSString *)activityId profileImage:(NSString *)imageUrl likeValue:(BOOL)like hugValue:(BOOL)hug activityTagArray:(NSArray *)tagArray headerHeight:(float)height memberID:(NSString *)strMemberId  attachLink:(NSString*)strAttachLink imageAttachLink:(NSString*)strImageAttachLink vedioLink:(NSString*)strVedioLink  vedioLinkImage:(NSString*)strVedioLinkImage imageArray:(NSMutableArray*)arrImages memberBlocked:(BOOL)Blocked isSelfActivity:(BOOL)selfActivity isActivityMemberReport:(BOOL)repoted isMemberInCircle:(BOOL)circleStatus attachVedioLink:(NSString*)strAttachVedioLink WallPostUserName:(NSString*)otherUSerName wallPostUserId:(NSString*)otherUserId isWallPost:(BOOL)wallPost;


@property (nonatomic,weak) id <ActivityDetailHeaderViewCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIButton *btncomment;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) IBOutlet UIButton *btnHug;

@property(nonatomic) BOOL isMemberActivityLike;
@property(nonatomic) BOOL isMemberActivityHug;

@property(nonatomic,assign) BOOL likeValue;
@property(nonatomic,assign) BOOL hugValue;
@property(nonatomic,assign) BOOL isLike;
@property(nonatomic,assign) BOOL isHug;
@property(nonatomic,assign) BOOL shareActivity;
@property(nonatomic) BOOL isWallPost;
@property(nonatomic,assign) BOOL isChange;



//@property(nonatomic,strong)NSString *activityId;
@property (strong ,nonatomic) UIFont* activityFont;

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet MyImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgTimeClock;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIView *buttonBarView;

@property (strong, nonatomic) IBOutlet UITextView *txtviewVideoUrl;
@property (strong, nonatomic) IBOutlet UILabel *lblVideoUrl;

@property(nonatomic)BOOL isMemberActivityReported;
@property(nonatomic)BOOL isSelfMemberActivity;
@property (nonatomic)BOOL isMemberAlreadyInCircle;
@property(nonatomic) BOOL isMemeberBlocked;

@property(nonatomic,strong) NSString *strMessage;
@property(nonatomic,strong) NSString *strActivityId;
@property(nonatomic,strong) NSString *activityMemberId;
@property(nonatomic,strong) NSArray *activityTag;
@property(nonatomic,strong) NSString *activityAttachLinkSting;
@property(nonatomic,strong) NSString *parentViewControllerName;
@property(nonatomic,strong) NSString *wallPostMemberId;
@property (nonatomic,strong) NSMutableArray *imagesArray;
/*@property(nonatomic,strong) NSString *attachLinkUrl;
@property(nonatomic,strong) NSString *attachLinkThumbnailImageUrl;
@property(nonatomic,strong) NSString *videoUrl;
@property(nonatomic,strong) NSString *videoThumbnailImageUrl;*/

@property(nonatomic,strong) NSString *videoUrl;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet STTweetLabel *lblDetail;
@property (strong, nonatomic) IBOutlet STTweetLabel *lblAttachLink;
@property (nonatomic, strong)IBOutlet MyImageView *imageAttachLink;
@property (strong, nonatomic) IBOutlet UILabel *lblWebsite;
@property (strong, nonatomic) IBOutlet UILabel *lblOtherUSerName;
@property (strong, nonatomic) IBOutlet UILabel *lblSign;


@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) MyImageView *imageView;
@property (nonatomic, strong)IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *btnAttachImage;
@property (nonatomic,assign) NSInteger currentRowAtIndex;

@property (weak, nonatomic) IBOutlet UIButton *memberNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherMemberNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic) IBOutlet MyImageView *videoThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnReportToAWM;
@property (weak, nonatomic) IBOutlet UIButton *removeActivityButton;

@property(nonatomic, strong) UIActionSheet *actionSheet;


- (IBAction)removeActivtyButtonPressed:(id)sender;
- (IBAction)memberNameBtnPressed:(id)sender;
- (IBAction)videoPlayButtonPressed:(id)sender;

- (IBAction)likeAction:(id)sender;
- (IBAction)hugAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)commentAction:(id)sender;


@end

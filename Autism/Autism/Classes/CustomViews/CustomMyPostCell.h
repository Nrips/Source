//
//  CustomMyPostCell.h
//  Autism
//
//  Created by Neuron-iPhone on 3/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetMyActivity.h"
#import "CustomEventDetailCell.h"
#import "MyImageView.h"
#import "MemberInCircle.h"
#include "STTweetLabel.h"

@protocol CustomMyPostCellDelegate <NSObject>

@optional

- (void)activityDeletedFromActivityView;
- (void)memberSuccessfullyBlocked:(BOOL)circleBlock:(NSString*)blockMemberID;
- (void)memberSuccessfullyAddedInCircle:(BOOL)circleStatus :(NSString*)memberID;
- (void)replyButtonPressedAtRow :(long)row withQuestionID:(NSString *)questionID buttonState:(BOOL)selected;
- (void)showReportToAWMViewWithReportID:(NSString*)reportID;
- (void)userLikeActivitySuccessfully:(BOOL)isLikeValue:(NSString*)activityId;
- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forMyActivity:(GetMyActivity *)myActivity;
- (void)clickOnMemeberName:(NSString*)memeberID;
- (void)videoPlayButtonPressedWithUrl:(NSString*)videoUrl;

@end

@interface CustomMyPostCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>
{
  NSMutableArray *arrayImages;

}

-(void)configureCell:(GetMyActivity *)myActivity activityDetailLabelHeight:(float)commentLabelHeight attachLinkHeight:(float)attachLinkLabelHeight  andCellHeight:(float)cellHeight;

+ (CustomMyPostCell *)cellFromNibNamed:(NSString *)nibName;

@property(nonatomic,assign) BOOL likeValue;
@property(nonatomic,assign) BOOL hugValue;
@property(nonatomic,assign) BOOL isLike;
@property(nonatomic,assign) BOOL isHug;
@property(nonatomic)BOOL isMemberActivityReported;
@property(nonatomic)BOOL isSelfMemberActivity;
@property (nonatomic)BOOL isMemberAlreadyInCircle;
@property(nonatomic) BOOL isMemeberBlocked;
@property(nonatomic) BOOL isWallPost;



@property(nonatomic,strong) NSString *strMessage;
@property(nonatomic,strong) NSString *strActivityId;
@property(nonatomic,strong) NSString *activityMemberId;
@property(nonatomic,strong) NSString *wallPostMemberId;
@property(nonatomic,strong) NSArray *activityTag;
@property(nonatomic,strong) NSString *activityAttachLinkSting;
@property (nonatomic, strong) NSString *parentViewControllerName;

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblOtherUSerName;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblSign;
@property (strong, nonatomic) IBOutlet STTweetLabel *lblDetail;
@property (strong, nonatomic) IBOutlet STTweetLabel *lblAttachLink;
@property (nonatomic, strong)IBOutlet MyImageView *imageAttachLink;
@property (strong, nonatomic) IBOutlet UILabel *lblWebsite;


@property (nonatomic, strong)IBOutlet UIView *buttonBarView;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) MyImageView *imageView;

@property (weak, nonatomic) IBOutlet UIImageView *imgTimeClock;
@property (nonatomic, strong)IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong)IBOutlet UIImageView *arrowImageView;

@property (strong, nonatomic) IBOutlet UITextView *txtviewVideoUrl;
@property (strong, nonatomic) IBOutlet UILabel *lblVideoUrl;



@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIButton *btncomment;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) IBOutlet UIButton *btnHug;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *btnAttachImage;


@property (nonatomic,weak) id<CustomMyPostCellDelegate>delegate;
@property (nonatomic,assign) NSInteger currentRowAtIndex;

- (IBAction)likeAction:(id)sender;
- (IBAction)hugAction:(id)sender;
- (IBAction)shareAction:(id)sender;

@end

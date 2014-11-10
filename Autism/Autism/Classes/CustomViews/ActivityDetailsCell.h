//
//  ActivityDetailsViewCellTableViewCell.h
//  Autism
//
//  Created by Dipak on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "ActivityDetails.h"
#import "STTweetLabel.h"

@protocol ActivityDetailsCellDelegate <NSObject>
- (void)activityCommentDeleted;
- (void)activityCommentUpdated;
- (void)activityCommentLike;
- (void)activityCommentHug;
- (void)replyButtonPressedAtRow :(long)row withActivityID:(NSString *)ActivityID ActivityText:(NSString *)activityText  andActivityTagArray:(NSArray *)activityTagArray buttonState:(BOOL)selected;
- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forActivity:(ActivityDetails *)activity;
- (void)clickOnMemeberName:(NSString*)memeberID;


@end

@interface ActivityDetailsCell : UITableViewCell

@property (nonatomic,weak) id <ActivityDetailsCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet UITextView* commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *commentedUserName;
@property (weak, nonatomic) IBOutlet UILabel *commentTime;
@property (weak, nonatomic) IBOutlet MyImageView *commentedUserProfileView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *removeActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *editActivityButton;
@property (weak, nonatomic) IBOutlet STTweetLabel *lblcomment;

@property (nonatomic, strong) NSString *activityCommentID;
@property (nonatomic, strong) NSString *activityCommentMemberID;
@property (nonatomic, strong) NSString *activityCommentText;
@property(nonatomic,strong) NSArray *actTagArray;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgGrayImageView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;



-(void)configureCell:(ActivityDetails *)activityDetails;

-(void)configureActivityDetailCell:(ActivityDetails *)activityDetails detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;

+(ActivityDetailsCell*)cellFromNibNamed:(NSString *)nibName;

@end

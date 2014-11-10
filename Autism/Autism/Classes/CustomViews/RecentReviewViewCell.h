//
//  RecentReviewViewCell.h
//  Autism
//
//  Created by Neuron Solutions on 5/26/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProviderDetail.h"
#import "MyImageView.h"

@interface RecentReviewViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblReview;
@property (weak, nonatomic) IBOutlet UILabel *reviewUserName;
@property (weak, nonatomic) IBOutlet UILabel *ratinng;
@property (weak, nonatomic) IBOutlet MyImageView *reviewUserProfileView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgMainImageView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;


@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *activityCommentMemberID;
@property (nonatomic, strong) NSString *serviceRating;

@property (strong, nonatomic) IBOutlet UIButton *btnAddToCircle;
@property (strong, nonatomic) IBOutlet UIButton *btnStar1;
@property (strong, nonatomic) IBOutlet UIButton *btnStar2;
@property (strong, nonatomic) IBOutlet UIButton *btnStar3;
@property (strong, nonatomic) IBOutlet UIButton *btnStar4;
@property (strong, nonatomic) IBOutlet UIButton *btnStar5;


//-(void)configureCell:(ProviderDetail *)Details;
-(void)configureCell:(ProviderDetail *)review ViewReviewLabelHeight:(float)reviewlabelHeight andCellHeight:(float)cellHeight;
-(void)configureServiceCell:(ProviderDetail *)Details;

+(RecentReviewViewCell*)cellFromNibNamed:(NSString *)nibName;


@end

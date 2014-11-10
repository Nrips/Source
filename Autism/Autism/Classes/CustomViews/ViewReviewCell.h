//
//  ViewReviewCell.h
//  Autism
//
//  Created by Neuron Solutions on 5/29/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewReview.h"
#import "WriteReviewView.h"

@protocol ViewReviewCellDelegate <NSObject>

@optional

- (void)editButtonPressedAtRow:(NSString*)reviewText:(NSString*)reviewRating:(NSString*)reviewId;
- (void)reviewDeletedFromReviewView;


@end

@interface ViewReviewCell : UITableViewCell <WriteReviewViewDelegate>

+(ViewReviewCell *)cellFromNibNamed:(NSString *)nibName;
-(void)configureCell:(ViewReview *)review ViewReviewLabelHeight:(float)reviewlabelHeight andCellHeight:(float)cellHeight;

@property (nonatomic,weak) id <ViewReviewCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *lblAnswer;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;


@property (strong, nonatomic) IBOutlet UIButton *btnStar1;
@property (strong, nonatomic) IBOutlet UIButton *btnStar2;
@property (strong, nonatomic) IBOutlet UIButton *btnStar3;
@property (strong, nonatomic) IBOutlet UIButton *btnStar4;
@property (strong, nonatomic) IBOutlet UIButton *btnStar5;
@property (strong, nonatomic) IBOutlet UIImageView *bgImage;
@property (strong, nonatomic) IBOutlet UIView *buttonView;

@property (nonatomic, strong) NSString *serviceRating;
@property (nonatomic, strong) NSString *reviewText;
@property (nonatomic, strong) NSString *serviceReviewId;
@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic) BOOL isSelfReview;

@property (strong, nonatomic) IBOutlet UIButton *btnEditReview;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteReview;

@property(strong,nonatomic)UIView* view;
-(IBAction)deleteAction:(id)sender;
-(IBAction)editAction:(id)sender;

@end

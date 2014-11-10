//
//  RecentReviewViewCell.m
//  Autism
//
//  Created by Neuron Solutions on 5/26/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "RecentReviewViewCell.h"
#import "ProviderServices.h"

@implementation RecentReviewViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (RecentReviewViewCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    RecentReviewViewCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[RecentReviewViewCell class]]) {
            customCell = (RecentReviewViewCell*)nibItem;
            break;
        }
    }
  
    return customCell;
}




-(void)configureCell:(ProviderDetail *)review ViewReviewLabelHeight:(float)reviewlabelHeight andCellHeight:(float)cellHeight
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    DLog(@"review cell hight %f", cellFrame.size.height);
    CGRect frame = self.lblReview.frame;
    frame.size.height = reviewlabelHeight;
    self.lblReview.frame = frame;
    
    
    CGRect buttonViewFrame = self.buttonView.frame;
    buttonViewFrame.origin.y = self.lblReview.frame.origin.y + reviewlabelHeight + REVIEWCELL_CONTENT_MARGIN;
    self.buttonView.frame= buttonViewFrame;
    
    CGRect frame1 = self.bgImageView.frame;
    frame1.size.height = cellHeight;
    self.bgImageView.frame = frame1;
    
    CGRect frame2 = self.bgMainImageView.frame;
    frame2.size.height = cellHeight;
    self.bgMainImageView.frame = frame2;

    
    [self.lblReview setText:review.reviewDetail];
    [self.reviewUserName setText:review.reviewMemberName];
    [self.reviewUserProfileView configureImageForUrl:review.reviewMemberImage];
     self.serviceRating = review.serviceRating;
    [self showStarRating];
}

- (void)showStarRating
{
    BOOL showHalfRating = NO;
    int rating = [self.serviceRating floatValue];
    float floatRating = [self.serviceRating floatValue];
    
    if (ceilf(floatRating) > floorf(floatRating)) {
        showHalfRating = YES;
    }
    for(int i = 1; i <=5; i++) {
        UIButton *button = (UIButton*)[self.contentView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-normal.png"] forState:UIControlStateNormal];
    }
    
    for(int i = 1; i <=rating ; i++) {
        UIButton *button = (UIButton*)[self.contentView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-active.png"] forState:UIControlStateNormal];
    }
    if (showHalfRating) {
        UIButton *button = (UIButton*)[self.contentView viewWithTag: rating+1];
        [button setBackgroundImage:[UIImage imageNamed:@"star-half-selected.png"] forState:UIControlStateNormal];
    }
}

-(void)configureServiceCell:(ProviderServices *)providerServices
{
    [self.lblReview setText:providerServices.serviceName];
}

@end

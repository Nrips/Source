//
//  ViewReviewCell.m
//  Autism
//
//  Created by Neuron Solutions on 5/29/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ViewReviewCell.h"
#import "WriteReviewView.h"
#import "Utility.h"

@implementation ViewReviewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (ViewReviewCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    ViewReviewCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[ViewReviewCell class]]) {
            customCell = (ViewReviewCell *)nibItem;
            break; // we have a winner
        }
    }
        return customCell;
}

-(void)configureCell:(ViewReview *)review ViewReviewLabelHeight:(float)reviewlabelHeight andCellHeight:(float)cellHeight
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    CGRect frame = self.lblAnswer.frame;
    frame.size.height = reviewlabelHeight;
    self.lblAnswer.frame = frame;

    CGRect buttonViewFrame = self.buttonView.frame;
    buttonViewFrame.origin.y = self.lblAnswer.frame.origin.y + reviewlabelHeight + REVIEWCELL_CONTENT_MARGIN;
    self.buttonView.frame= buttonViewFrame;

    CGRect frame1 = self.bgImage.frame;
    frame1.size.height = cellHeight;
    self.bgImage.frame = frame1;


    
    [self.lblName setText:review.name];
    [self.lblAnswer setText:review.reviewText];
    
    self.serviceRating = review.rating;//[review.rating integerValue];
    self.reviewText = review.reviewText;
    self.serviceReviewId = review.reviewId;
    self.serviceId = review.serviceId;
    self.isSelfReview = review.isSelfReview;
    
    if (self.isSelfReview){
        self.btnEditReview.hidden = NO;
        self.btnDeleteReview.hidden = NO;
    }

    [self showStarRating];
    
}


-(void)showStarRating
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


-(IBAction)deleteAction:(id)sender
{
    DLog(@"%s",__FUNCTION__);
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                      message:@"Are you sure you want to delete this post?"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"No", @"Yes", nil];
    myAlert.tag = kTagDeleteActivityAlert;
    [myAlert show];


}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != kTagDeleteActivityAlert) {
        return;
    }
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        
    }
    else if (buttonIndex == 1)
    {
        [self deleteReview];
    }
}



-(IBAction)editAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(editButtonPressedAtRow:::)]) {
        
        [self.delegate editButtonPressedAtRow:self.reviewText :self.serviceRating:self.serviceReviewId];
    }
 }


-(void)deleteReview
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.serviceId)
    {
        DLog(@"ReviewId does not exist");
        return;
    }
    NSDictionary *deleteReviewParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"service_review_id":self.serviceReviewId,
                                            @"service_id":self.serviceId,
                                            };
    NSString *deleteReviewUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_DeleteReview];
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,deleteReviewUrl,deleteReviewParameters);
    [serviceManager executeServiceWithURL:deleteReviewUrl andParameters:deleteReviewParameters forTask:kTaskDeleteActivity completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,deleteReviewUrl, response);
        if (!error && response) {
            NSDictionary *dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(reviewDeletedFromReviewView)]) {
                    [self.delegate reviewDeletedFromReviewView];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    
}

@end

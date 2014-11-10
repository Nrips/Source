//
//  ActivityDetailsViewCellTableViewCell.m
//  Autism
//
//  Created by Dipak on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ActivityDetailsCell.h"
#import "AppDelegate.h"
#include "STTweetLabel.h"
#import "Utility.h"
#import "CommentViewController.h"

@interface ActivityDetailsCell ()<CommentViewControllerDelegate>

@property (nonatomic, strong) NSString *previousComment;

- (IBAction)removeActivtyButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;

@end

@implementation ActivityDetailsCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (ActivityDetailsCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    ActivityDetailsCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[ActivityDetailsCell class]]) {
            customCell = (ActivityDetailsCell*)nibItem;
            break; // we have a winner
        }
    }

    return customCell;
}


-(void)configureActivityDetailCell:(ActivityDetails *)activityDetails detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight
{
    
    
    CGRect frame = self.lblcomment.frame;
    frame.origin.y = self.commentedUserName.frame.origin.y + 25 +CELL_LABEL_MARGIN;
    frame.size.height = labelHeight;
    self.lblcomment.frame = frame;
    
    
    
    CGRect buttonViewFrame = self.buttonView.frame;
    buttonViewFrame.origin.y = self.lblcomment.frame.origin.y + labelHeight + CELL_CONTENT_MARGIN;
    self.buttonView.frame= buttonViewFrame;
    
    
    CGRect frame2 = self.bgGrayImageView.frame;
    frame2.size.height = cellHeight;
    self.bgGrayImageView.frame = frame2;

    
    CGRect frame1 = self.bgImageView.frame;
    frame1.size.height = cellHeight;
    self.bgImageView.frame = frame1;
    

    
    //self.commentTextView.text = activityDetails.commentText;
    self.commentTextView.text = activityDetails.commentText;
    self.commentedUserName.text = activityDetails.commentUserName;
    self.commentTime.text = activityDetails.commentTime;
    [self.commentedUserProfileView configureImageForUrl:activityDetails.commentUserImageUrl];
    self.likeButton.selected = activityDetails.isActivityCommentLiked;
    self.removeActivityButton.hidden = !activityDetails.isSelfActivityComment;
    self.activityCommentID = activityDetails.activityCommentID;
    self.activityCommentMemberID = activityDetails.activityCommentMemberID;
    self.editActivityButton.hidden = !activityDetails.isSelfActivityComment;
    self.activityCommentText = activityDetails.commentText;
    
    //For Hash Tagging
    ///////
    self.lblcomment.callerView = kCallerViewActivityDetail;
    [self.lblcomment setupFontColorOfHashTag];
    self.lblcomment.acttivityDetail = activityDetails;
    [self.lblcomment setText:activityDetails.commentText];
    
    
    __weak typeof(self) weakSelf = self;
    
    [self.lblcomment setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[kHotWordHandle, kHotWordHashtag,kHotWordLink, kHotWordNotification];
        NSString *selectedString = [NSString stringWithFormat:@"%@ [%d,%d]: hotWorld: %@, hotWorldID:%@, %@", hotWords[hotWord], (int)range.location, (int)range.length, hotString, hotWorldID,(protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
        
        if (hotWord == 2 && ([Utility getValidString:hotString].length > 0))
          {
              NSString *lowercaseUrl = [hotString lowercaseString];
              
        if ([lowercaseUrl rangeOfString:@"http"].location == NSNotFound) {
               NSString *string = [NSString stringWithFormat:@"http://%@",hotString];
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
            }
            else {
                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:hotString]];
                }
             }
          
        if ([weakSelf.delegate respondsToSelector:@selector(clickOnHashTag:hashType:forActivity:)]) {
            [weakSelf.delegate clickOnHashTag:hotWorldID hashType:hotWords[hotWord] forActivity:activityDetails];
        }
    }];
    
    //// Tagging
   self.commentedUserName.text = activityDetails.commentUserName;
    self.commentTime.text = activityDetails.commentTime;
    [self.commentedUserProfileView configureImageForUrl:activityDetails.commentUserImageUrl];
    self.likeButton.selected = activityDetails.isActivityCommentLiked;
    self.removeActivityButton.hidden = !activityDetails.isSelfActivityComment;
    self.activityCommentID = activityDetails.activityCommentID;
    self.activityCommentMemberID = activityDetails.activityCommentMemberID;
    self.editActivityButton.hidden = !activityDetails.isSelfActivityComment;
    self.actTagArray = activityDetails.tagsArray;
    
    DLog(@"tag %@",activityDetails.tagsArray);
    
}

- (IBAction)removeActivtyButtonPressed:(id)sender
{
    DLog(@"%s",__FUNCTION__);
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                      message:@"Are you sure you want to delete the comment?"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"No", @"Yes", nil];
    myAlert.tag = kTagDeleteActivityAlert;
    [myAlert show];
}

- (IBAction)memberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.activityCommentMemberID);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.activityCommentMemberID];
    }
}


-(void)removeActivityCommentApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.activityCommentID) {
        DLog(@"Edit Activity Comment api call not perform because ActivityId is not exist");
        return;
    }
    
    NSDictionary *deleteActivityParameter = @{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                @"activity_comment_id":self.activityCommentID
                                                };
    
    NSString *deleteActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_DeleteActivityComment];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,deleteActivityUrl, deleteActivityParameter);
    
    [serviceManager executeServiceWithURL:deleteActivityUrl andParameters:deleteActivityParameter forTask:kTaskDeleteActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response : %@",__FUNCTION__,deleteActivityUrl,response);

        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(activityCommentDeleted)]) {
                    [self.delegate activityCommentDeleted];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
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
        [self removeActivityCommentApiCall];
        
    }
}


- (IBAction)editButtonPressed:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(replyButtonPressedAtRow:withActivityID:ActivityText:andActivityTagArray:buttonState:)])
        
   [self.delegate replyButtonPressedAtRow:self.tag withActivityID:self.activityCommentID ActivityText:self.activityCommentText andActivityTagArray:self.actTagArray buttonState:self.editActivityButton.selected ];
}


- (IBAction)likeButtonPressed:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.activityCommentID) {
        DLog(@"LikeActivity api call not perform because Activity CommentID is not exist");
        return;
    }
    
    NSDictionary *likeActivityParameter = @{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"activity_comment_id":self.activityCommentID,
                                              @"type": @"like",
                                              };
    
    NSString *strLikeActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ActivityCommentLike];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,strLikeActivityUrl,likeActivityParameter);

    [serviceManager executeServiceWithURL:strLikeActivityUrl andParameters:likeActivityParameter forTask:kTaskActivityCommentLike completionHandler:^(id response, NSError *error, TaskType task) {
         DLog(@"%s %@ api \n response:%@",__FUNCTION__,strLikeActivityUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
           
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.likeButton.selected = [[dict objectForKey:@"is_like"] boolValue];
                if ([self.delegate respondsToSelector:@selector(activityCommentLike)]) {
                    [self.delegate activityCommentLike];
                }
               } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

@end

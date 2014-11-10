 //
//  ActivityDetailHeaderViewCell.m
//  Autism
//
//  Created by Neuron Solutions on 9/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ActivityDetailHeaderViewCell.h"
#import "Utility.h"
#import "ActivityImageCell.h"

@implementation ActivityDetailHeaderViewCell
@synthesize imageAttachLink, imageView;

- (void)awakeFromNib
{
    // Initialization code
    self.isChange = NO;
    UINib *cellNib = [UINib nibWithNibName:@"ActivityImageCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CollectionCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)passHeaderValue:(NSString *)strName time:(NSString *)strActivitPostTime activityDetail:(NSString *)activityDetail activityID:(NSString *)activityId profileImage:(NSString *)imageUrl likeValue:(BOOL)like hugValue:(BOOL)hug activityTagArray:(NSArray *)tagArray headerHeight:(float)height memberID:(NSString *)strMemberId attachLink:(NSString *)strAttachLink imageAttachLink:(NSString *)strImageAttachLink vedioLink:(NSString *)strVedioLink vedioLinkImage:(NSString *)strVedioLinkImage imageArray:(NSMutableArray *)arrImages memberBlocked:(BOOL)Blocked isSelfActivity:(BOOL)selfActivity isActivityMemberReport:(BOOL)repoted isMemberInCircle:(BOOL)circleStatus attachVedioLink:(NSString *)strAttachVedioLink WallPostUserName:(NSString *)otherUSerName wallPostUserId:(NSString *)otherUserId isWallPost:(BOOL)wallPost
{
    self.activityFont = [UIFont systemFontOfSize:13.6];
    float nameLabelHeight = [self calculateLabelStringHeight:strName];
    float nameLabelWidth = [self calculateLabelStringWidth:strName];
    float otherUserNameHeight = [self calculateLabelStringHeight:otherUSerName];
    
    float commentLabelHeight = [self calculateLabelStringHeight:activityDetail];
    float attachLinkLabelHeight = [self calculateLabelStringHeight:strAttachLink];
    
    CGRect cellFrame = self.frame;
    cellFrame.size.height = height;
    self.frame = cellFrame;
    
    CGRect frame = self.lblName.frame;
    frame.origin.y = 04.0;
    frame.size.height = nameLabelHeight;
    //frame.size.width = nameLabelWidth;
    self.lblName.frame = frame;
    
    CGRect btnFrame = self.memberNameBtn.frame;
    btnFrame.origin.y = 04.0;
    btnFrame.size.height = nameLabelHeight;
    frame.size.width = nameLabelWidth;
    self.memberNameBtn.frame = btnFrame;

    
    
   /* CGRect frame1 = self.imgTimeClock.frame;
    frame1.origin.y = self.lblName.frame.origin.y + ACTIVITY_MEMBERNAME_HEIGHT + CELL_LABEL_MARGIN;
    frame1.size.height = ACTIVITY_TIMELABEL_HEIGHT;
    self.imgTimeClock.frame = frame1;
    
    CGRect frame2 = self.lblTime.frame;
    frame2.origin.y = self.imgTimeClock.frame.origin.y + ACTIVITY_MEMBERNAME_HEIGHT + CELL_LABEL_MARGIN;
    self.lblTime.frame = frame2;*/
    
    
    CGRect SecondFrame = self.lblOtherUSerName.frame;
    SecondFrame.origin.y = self.lblName.frame.origin.y + nameLabelHeight ;
    
    CGRect frame1 = self.imgTimeClock.frame;
    CGRect frame2 = self.lblTime.frame;
    
    if (wallPost) {
        
        CGRect signFrame = self.lblSign.frame;
        signFrame.origin.y = 2.0;
        signFrame.origin.x = self.lblName.frame.origin.x + nameLabelWidth + 12;
        self.lblSign.frame = signFrame;
        
        CGRect otherBtnFrame = self.otherMemberNameBtn.frame;
        otherBtnFrame.origin.y = self.lblName.frame.origin.y + nameLabelHeight;
        otherBtnFrame.size.height = otherUserNameHeight;
        self.otherMemberNameBtn.frame = otherBtnFrame;
        
        SecondFrame.size.height = otherUserNameHeight;
        self.lblOtherUSerName.frame = SecondFrame;
        [self.lblOtherUSerName setText:otherUSerName];
        
        
        frame1.origin.y = self.lblOtherUSerName.frame.origin.y + otherUserNameHeight + CELL_LABEL_MARGIN ;
        self.imgTimeClock.frame = frame1;
        
        frame2.origin.y = self.lblOtherUSerName.frame.origin.y  + otherUserNameHeight + CELL_LABEL_MARGIN - 5;
        self.lblTime.frame = frame2;
    }
    
    else{
        
        SecondFrame.size.height = 0;
        self.lblOtherUSerName.frame = SecondFrame;
        self.lblOtherUSerName.hidden = YES;
        self.lblSign.hidden = YES;
        
        frame1.origin.y = self.lblName.frame.origin.y + nameLabelHeight + CELL_LABEL_MARGIN + 5;
        
        self.imgTimeClock.frame = frame1;
        
        CGRect frame2 = self.lblTime.frame;
        frame2.origin.y = self.lblName.frame.origin.y  + nameLabelHeight + CELL_LABEL_MARGIN;
        self.lblTime.frame = frame2;
    }
    
    CGRect commentFrame = self.lblDetail.frame;
    commentFrame.origin.y = self.lblTime.frame.origin.y + ACTIVITY_TIMELABEL_HEIGHT;
    commentFrame.size.height = commentLabelHeight+ 5;
    self.lblDetail.frame = commentFrame;
    
    
    CGRect frameImage = self.bgImageView.frame;
    frameImage.size.height = height;
    self.bgImageView.frame = frameImage;
    
    
    //Set Attach Link Label, Image Frame and CollectionView frame
    CGRect attachFrame = self.lblAttachLink.frame;
    CGRect attachImageFrame = self.imageAttachLink.frame;
    attachFrame.origin.y = self.lblDetail.frame.origin.y + commentLabelHeight + CELL_CONTENT_MARGIN + 2.0;
    CGRect collectionViewFrame = self.collectionView.frame;
    
    if ([Utility getValidString:strAttachLink].length > 0)
    {
        self.lblWebsite.hidden = NO;
        CGRect frameWebsite = self.lblWebsite.frame;
        frameWebsite.origin.y = self.lblDetail.frame.origin.y + commentLabelHeight + CELL_CONTENT_MARGIN;
        self.lblWebsite.frame = frameWebsite;
        
        attachFrame.size.height = attachLinkLabelHeight +5;
        self.lblAttachLink.frame = attachFrame;
        
        collectionViewFrame.origin.y = self.lblAttachLink.frame.origin.y + attachLinkLabelHeight + CELL_CONTENT_MARGIN;
        
        
        //For Hash Tagging
        ///////
        self.activityAttachLinkSting = strAttachLink;
        self.lblAttachLink.callerView = kCallerViewActivity;
        [self.lblAttachLink setupFontColorOfHashTag];
        //self.lblAttachLink.getMyActivity = myActivity;
        [self.lblAttachLink setText:self.activityAttachLinkSting];
        
        
        [self.lblAttachLink setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
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
            DLog(@"Clickeded UserID String:%@",selectedString);
            
        }];
        ////
        
        
        if ([Utility getValidString:strImageAttachLink].length > 0) {
            
            attachImageFrame.origin.y = self.lblAttachLink.frame.origin.y + attachLinkLabelHeight + CELL_CONTENT_MARGIN;
            attachImageFrame.size.height = ACTIVITY_ATTACHIMAGEFRAME_HEIGHT;
            self.imageAttachLink.frame = attachImageFrame;
            
            CGRect attachImageButtonFrame = self.btnAttachImage.frame;
            attachImageButtonFrame.origin.y =self.lblAttachLink.frame.origin.y + attachLinkLabelHeight + CELL_CONTENT_MARGIN;
            attachImageButtonFrame.size.height = ACTIVITY_ATTACHIMAGEFRAME_HEIGHT;
            self.btnAttachImage.frame = attachImageButtonFrame;
            
            collectionViewFrame.origin.y = self.imageAttachLink.frame.origin.y + ACTIVITY_ATTACHIMAGEFRAME_HEIGHT + CELL_CONTENT_MARGIN;
        }
        else{
            collectionViewFrame.origin.y = self.lblAttachLink.frame.origin.y + attachLinkLabelHeight + CELL_CONTENT_MARGIN;
            attachImageFrame.size.height = 0;
            self.imageAttachLink.hidden = YES;
        }
    }
    
    else{
        attachFrame.size.height = 0;
        self.lblAttachLink.hidden = YES;
        self.lblAttachLink.frame = attachFrame;
        self.btnAttachImage.hidden = YES;
        collectionViewFrame.origin.y = self.lblDetail.frame.origin.y + commentLabelHeight + CELL_CONTENT_MARGIN;
    }
    
    if (arrImages.count > 0) {
        
        collectionViewFrame.size.height = ACTIVITY_COLLECTIONVIEW_HEIGHT;
        arrayImages = arrImages;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
    } else {
        collectionViewFrame.size.height = 0;
        self.collectionView.hidden = YES;
    }
    
    self.collectionView.frame = collectionViewFrame;
    
    
    //Set VideoURL Frame
    CGRect vedioURLViewFrame = self.txtviewVideoUrl.frame;
    vedioURLViewFrame.origin.y = self.collectionView.frame.origin.y + self.collectionView.frame.size.height + CELL_LABEL_MARGIN - 6;
    
    if ([Utility getValidString:strAttachVedioLink].length > 0) {
        
        self.lblVideoUrl.hidden = NO;
        CGRect frameUrlWebsite = self.lblVideoUrl.frame;
        frameUrlWebsite.origin.y = self.collectionView.frame.origin.y + self.collectionView.frame.size.height + CELL_LABEL_MARGIN ;
        self.lblVideoUrl.frame = frameUrlWebsite;
        
        vedioURLViewFrame.size.height = ACTIVITY_ATTACH_VIDEO_URL_HEIGHT;
        self.txtviewVideoUrl.frame = vedioURLViewFrame;
        
    }
    else
    {   self.lblVideoUrl.hidden = YES;
        self.txtviewVideoUrl.hidden = YES;
        vedioURLViewFrame.size.height = 0;
        self.txtviewVideoUrl.frame = vedioURLViewFrame;
    }
    
    
    //Set Video Frame
    CGRect vedioViewFrame = self.videoThumbnailImageView.frame;
    vedioViewFrame.origin.y = self.txtviewVideoUrl.frame.origin.y + self.txtviewVideoUrl.frame.size.height + CELL_LABEL_MARGIN;
    
    //Set Video Button Frame
    CGRect vediobuttonFrame = self.videoPlayButton.frame;
    vediobuttonFrame.origin.y = self.txtviewVideoUrl.frame.origin.y + self.txtviewVideoUrl.frame.size.height + CELL_LABEL_MARGIN;
    
    if ([Utility getValidString:strVedioLink].length > 0) {
        
        vedioViewFrame.size.height = ACTIVITY_VIDEOFRAME_HEIGHT;
        
        vediobuttonFrame.size.height = ACTIVITY_VIDEOFRAME_HEIGHT;
        
        [self.videoThumbnailImageView configureImageForUrl:strVedioLinkImage];
        
        if ([Utility getValidString:strVedioLink].length > 0) {
            self.videoPlayButton.hidden = NO;
            self.videoUrl = strVedioLink;
        }
    } else {
        
        vedioViewFrame.size.height = 0;
        vediobuttonFrame.size.height = 0;
        
        self.videoPlayButton.hidden = YES;
        self.videoThumbnailImageView.hidden = YES;
        
    }
    self.videoThumbnailImageView.frame = vedioViewFrame;
    self.videoPlayButton.frame = vediobuttonFrame;
    
    //Set Bottom Buttons Frame
    CGRect buttonFrame = self.buttonBarView.frame;
    buttonFrame.origin.y = self.videoThumbnailImageView.frame.origin.y + self.videoThumbnailImageView.frame.size.height + CELL_LABEL_MARGIN;
    self.buttonBarView.frame = buttonFrame;
    
    //For Hash Tagging
    ///////
    NSString *activityDetailStr = activityDetail;
    
    self.lblDetail.callerView = kCallerViewActivity;
    [self.lblDetail setupFontColorOfHashTag];
    //self.lblDetail.getMyActivity = myActivity;
    [self.lblDetail setText:activityDetailStr];
    
    
    [self.lblDetail setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
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
        DLog(@"Clickeded UserID String:%@",selectedString);
        
    }];
    ////
    
    
    [self.imageAttachLink configureImageForUrl:strImageAttachLink];
    
    [self.lblAttachLink setText:self.activityAttachLinkSting];
    [self.txtviewVideoUrl setText:strAttachVedioLink];
    [self.lblTime setText:strActivitPostTime];
    self.strActivityId = activityId;
    self.isMemberActivityReported = repoted;
    self.isSelfMemberActivity = selfActivity;
    self.activityMemberId = strMemberId;
    self.isMemberAlreadyInCircle = circleStatus;
    self.isMemberActivityLike = like;
    self.isMemberActivityHug = hug;
    self.activityTag = tagArray;
    arrayImages      = arrImages;
    
    self.wallPostMemberId = otherUserId;
    self.isWallPost = wallPost;
    self.btnHug.selected = self.isMemberActivityHug;
    self.btnLike.selected = self.isMemberActivityLike;
    
    self.isMemeberBlocked = Blocked;
    
    if (self.isSelfMemberActivity){
        self.btnReportToAWM.hidden = YES;
        self.removeActivityButton.hidden = NO;
    }
    else{
        self.btnReportToAWM.hidden = NO;
        self.removeActivityButton.hidden = YES;
     }

    [self.userImageView configureImageForUrl:imageUrl];
    [self.lblName setText:strName];
    //[self.memberNameBtn setTitle:strName forState:UIControlStateNormal];

}

// Action method for click on attachimage by link

-(IBAction)attachImageAction:(id)sender
{
    if ([Utility getValidString:self.activityAttachLinkSting].length > 0){
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.activityAttachLinkSting]];
    }
}

-(float)calculateLabelStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(235, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.activityFont} context:nil];
    return textRect.size.height;
    
}

-(float)calculateLabelStringWidth:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(205, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.activityFont} context:nil];
    return textRect.size.width;
}


#pragma mark - CollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    DLog(@"%s",__FUNCTION__);
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    DLog(@"%s \n //*> arrayImages Count:%d",__FUNCTION__, arrayImages.count);
    
    return arrayImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ActivityImageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    NSString *imageURL = [NSString stringWithFormat:@"%@",[arrayImages objectAtIndex:indexPath.row]];
    DLog(@"%s \n //*> imageURL:%@",__FUNCTION__, imageURL);
    
    [cell.imag configureImageForUrl:imageURL];
    
    return cell;
}


-(IBAction)memberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.activityMemberId);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.activityMemberId];
    }
}


-(IBAction)otherMemberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.wallPostMemberId);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.wallPostMemberId];
    }
}



- (IBAction)videoPlayButtonPressed:(id)sender {
    DLog(@"%s videoUrl:%@",__FUNCTION__, self.videoUrl);
    if (([Utility getValidString:self.videoUrl].length > 0) && [self.delegate respondsToSelector:@selector(videoPlayButtonPressedWithUrl:)]) {
        [self.delegate videoPlayButtonPressedWithUrl:self.videoUrl];
    }
}

-(IBAction)reportToAWM:(id)sender
{
    self.isChange = YES;
    NSString *blockMemberTitle = self.isMemeberBlocked ? kTitleUnblockMember : kTitleBlockThisMember;
    
    if ([self.parentViewControllerName isEqualToString:kCallerViewFindPeople])
    {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:blockMemberTitle,kTitleReportToAWM, nil];
    }
    else if (self.isWallPost)
    {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:blockMemberTitle,kTitleReportToAWM, nil];
     }
    
    else{
        NSString *inCircleButtonTitle = self.isMemberAlreadyInCircle ? kTitleInCircle : kTitleAddToCircle;
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:inCircleButtonTitle, blockMemberTitle,kTitleReportToAWM, nil];
    }
    
    self.actionSheet.delegate = self;
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [self.actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([title isEqual: kTitleInCircle] || [title isEqual:kTitleAddToCircle])
    {
        [self addToCircleApiCall];
    }
    else if([title isEqual: kTitleBlockThisMember] || [title isEqual: kTitleUnblockMember])
    {
        NSString *message = self.isMemeberBlocked ? @"Are you sure you want to Unblock this member?" : @"Are you sure you want to block this member?";
        
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"No", @"Yes", nil];
        myAlert.tag = kTagBlockMemeberAlert;
        [myAlert show];
    }
    else if([title isEqual:kTitleReportToAWM])
    {
        if (self.isMemberActivityReported) {
            [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Already Reported"];
            return;
        }
        if([self.delegate respondsToSelector:@selector(showReportToAWMViewWithReportID:)])
        {
            [self.delegate showReportToAWMViewWithReportID:self.strActivityId];
        }
    }
    [self.actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        
    }
    else if (buttonIndex == 1)
    {
        if (alertView.tag == kTagBlockMemeberAlert){
            
            [self blockMemberApiCall];
        }
    }
}

-(void)addToCircleApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.activityMemberId) {
        DLog(@"Person id whom you want to add does not exist");
        return;
    }
    NSDictionary *addToCircleParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"add_member_id":self.activityMemberId,
                                            };
    NSString *addToCircleUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_AddMemberInTeam];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,addToCircleUrl, addToCircleParameters);
    [serviceManager executeServiceWithURL:addToCircleUrl andParameters:addToCircleParameters forTask:kTaskAddMemberInTeam completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,addToCircleUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                BOOL circleVlue ;
                if([[dict objectForKey:@"is_memmber_added_incircle"] boolValue]){
                    [Utility showAlertMessage:@"" withTitle:@"Member added successfully in your circle."];
                    circleVlue = YES;
                } else {
                    [Utility showAlertMessage:@"" withTitle:@"Member successfully removed from your circle."];
                    circleVlue = NO;
                }
                if ([self.delegate respondsToSelector:@selector(memberSuccessfullyAddedInCircle:)]) {
                    [self.delegate memberSuccessfullyAddedInCircle:circleVlue];
                }
            } else if ([[dict valueForKey:@"is_blocked"] boolValue]){
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else {
                [Utility showAlertMessage:@"Member could not be added in your cirlce. Please try again." withTitle:@""];
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

-(void)blockMemberApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.activityMemberId) {
        DLog(@"Person id whom you want to block does not exist");
        return;
    }
    
    NSDictionary *blockMemberParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           @"block_member_id" : self.activityMemberId,
                                           };
    
    NSString *blockMemberUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_BlockMember];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,blockMemberUrl,blockMemberParameters);
    
    [serviceManager executeServiceWithURL:blockMemberUrl andParameters:blockMemberParameters forTask:kTaskBlockMember completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s blockMemberUrl %@ api \n with response :%@",__FUNCTION__,blockMemberUrl,response);
        
        if (!error && response){
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"" withTitle:[dict valueForKey:@"message"]];
                BOOL blockStatus = [[dict valueForKey:@"is_blocked"]boolValue];
                if (blockStatus) {
                    blockStatus = YES;
                }
                else{
                    blockStatus = NO;
                }

                if([self.delegate respondsToSelector:@selector(memberSuccessfullyBlocked:)])
                    [self.delegate memberSuccessfullyBlocked:blockStatus];
             } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                        [appDelegate userAutismSessionExpire];
              }
            else {
                if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                    [Utility showAlertMessage:@"" withTitle:@"Please unblock this member first."];
                } else {
                    [Utility showAlertMessage:@"Member could not be blocked from your cirlce. Please try again." withTitle:@""];
                }
            }
        }
        else
        {   DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

-(IBAction)likeAction:(id)sender
{
    if (![appDelegate isNetworkAvailable])
        {
            [Utility showNetWorkAlert];
            return;
        }
        if (!self.strActivityId) {
            DLog(@"likeActivity api call not perform because ActivityId is not exist");
            return;
        }
    
      self.isChange = YES;

    
        NSDictionary *likeActivityParameter =@{   @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                  @"activity_id":self.strActivityId,
                                                  @"type": @"like"
                                                  
                                                  };
        
        NSString *strLikeActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostLikeHug];
    
        DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__, strLikeActivityUrl, likeActivityParameter);
        
        [serviceManager executeServiceWithURL:strLikeActivityUrl andParameters:likeActivityParameter forTask:kTaskLikeHug completionHandler:^(id response, NSError *error, TaskType task) {
            
            DLog(@"%s %@ api \n Response:%@",__FUNCTION__, strLikeActivityUrl, response);
            
            if (!error && response) {
                
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                    self.isLike = [[response objectForKey:@"is_like"] boolValue];
                    self.btnLike.selected = self.isLike;
                    if (self.isLike) {
                        self.isLike = YES;
                      }
                    else{
                        self.isLike = NO;
                      }
                    if([self.delegate respondsToSelector:@selector(memberSuccessfullyLike:)])
                        [self.delegate memberSuccessfullyLike:self.isLike];
                    }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else{
                    DLog(@"%s Error:%@",__FUNCTION__,error);
                    [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
                }
            }
        }];
    }

-(IBAction)hugAction:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!_strActivityId) {
        DLog(@"hug Activity api call not perform because questionId is not exist");
        return;
    }
    self.isChange = YES;

    
    NSDictionary *hugActivityParameter =@{   @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"activity_id":_strActivityId,
                                             @"type": @"hug",
                                             
                                             };
    
    DLog(@"%s Performing auth/hugActivity with parameter:%@",__FUNCTION__,hugActivityParameter);
    
    
    NSString *strHugActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostLikeHug];
    
    [serviceManager executeServiceWithURL:strHugActivityUrl andParameters:hugActivityParameter forTask:kTaskLikeHug completionHandler:^(id response, NSError *error, TaskType task) {
       
        DLog(@"%s Response of auth/hugActivity api:%@",__FUNCTION__,response);
        
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isHug = [[response objectForKey:@"is_hug"] boolValue];
                    self.btnHug.selected = self.isHug;
                    if (self.isHug)
                       {
                        self.isHug = YES;
                       }
                    else{
                        self.isHug = NO;
                     }
                    
                    if([self.delegate respondsToSelector:@selector(memberSuccessfullyHug:)])
                        [self.delegate memberSuccessfullyHug:YES];
                    });
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            
            else{
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
    }];
}

-(IBAction)shareAction:(id)sender
{
  //self.btnShare.selected = YES;
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (self.strActivityId.length < 1) {
        DLog(@"share Activity api call not perform because questionId is not exist");
        return;
    }
    self.isChange = YES;

    NSDictionary *shareActivityParameter =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"activity_id":_strActivityId,
                                             
                                             };
    
    NSString *shareActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ShareActivity];
    
    DLog(@"%s Performing  %@ api \n with parameter:%@",__FUNCTION__,shareActivityUrl, shareActivityParameter);
    
    [serviceManager executeServiceWithURL:shareActivityUrl andParameters:shareActivityParameter forTask:kTaskShareActivity completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ \n with response : %@ ",__FUNCTION__,shareActivityUrl,response);
        self.btnShare.selected = NO;
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    DLog(@"share api response %@",response);
                    
                    self.shareActivity = [[response objectForKey:@"message"] boolValue];
                    self.btnShare.selected = self.shareActivity;
                    [Utility showAlertMessage:@"" withTitle:@"You have successfully shared this post"];
                });
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

-(IBAction)removeActivtyButtonPressed:(id)sender
{
    [self deleteActivity];
}

-(void)deleteActivity
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.strActivityId)
    {
        DLog(@"ActivtyId does not exist");
        return;
    }
   
    NSDictionary *deleteActivityParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               @"activity_id":self.strActivityId,
                                               };
    
    NSString *deleteActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_DeleteActivity];
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,deleteActivityUrl, deleteActivityParameters);
    [serviceManager executeServiceWithURL:deleteActivityUrl andParameters:deleteActivityParameters forTask:kTaskDeleteActivity completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,deleteActivityUrl, response);
        if (!error && response) {
            NSDictionary *dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(activityDeletedFromActivityView)]) {
                    [self.delegate activityDeletedFromActivityView];
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


-(IBAction)commentAction:(id)sender
{
     DLog(@"%s, activityId:%@",__FUNCTION__, self.strActivityId);
    if ([self.delegate respondsToSelector:@selector(commentButtonPressed:buttonState:)]) {
        [self.delegate commentButtonPressed:self.strActivityId buttonState:self.btncomment.selected];
    }
}

@end

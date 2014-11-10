//
//  CustomMyPostCell.m
//  Autism
//
//  Created by Neuron-iPhone on 3/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "CustomMyPostCell.h"
#import "CollectionImageCell.h"
#import "NSDictionary+HasValueForKey.h"
#import "Utility.h"
#import "ActivityImageCell.h"

@interface CustomMyPostCell () <UIActionSheetDelegate, UIAlertViewDelegate>
{
    float nameWidth;
}
@property (weak, nonatomic) IBOutlet UIButton *memberNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic) IBOutlet MyImageView *videoThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnReportToAWM;
@property (weak, nonatomic) IBOutlet UIButton *removeActivityButton;
@property(nonatomic) BOOL isMemberActivityLike;
@property(nonatomic) BOOL isMemberActivityHug;
@property(nonatomic, strong) NSString *videoUrl;
@property(nonatomic, strong) UIActionSheet *actionSheet;
@property(nonatomic, strong) UIFont* activityFont;
@property(nonatomic)BOOL circleStatus;
- (IBAction)removeActivtyButtonPressed:(id)sender;
- (IBAction)memberNameBtnPressed:(id)sender;
- (IBAction)videoPlayButtonPressed:(id)sender;

@end

@implementation CustomMyPostCell
@synthesize imageView,isLike,strMessage,btnHug,btnLike;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.activityFont = [UIFont systemFontOfSize:13.0];
    UINib *cellNib = [UINib nibWithNibName:@"ActivityImageCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CollectionCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (CustomMyPostCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    CustomMyPostCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[CustomMyPostCell class]]) {
            customCell = (CustomMyPostCell *)nibItem;
            break; // we have a winner
        }
    }
         customCell.imageView = [[MyImageView alloc]initWithFrame:CGRectMake(2, 4,41,41)];
        [customCell.imageView setImage:[UIImage imageNamed:@"avatar-140.png"]];
        [customCell addSubview:customCell.imageView];
        return customCell;
}


-(void)configureCell:(GetMyActivity *)myActivity activityDetailLabelHeight:(float)commentLabelHeight attachLinkHeight:(float)attachLinkLabelHeight andCellHeight:(float)cellHeight
{
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;
    
    nameWidth = [self calculateStringWidth:myActivity.name];
    
    CGRect frame = self.lblName.frame;
    
    if (nameWidth >= 170) {
        
       frame.size.width = self.memberNameBtn.frame.origin.x + 170 ;
        
      }
    else{
        
        frame.size.width = self.memberNameBtn.frame.origin.x + nameWidth ;
     }
      frame.origin.y = 4.0;
      frame.size.height = ACTIVITY_MEMBERNAME_HEIGHT;
      self.lblName.frame = frame;
    
     CGRect SecondFrame = self.lblOtherUSerName.frame;
     CGRect frame1 = self.imgTimeClock.frame;
     CGRect frame2 = self.lblTime.frame;
    
    if (myActivity.isWallPost) {
        
        CGRect signFrame = self.lblSign.frame;
        signFrame.origin.y = 0;
        signFrame.origin.x = self.memberNameBtn.frame.origin.x + nameWidth + 10;
        self.lblSign.frame = signFrame;
        
        SecondFrame.origin.y = self.lblName.frame.origin.y + ACTIVITY_MEMBERNAME_HEIGHT + CELL_LABEL_MARGIN ;
        SecondFrame.size.height = ACTIVITY_MEMBERNAME_HEIGHT;
        self.lblOtherUSerName.frame = SecondFrame;
        [self.lblOtherUSerName setText:myActivity.wallPostUSerName];
        
       
        frame1.origin.y = self.lblOtherUSerName.frame.origin.y + ACTIVITY_MEMBERNAME_HEIGHT + CELL_LABEL_MARGIN ;
        self.imgTimeClock.frame = frame1;
        
        frame2.origin.y = self.lblOtherUSerName.frame.origin.y  + ACTIVITY_MEMBERNAME_HEIGHT + CELL_LABEL_MARGIN - 5;
        self.lblTime.frame = frame2;
        }
    
    else{
        
        SecondFrame.size.height = 0;
        self.lblOtherUSerName.frame = SecondFrame;
        self.lblOtherUSerName.hidden = YES;
        self.lblSign.hidden = YES;
        
      frame1.origin.y = self.lblName.frame.origin.y + ACTIVITY_MEMBERNAME_HEIGHT + CELL_LABEL_MARGIN + 5;
        
        self.imgTimeClock.frame = frame1;
        
        CGRect frame2 = self.lblTime.frame;
        frame2.origin.y = self.lblName.frame.origin.y  + ACTIVITY_MEMBERNAME_HEIGHT + CELL_LABEL_MARGIN;
        self.lblTime.frame = frame2;
     }
    
    CGRect commentFrame = self.lblDetail.frame;
    commentFrame.origin.y = self.lblTime.frame.origin.y + ACTIVITY_TIMELABEL_HEIGHT + CELL_CONTENT_MARGIN;
    commentFrame.size.height = commentLabelHeight + 5;
    self.lblDetail.frame = commentFrame;
    
    CGRect frameImage = self.bgImageView.frame;
    frameImage.size.height = cellHeight;
    self.bgImageView.frame = frameImage;
    
    CGRect frame3 = self.arrowImageView.frame;
    frame3.origin.y = cellHeight/2 - 5;
    self.arrowImageView.frame = frame3;

    
    //Set Attach Link Label, Image Frame and CollectionView framae
    CGRect attachFrame = self.lblAttachLink.frame;
    CGRect attachImageFrame = self.imageAttachLink.frame;
    attachFrame.origin.y = self.lblDetail.frame.origin.y + commentLabelHeight + CELL_CONTENT_MARGIN + 2.0;
    CGRect collectionViewFrame = self.collectionView.frame;
    
    if ([Utility getValidString:myActivity.attachLinkUrl].length > 0)
    {
        self.lblWebsite.hidden = NO;
        CGRect frameWebsite = self.lblWebsite.frame;
        frameWebsite.origin.y = self.lblDetail.frame.origin.y + commentLabelHeight + CELL_CONTENT_MARGIN;
        self.lblWebsite.frame = frameWebsite;
        
        attachFrame.size.height = attachLinkLabelHeight + 3;
        self.lblAttachLink.frame = attachFrame;
        
        collectionViewFrame.origin.y = self.lblAttachLink.frame.origin.y + attachLinkLabelHeight + CELL_CONTENT_MARGIN;
        
        
        //For Hash Tagging
        ///////
        self.activityAttachLinkSting = myActivity.attachLinkUrl;
        self.lblAttachLink.callerView = kCallerViewActivity;
        [self.lblAttachLink setupFontColorOfHashTag];
        self.lblAttachLink.getMyActivity = myActivity;
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

        
        if ([Utility getValidString:myActivity.attachLinkThumbnailImageUrl].length > 0) {
            
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
    
    if (myActivity.imagesArray.count > 0) {
        
        collectionViewFrame.size.height = ACTIVITY_COLLECTIONVIEW_HEIGHT;
        arrayImages = myActivity.imagesArray;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView reloadData];
    } else {
        collectionViewFrame.size.height = 0;
        self.collectionView.hidden = YES;
    }
    
    self.collectionView.frame = collectionViewFrame;
    
    //Set VideoURL Frame
    CGRect vedioURLViewFrame = self.txtviewVideoUrl.frame;
    vedioURLViewFrame.origin.y = self.collectionView.frame.origin.y + self.collectionView.frame.size.height + CELL_LABEL_MARGIN - 2;
    
    if ([Utility getValidString:myActivity.attachVideoUrl].length > 0) {
        
        self.lblVideoUrl.hidden = NO;
        CGRect frameUrlWebsite = self.lblVideoUrl.frame;
        frameUrlWebsite.origin.y = self.collectionView.frame.origin.y + self.collectionView.frame.size.height + CELL_LABEL_MARGIN + 4;
        self.lblVideoUrl.frame = frameUrlWebsite;
        
        vedioURLViewFrame.size.height = ACTIVITY_ATTACH_VIDEO_URL_HEIGHT;
        self.txtviewVideoUrl.frame = vedioURLViewFrame;
        
    }
    else
    {  self.lblVideoUrl.hidden = YES;
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
    
    if ([Utility getValidString:myActivity.videoThumbnailImageUrl].length > 0) {
        
        vedioViewFrame.size.height = ACTIVITY_VIDEOFRAME_HEIGHT;
        
        vediobuttonFrame.size.height = ACTIVITY_VIDEOFRAME_HEIGHT;
        
        [self.videoThumbnailImageView configureImageForUrl:myActivity.videoThumbnailImageUrl];
        
        if ([Utility getValidString:myActivity.videoUrl].length > 0) {
            self.videoPlayButton.hidden = NO;
            self.videoUrl = myActivity.videoUrl;
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
    NSString *activityDetailStr = myActivity.detail;
    
    self.lblDetail.callerView = kCallerViewActivity;
    [self.lblDetail setupFontColorOfHashTag];
    self.lblDetail.getMyActivity = myActivity;
    [self.lblDetail setText:activityDetailStr];
    
    __weak typeof(self) weakSelf = self;
    
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
        if ([weakSelf.delegate respondsToSelector:@selector(clickOnHashTag:hashType:forMyActivity:)]) {
            [weakSelf.delegate clickOnHashTag:hotWorldID hashType:hotWords[hotWord] forMyActivity:myActivity];
        }
    }];
    ////
    
    [self.imageAttachLink configureImageForUrl:myActivity.attachLinkThumbnailImageUrl];
   
    //[self.lblAttachLink setText:self.activityAttachLinkSting];
    
    if ([Utility getValidString:myActivity.attachVideoUrl].length > 0) {
       
        [self.txtviewVideoUrl setText:myActivity.attachVideoUrl];
    }
    
    [self.lblTime setText:myActivity.activityTime];
    self.strActivityId = myActivity.activityId;
    self.isMemberActivityReported = myActivity.isMemberActivityReported;
    self.isSelfMemberActivity = myActivity.isSelfMemberActivity;
    self.activityMemberId = myActivity.activityMemberId;
    self.isMemberAlreadyInCircle = myActivity.isMemberAlreadyCircle;
    self.isMemberActivityLike = myActivity.isMemberActivityLike;
    self.isMemberActivityHug = myActivity.isMemberActivityHug;
    self.activityTag = myActivity.tagsArray;
    arrayImages      = myActivity.imagesArray;
    self.wallPostMemberId = myActivity.wallPostUSerId;
    self.isWallPost = myActivity.isWallPost;
    
    self.btnHug.selected = self.isMemberActivityHug;
    self.btnLike.selected = self.isMemberActivityLike;
    
    self.isMemeberBlocked = myActivity.isMemeberBlocked;
    
    if (self.isSelfMemberActivity)
        self.btnReportToAWM.hidden = YES;
    
    self.removeActivityButton.hidden = !self.isSelfMemberActivity;
    
    [self.imageView configureImageForUrl:myActivity.picture];
    
    [self.lblName setText:myActivity.name];
    //[self.memberNameBtn setTitle:myActivity.name forState:UIControlStateNormal];
}

// Action method for click on attachimage by link

-(float)calculateStringWidth:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(204,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.activityFont} context:nil];
    return textRect.size.width;
}


-(IBAction)attachImageAction:(id)sender
{   if ([Utility getValidString:self.activityAttachLinkSting].length > 0){

 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.activityAttachLinkSting]];
  }
}

#pragma mark - CollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    DLog(@"%s",__FUNCTION__);
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    DLog(@"%s \n //*> arrayImages Count:%lu",__FUNCTION__, (unsigned long)arrayImages.count);

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
    
    NSDictionary *likeActivityParameter =@{   @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"activity_id":self.strActivityId,
                                              @"type": @"like",
                                              
                                              };
    NSString *strLikeActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostLikeHug];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__, strLikeActivityUrl, likeActivityParameter);

    [serviceManager executeServiceWithURL:strLikeActivityUrl andParameters:likeActivityParameter forTask:kTaskLikeHug completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n Response:%@",__FUNCTION__, strLikeActivityUrl, response);
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
           
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                isLike = [[response objectForKey:@"is_like"] boolValue];
                self.btnLike.selected = isLike;
                if (self.isLike) {
                      self.isLike = YES;
                     }
                else{
                    self.isLike = NO;
                  }
                if ([self.delegate performSelector:@selector(userLikeActivitySuccessfully::)]) {
                  [self.delegate userLikeActivitySuccessfully:self.isLike :self.strActivityId];
                }
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

- (IBAction)hugAction:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.strActivityId) {
        DLog(@"hug Activity api call not perform because questionId is not exist");
        return;
    }

    NSDictionary *hugActivityParameter =@{   @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"activity_id":self.strActivityId,
                                             @"type": @"hug",
                                              
                                              };
      NSString *strHugActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostLikeHug];
    DLog(@"%s Performing auth/hugActivity %@ \n with parameter:%@",__FUNCTION__,strHugActivityUrl,hugActivityParameter);
    
    [serviceManager executeServiceWithURL:strHugActivityUrl andParameters:hugActivityParameter forTask:kTaskLikeHug completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s Response of auth/hugActivity api:%@",__FUNCTION__,response);

        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
           dispatch_async(dispatch_get_main_queue(), ^{
               self.isHug = [[response objectForKey:@"is_hug"] boolValue];
               self.btnHug.selected = self.isHug;
               if (self.isLike) {
                   self.isHug = YES;
                 }
               else{
                   self.isHug = NO;
                }
            /*
            if ([self.delegate performSelector:@selector(userLikeActivitySuccessfully::)]) {
                
                [self.delegate userLikeActivitySuccessfully:self.isHug :self.strActivityId];
                 }*/
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

- (IBAction)shareAction:(id)sender {
    
    self.btnShare.selected = YES;
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (self.strActivityId.length < 1) {
        DLog(@"share Activity api call not perform because questionId is not exist");
        return;
    }

    NSDictionary *shareActivityParameter =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"activity_id":self.strActivityId,
                                             
                                             };
    
    NSString *shareActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ShareActivity];
    
    DLog(@"%s Performing  %@ api \n with parameter:%@",__FUNCTION__, shareActivityUrl, shareActivityParameter);

    [serviceManager executeServiceWithURL:shareActivityUrl andParameters:shareActivityParameter forTask:kTaskShareActivity completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n with response : %@",__FUNCTION__,shareActivityUrl,response);
        self.btnShare.selected = NO;
        if (!error && response) {
            
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    DLog(@"share api response %@",response);
                    [Utility showAlertMessage:@"" withTitle:@"You have successfully shared this post"];
                });
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
                }
            } else
            {
                DLog(@"%s Error:%@",__FUNCTION__,error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
    }];
}

- (IBAction)commentButtonPressed:(id)sender {
   
    if([self.delegate respondsToSelector:@selector(replyButtonPressedAtRow:withQuestionID:buttonState:)])
        [self.delegate replyButtonPressedAtRow:self.tag withQuestionID:self.strActivityId buttonState:self.commentButton.selected];
}



- (IBAction)removeActivtyButtonPressed:(id)sender
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

- (IBAction)memberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.activityMemberId);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.activityMemberId];
    }
}

- (IBAction)otherMemberNameBtnPressed:(id)sender {
    DLog(@"%s, MemberID:%@",__FUNCTION__, self.wallPostMemberId);
    if ([self.delegate respondsToSelector:@selector(clickOnMemeberName:)]) {
        [self.delegate clickOnMemeberName:self.wallPostMemberId];
    }
}

-(IBAction)videoPlayButtonPressed:(id)sender {
    DLog(@"%s videoUrl:%@",__FUNCTION__, self.videoUrl);
    if (([Utility getValidString:self.videoUrl].length > 0) && [self.delegate respondsToSelector:@selector(videoPlayButtonPressedWithUrl:)]) {
        [self.delegate videoPlayButtonPressedWithUrl:self.videoUrl];
    }
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //if (alertView.tag != kTagDeleteActivityAlert) {
        //return;
    //}
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];

    }
    else if (buttonIndex == 1)
    {
        if (alertView.tag == kTagDeleteActivityAlert) {
            [self deleteActivity];
        } else if (alertView.tag == kTagBlockMemeberAlert){
            
            [self blockMemberApiCall];
        }
    }
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


- (IBAction)reportToAWMButtonPressed:(id)sender
{
    int btnTag = [sender tag];
    
    
    
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
          NSString*inCircleButtonTitle = self.isMemberAlreadyInCircle ? kTitleInCircle : kTitleAddToCircle;
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:inCircleButtonTitle, blockMemberTitle,kTitleReportToAWM, nil];
       }
    
     self.actionSheet.delegate = self;
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString* title = [self.actionSheet buttonTitleAtIndex:buttonIndex];
    
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


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = appUIGreenColor;
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
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"])
            {
                self.circleStatus = [[dict valueForKey:@"is_memmber_added_incircle"]boolValue];
                if([[dict objectForKey:@"is_memmber_added_incircle"] boolValue]){
                    [Utility showAlertMessage:@"" withTitle:@"Member added successfully in your circle."];
                } else {
                    [Utility showAlertMessage:@"" withTitle:@"Member successfully removed from your circle."];
                }
                if (self.circleStatus) {
                    self.circleStatus = YES;
                  }
                else{
                    self.circleStatus = NO;
                 }
              if ([self.delegate respondsToSelector:@selector(memberSuccessfullyAddedInCircle::)]) {
                    [self.delegate memberSuccessfullyAddedInCircle:self.circleStatus :self.activityMemberId];
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
                BOOL blockStatus = [[dict valueForKey:@"is_blocked"]boolValue];
                [Utility showAlertMessage:@"" withTitle:[dict valueForKey:@"message"]];
                if (blockStatus) {
                    blockStatus = YES;
                  }
                else{
                    blockStatus = NO;
                 }
                if([self.delegate respondsToSelector:@selector(memberSuccessfullyBlocked::)])
                   [self.delegate memberSuccessfullyBlocked:blockStatus :self.activityMemberId];
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
        {    DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

@end

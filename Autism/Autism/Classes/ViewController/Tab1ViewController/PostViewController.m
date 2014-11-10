//
//  PostViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "PostViewController.h"
#import "AttachLinkViewController.h"
#import "CustomTextField.h"
#import "MyImageView.h"
#import "Utility.h"
#import "UIImage+ImageEffects.h"
#import "GzipCompression.h"
#import "AttachLinkView.h"
#import "AttachVideoView.h"
#import "CTAssetsPickerController.h"
#import "PostUpdateCollectionViewCell.h"
#import "EXPhotoViewer.h"
#import "MemebersListAutoCompleteCell.h"
#import "NSDictionary+HasValueForKey.h"



@interface PostViewController ()<UIImagePickerControllerDelegate,UITextViewDelegate,UINavigationControllerDelegate,UITextFieldDelegate, AttachVideoViewDelegate, AttachLinkViewDelegate, CTAssetsPickerControllerDelegate, UIActionSheetDelegate>
{
    UIView *attachView;
    CustomTextField *txtUrlFetchImage;
    UIButton *btnGo;
    UIButton *btnNextForView;
    UIButton *btnPreviousForView;
    UIButton *btnSelectImage;
    UIButton *btnCancel;
    UIActionSheet *btnPostUpdateCategory;
}

@property (nonatomic) BOOL didStartDownload;
@property (strong, nonatomic) MJAutoCompleteManager *autoCompleteMgr;
@property (weak, nonatomic) IBOutlet UIView *autoCompleteContainer;
@property (nonatomic, strong) NSMutableArray *memberList;


@property (weak, nonatomic) IBOutlet UIButton *postUpdateButton;
@property (nonatomic, strong) AttachVideoView *attachVideoView;
@property (nonatomic, strong) AppDelegate *appDel;

@property (nonatomic,strong) UIView *popUpView;
@property (weak, nonatomic) IBOutlet UILabel *attachLinkTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *attachVideoUrlTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *attachLinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoUrlLabel;
@property (strong, nonatomic) IBOutlet MyImageView *attachedImagViewFromLink;
@property (strong, nonatomic) NSData *compressedImageDataForAttachPic;
@property (strong, nonatomic) NSString *base64StringForAttachPicFromLink;
@property (strong, nonatomic) NSString *base64StringForAttachPicFromPhotoLibrary;
@property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) NSString *attachedImageLinkFullUrl;
@property (strong, nonatomic) NSString *visibleAttachedLinkWithHttpVerb;
@property (weak, nonatomic) IBOutlet UIButton *removeAttachLinkButton;
@property (weak, nonatomic) IBOutlet UIButton *removeLinkTextButton;
@property (weak, nonatomic) IBOutlet UIButton *removeVideoUrlTextButton;
@property (weak, nonatomic) IBOutlet UIButton *attachLinkButton;
@property (weak, nonatomic) IBOutlet UIButton *attachVideoButton;

@property(strong,nonatomic) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *assets;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) AttachLinkView *attachLink;

@property (nonatomic, strong) UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *attachLinkImageContainerButton;

- (IBAction)attachPhoto:(id)sender;
- (IBAction)attachLink:(id)sender;
- (IBAction)postUPdate:(id)sender;
- (IBAction)attachedVideoButtonTapped:(id)sender;
- (IBAction)removePhotoLibraryButtonPressed:(id)sender;
- (IBAction)removeAttachLinkButtonPressed:(id)sender;
- (IBAction)removeLinkTextButtonPressed:(id)sender;
- (IBAction)removeVideoUrlTextButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)attachLinkImageContainerButtonPressed:(id)sender;

@end

@implementation PostViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.memberList = [NSMutableArray array];
        self.appDel = [[UIApplication sharedApplication] delegate];
        [self getMembersList];
        DLog(@"memberList Count:%lu",(unsigned long)self.appDel.memberListArray.count);
        
        self.autoCompleteMgr = [[MJAutoCompleteManager alloc] init];
        self.autoCompleteMgr.dataSource = self;
        self.autoCompleteMgr.delegate = self;
        
        // For the @ trigger, it is much more complex, with lots of async thingies */
        MJAutoCompleteTrigger *atTrigger = [[MJAutoCompleteTrigger alloc] initWithDelimiter:@"@"];
        atTrigger.cell = @"MemebersListAutoCompleteCell";
        [self.autoCompleteMgr addAutoCompleteTrigger:atTrigger];
        
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Add Observer for reciveing Notification when user tapped on menu button
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(receivedHideKeyboardNotification:) name:kHideKeyboardFromPostViewController object:nil];

    self.txtViewPost.text = @"";
    
    if ([self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage]||[self.callerView isEqualToString:kPostUpdateTypeSendMessage])
    {
        self.textView.hidden = YES;
        self.txtViewPost.hidden = NO;
    }
    else
    {
        self.textView.hidden = NO;
        self.txtViewPost.hidden = YES;
    }

    self.appDel = [[UIApplication sharedApplication] delegate];

    btnPostUpdateCategory = [[UIActionSheet alloc] init];
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    
    self.txtViewPost.delegate = self;
    [self.attachedImagViewFromLink.layer setBorderColor: [[UIColor colorWithRed:196/255.0f green:196/255.0f blue:196/255.0f alpha:1.0f] CGColor]];
    [self.attachedImagViewFromLink.layer setBorderWidth: 2.0];
    self.attachedImagViewFromLink.layer.cornerRadius = 4;
    self.attachedImagViewFromLink.layer.masksToBounds = YES;
    self.attachedImagViewFromLink.contentMode = UIViewContentModeScaleAspectFill;
    
    self.txtViewPost.layer.cornerRadius = 6.0f;
    self.txtViewPost.clipsToBounds = YES;
    
    self.textView.delegate = self;

    self.autoCompleteMgr.container = self.autoCompleteContainer;
    
    if (!IS_IPHONE_5)
        [self.scrollView setContentSize:CGSizeMake(320, 725)];
    else
        [self.scrollView setContentSize:CGSizeMake(320, 660)];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self isMovingToParentViewController])
    {
        DLog(@"isMovingToParentViewController");
        if (self.imageArray.count > 0) {
            [self.imageArray removeAllObjects];
            
        }
        if (self.assets.count > 0) {
            [self.assets removeAllObjects];
        }
        [self.collectionView reloadData];
    }
    
    if ([self.callerView isEqualToString:kPostUpdateTypeSendMessage])
    {
        self.attachVideoButton.hidden = YES;
        CGRect frame =  self.attachLinkButton.frame;
        frame.origin.x = 112;
        self.attachLinkButton.frame = frame;
        self.title = @"Send Message";
        
        frame =  self.postUpdateButton.frame;
        frame.origin.x -= 3;
        frame.size.width += 7;
        self.postUpdateButton.frame = frame;
        
        [self.postUpdateButton setTitle:@"Send Message" forState:UIControlStateNormal];
    }
    
    if ([self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage])
    {
        self.attachVideoButton.hidden = YES;
        CGRect frame =  self.attachLinkButton.frame;
        frame.origin.x = 112;
        self.attachLinkButton.frame = frame;
        self.title = @"Send Message";
        
        frame =  self.postUpdateButton.frame;
        frame.origin.x -= 3;
        frame.size.width += 7;
        self.postUpdateButton.frame = frame;
        
        if (!IS_IPHONE_5)
            [self.scrollView setContentSize:CGSizeMake(320, 650)];
        else
            [self.scrollView setContentSize:CGSizeMake(320, 560)];
        
        [self.postUpdateButton setTitle:@"Send Message" forState:UIControlStateNormal];
    }
    
    
    if ((self.appDel.isPostUploadInboxMessageTaskRunning && [self.callerView isEqualToString:kPostUpdateTypePostUpdate] ) || (self.appDel.isPostUploadOtherTaskRunning && [self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]) || (self.appDel.isPostUploadInboxMessageTaskRunning && [self.callerView isEqualToString:kPostUpdateTypeSendMessage])  || (self.appDel.isPostUploadMyTaskRunning && [self.callerView isEqualToString:kPostUpdateTypePostUpdateMy]) || (self.appDel.isPostUploadMyTaskRunning && [self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage]))
    {
        [self showProgressView];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self resignFirstResponders];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPostUpdateTypePostUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:[PostViewController class] name:kHideKeyboardFromPostViewController object:nil];
    
    

}

#pragma mark - Attach Photos
- (IBAction)attachPhoto:(id)sender {
    
        self.attachedImagViewFromLink.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 335, 100, 100);
        self.attachLinkImageContainerButton.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 335, 100, 100);
        self.removeAttachLinkButton.frame = CGRectMake(self.removeAttachLinkButton.frame.origin.x, 317, 21  , 21);
        
        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 455, 83, 21);
        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 455, 195, 21);
        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 449, 21, 21);
    
    if (![self.videoUrl length] == 0 && ![self.attachedImageLinkFullUrl length] == 0) {
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 486, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 486, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 480, 21, 21);
    }else
    {
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 335, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 335, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 338, 21, 21);
        
       
    }
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allAssets];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.selectedAssets       = [NSMutableArray arrayWithArray:self.assets];
    
    if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther] || [self.callerView isEqualToString:kPostUpdateTypeSendMessage] || [self.callerView isEqualToString:kPostUpdateTypePostUpdateMy] || [self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage]) {
        [self presentViewController:picker animated:YES completion:^{}];
    }
    else {
        [[appDelegate rootNavigationController] presentViewController:picker animated:YES completion:^{}];
    }
}


//// Hash Tagging Code

/*
 ** Update Hotwords range if user do editing before to hotword and remove hotword from dictionary if editing between hotwords.
 */
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    DLog(@"textView.text:%@ \n range:%@, \n text:%@ \n selectedRange.location:%@",textView.text, NSStringFromRange(range), text, NSStringFromRange(textView.selectedRange));
    
    if (range.length == 0 && text.length==0)
    {
        [self highlightHotWordsInTextView:textView];
        return NO;
    }
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        self.autoCompleteContainer.hidden = YES;
        return NO;
    }
    BOOL isMovingBackword = (range.length > 0 && text.length == 0) ? YES : NO;
    
    NSRange hotWordRange;
    NSMutableDictionary *dict;
    
    for (NSUInteger i = 0; i< self.autoCompleteMgr.rangesOfSelectedHotWords.count; i++) {
        dict = (NSMutableDictionary*)[self.autoCompleteMgr.rangesOfSelectedHotWords objectAtIndex:i];
        hotWordRange = [[dict objectForKey:@"range"] rangeValue];
        
        //Check if current position is tuching to Hotword end location then put space between these two.
        if (text.length && (range.location == (hotWordRange.location + hotWordRange.length)))
        {
            textView.text  = [textView.text stringByReplacingCharactersInRange:range withString: [NSString stringWithFormat: @" "]];
            NSRange updatedRange = range;
            updatedRange.location += 1;
            textView.selectedRange = updatedRange;
            [self highlightHotWordsInTextView:textView];
            textView.selectedRange = updatedRange;
        }
        
        //Check cursor postion is behind hotword if
        if (range.location <= hotWordRange.location) {
            //Then change hotword location
            if (isMovingBackword) {         // user deleting text
                hotWordRange.location -= range.length;
            }
            else // user updating/typing text
            {
                if (text.length) {
                    hotWordRange.location += text.length;
                } else
                {
                    hotWordRange.location += 1;
                }
            }
            NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [newDict removeObjectForKey:@"range"];
            [newDict setObject:[NSValue valueWithRange: hotWordRange] forKey:@"range"];
            [self.autoCompleteMgr.rangesOfSelectedHotWords replaceObjectAtIndex:i withObject:newDict];
            
        }
        
        DLog(@"Start------ \n range :%@ \n hotWordRange :%@ \n selectedRange:%@",NSStringFromRange(range), NSStringFromRange(hotWordRange), NSStringFromRange(textView.selectedRange));
        
        DLog(@"range.location :%d \n (hotWordRange.location + hotWordRange.length) :%d \n------End",range.location, (hotWordRange.location + hotWordRange.length));
        
        //Check cursor postion is in middle of hotword then make it normal word and remove form hodword dict
        
        if ((range.location > hotWordRange.location) && (range.location < (hotWordRange.location + hotWordRange.length)))
        {
            
            DLog(@"Rang intersect");
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:textView.text];
            [attributedString removeAttribute:NSBackgroundColorAttributeName range:hotWordRange];
            [attributedString removeAttribute:NSForegroundColorAttributeName range:hotWordRange];
            textView.attributedText = attributedString;
            
            [self.autoCompleteMgr.rangesOfSelectedHotWords removeObject:dict];
            [self highlightHotWordsInTextView:textView];
            textView.selectedRange = range;
            
            if ([dict hasValueForKey:@"taggedMember"])
            {
                MJAutoCompleteItem *aCompleteItem = [dict valueForKey:@"taggedMember"];
                [self.memberList addObject:aCompleteItem];
            }
        }
        
    }
    return YES;
}


- (void)highlightHotWordsInTextView:(UITextView *)textView
{
    NSRange range;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:textView.text];
    for (NSDictionary *dict in self.autoCompleteMgr.rangesOfSelectedHotWords) {
        range = [[dict objectForKey:@"range"] rangeValue];
        
        @try {
            
            [attributedString addAttribute:NSBackgroundColorAttributeName
                                     value:[UIColor colorWithRed:44/255.0f green:173/255.0f blue:182/255.0f alpha:1.0f]
                                     range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor whiteColor]
                                     range:range];
        }
        @catch (NSException *e ) {
            DLog(@"Exeption:%@ \n Exception Reson:%@",e.userInfo, e.reason);
        }
        
    }
    textView.attributedText = attributedString;
}




- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.textView) {
        
        [self.autoCompleteMgr processString:textView.text];
      }
    
}

#pragma mark - MJAutoCompleteMgr DataSource Methods

- (void)autoCompleteManager:(MJAutoCompleteManager *)acManager
         itemListForTrigger:(MJAutoCompleteTrigger *)trigger
                 withString:(NSString *)string
                   callback:(MJAutoCompleteListCallback)callback
{
    if ([trigger.delimiter isEqual:@"@"])
    {
        self.autoCompleteContainer.hidden = NO;
        
        if (!self.didStartDownload)
        {
            self.didStartDownload = YES;
            for (Member *member in self.appDel.memberListArray)
            {
                NSString * acString = member.name;
                
                MJAutoCompleteItem *item = [[MJAutoCompleteItem alloc] init];
                item.autoCompleteString = acString;
                item.member = member;
                
                [self.memberList addObject:item];
            }
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               trigger.autoCompleteItemList = self.memberList;
                               callback(self.memberList);
                           });
        }
        else
        {
            callback(self.memberList);
            
        }
    }
}

#pragma mark - MJAutoCompleteMgr Delegate methods

- (void)autoCompleteManager:(MJAutoCompleteManager *)acManager shouldUpdateToText:(NSString *)newText
{
    self.textView.text = newText;
    [self highlightHotWordsInTextView:self.textView];
    
    for (MJAutoCompleteItem *item in self.memberList) {
        if([item isEqual:acManager.selectedItem]) {
            DLog(@"correct.........., self.memberListCoutn:%lu",(unsigned long)self.memberList.count);
            DLog(@"name:%@ \n memberId:%@",item.member.name, item.member.memberId);
            [self.memberList removeObject:item];
            DLog(@"memberListCoutn:%lu",(unsigned long)self.memberList.count);
            
            self.autoCompleteContainer.hidden = YES;
            
            break;
        
        }
    }
}


-(void)getMembersList
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *requestParameters = @{ @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                         };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMemberList];
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,requestUrl, requestParameters);
    
    [serviceManager executeServiceWithURL:requestUrl andParameters:requestParameters forTask:kTaskGetMemberList completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api \n response:%@",__FUNCTION__,requestUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                self.appDel.memberListArray = [parsingManager parseResponse:response forTask:task];
                NSMutableArray *membersList = [NSMutableArray array];
                
                for (Member *member in self.appDel.memberListArray)
                {
                    NSString * acString = member.name;
                    MJAutoCompleteItem *item = [[MJAutoCompleteItem alloc] init];
                    item.autoCompleteString = acString;
                    item.member = member;
                    // DLog(@"----name:%@ \n id:%@, \n avatar:%@",member.name, member.memberId, member.avatar);
                    [membersList addObject:item];
                }
                self.memberList = nil;
                self.memberList = membersList;
            }
            else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }
        else {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}



- (NSString*)getCommentTextAfterReplacingHashTagToMemberID
{
    NSMutableString *commentString = [[NSMutableString alloc] initWithString: self.textView.text];
    if([Utility getValidString:commentString].length < 1)
        return @"";
    DLog(@"commentString:%@",commentString);
    
    NSRange range;
    NSDictionary *dict;
    NSInteger hotwordCount = self.autoCompleteMgr.rangesOfSelectedHotWords.count -1;
    if(hotwordCount < 0)
        return commentString;
    
    for (NSInteger i = hotwordCount;  i >= 0; i--) {
        
        dict = [self.autoCompleteMgr.rangesOfSelectedHotWords objectAtIndex:i];
        range = [[dict objectForKey:@"range"] rangeValue];
        if ([dict hasValueForKey:@"taggedMember"])
        {
            MJAutoCompleteItem *aCompleteItem = [dict valueForKey:@"taggedMember"];
            [self.memberList addObject:aCompleteItem];
            
            @try {
                
                [commentString replaceCharactersInRange:range withString:[NSString stringWithFormat:@"@%@",aCompleteItem.member.memberId]];
            }
            @catch (NSException *e ) {
                
                DLog(@"Exeption:%@ \n Exception Reson:%@",e.userInfo, e.reason);
                return commentString;
            }
            DLog(@"Tagged Member name:%@",aCompleteItem.member.name);
        
        }
    }
    DLog(@"commentString replaceing with id:%@",commentString);
    
    return commentString;
}

//// Hash tagging

-(void)gestureEvent
{
    [attachView removeFromSuperview];
}

- (IBAction)removePhotoLibraryButtonPressed:(id)sender {
    long selectedButtonIndex = ((UIButton*)sender).tag;
    [self.imageArray removeObjectAtIndex:selectedButtonIndex];
    [self.assets removeObjectAtIndex:selectedButtonIndex];

    [self.collectionView reloadData];
    
    if (self.imageArray.count == 0 ) {
        self.attachedImagViewFromLink.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
        self.attachLinkImageContainerButton.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
        self.removeAttachLinkButton.frame = CGRectMake(self.removeAttachLinkButton.frame.origin.x, 187, 20, 20);
        
        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 325, 83, 21);
        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 325, 195, 21);
        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 319, 20, 20);
    }
    if (![self.videoUrl length] == 0 ) {
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 354, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 354, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 348, 20, 20);
    }
   if ( [self.attachedImageLinkFullUrl length] == 0 && (self.imageArray.count == 0))
    {
        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 200, 83, 21);
        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 200, 195, 21);
        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 194, 20, 20);
        
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 237, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 237, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 237, 20, 20);
    }
}

- (IBAction)removeAttachLinkButtonPressed:(id)sender {
    self.attachedImagViewFromLink.image = [UIImage imageNamed:@"default_attached_image.png"];
    self.removeAttachLinkButton.hidden = YES;
    self.attachedImageLinkFullUrl = @"";
    self.attachedImagViewFromLink.hidden = YES;
    self.attachLinkImageContainerButton.userInteractionEnabled = NO;
    
    if (self.imageArray.count == 0 ) {
//        self.attachedImagViewFromLink.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
//        self.attachLinkImageContainerButton.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
//        self.removeAttachLinkButton.frame = CGRectMake(self.removeAttachLinkButton.frame.origin.x, 187, 18  , 18);
        
        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 200, 83, 21);
        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 200, 195, 21);
        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 194, 20, 20);
        
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 237, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 237, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 237, 20, 20);
    }else{
        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 335, 83, 21);
        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 335, 195, 21);
        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 329, 20, 20);
    
           self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 375, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 375, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 369, 20, 20);
    }

}

- (IBAction)removeLinkTextButtonPressed:(id)sender {
    self.attachLinkLabel.text = @"No Link";
    self.removeLinkTextButton.hidden = YES;
    self.visibleAttachedLinkWithHttpVerb = @"";
    
    self.attachLinkTitleLabel.hidden = YES;
    self.attachLinkLabel.hidden = YES;
}

- (IBAction)removeVideoUrlTextButtonPressed:(id)sender {
    self.videoUrlLabel.text = @"No Url";
    self.videoUrl = @"";
    self.removeVideoUrlTextButton.hidden = YES;
    
    self.attachVideoUrlTitleLabel.hidden = YES;
    self.videoUrlLabel.hidden = YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    self.txtViewPost.text = @"";
    
    [self.postUpdateProgressView removeFromSuperview];
    self.postUpdateProgressView = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)attachLinkImageContainerButtonPressed:(id)sender {
    if (self.attachedImagViewFromLink.image)
        [EXPhotoViewer showImageFrom:self.attachedImagViewFromLink];
}

- (IBAction)postUPdate:(id)sender {

    DLog(@"%s",__FUNCTION__ );
    
    //Testing code for  Post Multiple image/ Multipart data
    /*[self testMultipleImage];
    return;*/
    if ([self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage]||[self.callerView isEqualToString:kPostUpdateTypeSendMessage])
    {
         [self performSendMessageAPI];
    }
    else if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]||[self.callerView isEqualToString:kPostUpdateTypePostUpdateMy])
    {
        [self postUpdateApiCall];
    
     }
    else{
        [self postUpdateApiCall];
    /*UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select PostUpdate Category" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Post to Circle",
                            @"Post to Publicly",
                            nil];
     popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];*/

    } 
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                    
                case 0: {
                    [self postUpdateApiCallInCircle];
                }
                    break;
                case 1: {
                    [self postUpdateApiCall];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        }
        default:
            
            break;
    }
}


-(void)postUpdateApiCall {
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSString *commentString = @"";
    commentString = [self getCommentTextAfterReplacingHashTagToMemberID];
    if (!([Utility getValidString:self.txtViewPost.text].length > 0 || self.videoUrl.length > 0 || self.imageArray.count > 0 || self.attachedImageLinkFullUrl.length > 0 || self.visibleAttachedLinkWithHttpVerb.length >0)) {
        [Utility showAlertMessage:@"" withTitle:@"Please fill the required fields."];
        return;
    }
    [self showProgressView];
    
    if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]) {
        self.appDel.isPostUploadOtherTaskRunning = YES;
    }else if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateMy]) {
        self.appDel.isPostUploadMyTaskRunning = YES;
    } else if ([self.callerView isEqualToString:kPostUpdateTypeSendMessage]) {
        [self performSendMessageAPI];
       self.appDel.isPostUploadMyTaskRunning = YES;
    }
    else if ([self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage]) {
        [self performSendMessageAPI];
        return;
     }
   else {
        self.appDel.isPostUploadTaskRunning = YES;
     }
    
     NSString *correctVideoURL = [self getUrlWithoutMExetention:self.videoUrl];
    
    NSDictionary *postParameters = @ {
        @"member_id"                    : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
        @"activityPost"                 : [Utility getValidString:commentString],
        @"activityPostLink"             : (self.attachedImageLinkFullUrl.length > 0 ? self.attachedImageLinkFullUrl : @"" ), //full image url
        @"activityPosWebLink"           : (self.visibleAttachedLinkWithHttpVerb.length > 0 ? self.visibleAttachedLinkWithHttpVerb : @""),  //original site url.
        @"activityType"                 : [NSString stringWithFormat:@"%d",PostTypePublic],
        @"activityVideoLink"            : (correctVideoURL.length > 0 ? correctVideoURL : @""),
        @"other_member_id"              : [Utility getValidString:self.otherMemberId].length > 0 ? [Utility getValidString:self.otherMemberId ]: [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
    };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostActivity];
    
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__, requestUrl,postParameters);
    
   self.postUpdateButton.userInteractionEnabled = NO;
    TaskType taskType;
   
    if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]) {
        taskType = kTaskPostUpdateOther;
    } else if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateMy]) {
        taskType = kTaskPostUpdateMy;
    } else {
        taskType = kTaskPostUpdate;
    }
    
    [serviceManager executePostImageServiceWithURL:requestUrl postParameters:postParameters imageArray:self.imageArray object:self forTask:taskType completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, %@ api response:%@",__FUNCTION__,requestUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                [Utility showAlertMessage:@"" withTitle:@"your update is successfully posted!"];
                if ([self.delegate respondsToSelector:@selector(postUpdatedSuccesfully)]) {
                    [self.delegate postUpdatedSuccesfully];
                }
                
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                if ([[dict valueForKey:@"is_blocked"] boolValue] || [[dict valueForKey:@"is_you_blocked"] boolValue]){
                    [Utility showAlertMessage:@"You cannot send a message to this user at this time. If you want to know why, please contact AWM." withTitle:@""];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else {
            DLog(@"Error:%@", error);
            if ([[error localizedDescription] isEqualToString:@"cancelled"])
                [Utility showAlertMessage:@"Post Update Cancelled" withTitle:@""];
            else
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        if (task == kTaskPostUpdate) {
            self.appDel.isPostUploadTaskRunning = NO;
        } else if (task == kTaskPostUpdateOther) {
            self.appDel.isPostUploadOtherTaskRunning = NO;
        }else if (task == kTaskPostUpdateMy) {
            self.appDel.isPostUploadMyTaskRunning = NO;
        }
        self.postUpdateButton.userInteractionEnabled = YES;
        [self clearPostedData];
    }];
}



-(void)postUpdateApiCallInCircle {
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!([Utility getValidString:self.txtViewPost.text].length > 0 || self.videoUrl.length > 0 || self.imageArray.count > 0 || self.attachedImageLinkFullUrl.length > 0 || self.visibleAttachedLinkWithHttpVerb.length >0)) {
        [Utility showAlertMessage:@"" withTitle:@"Please fill the required fields."];
        return;
    }
    [self showProgressView];
    
    if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]) {
        self.appDel.isPostUploadOtherTaskRunning = YES;
    }else if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateMy]) {
        self.appDel.isPostUploadMyTaskRunning = YES;
    } else if ([self.callerView isEqualToString:kPostUpdateTypeSendMessage]) {
        [self performSendMessageAPI];
        self.appDel.isPostUploadMyTaskRunning = YES;
    }
    else if ([self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage]) {
        [self performSendMessageAPI];
        return;
    }
    else {
        self.appDel.isPostUploadTaskRunning = YES;
    }
    
    NSString *correctVideoURL = [self getUrlWithoutMExetention:self.videoUrl];
    
    DLog(@"ccorrect email %@",correctVideoURL);
    
   
    NSDictionary *postParameters = @ {
        @"member_id"                    : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
        @"activityPost"                 : [Utility getValidString:self.txtViewPost.text],
        @"activityPostLink"             : (self.attachedImageLinkFullUrl.length > 0 ? self.attachedImageLinkFullUrl : @"" ), //full image url
        @"activityPosWebLink"           : (self.visibleAttachedLinkWithHttpVerb.length > 0 ? self.visibleAttachedLinkWithHttpVerb : @""),  //original site url.
        @"activityType"                 : [NSString stringWithFormat:@"%d",PostTypeCircle],
        @"activityVideoLink"            : (correctVideoURL.length > 0 ? correctVideoURL : @""),
        @"other_member_id"              : [Utility getValidString:self.otherMemberId].length > 0 ? [Utility getValidString:self.otherMemberId ]: [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
    };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostActivity];
    DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__, requestUrl,postParameters);
    self.postUpdateButton.userInteractionEnabled = NO;
    TaskType taskType;
    
    if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]) {
        taskType = kTaskPostUpdateOther;
    } else if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateMy]) {
        taskType = kTaskPostUpdateMy;
    } else {
        taskType = kTaskPostUpdate;
    }
    
    [serviceManager executePostImageServiceWithURL:requestUrl postParameters:postParameters imageArray:self.imageArray object:self forTask:taskType completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, %@ api response:%@",__FUNCTION__,requestUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                [Utility showAlertMessage:@"" withTitle:@"your update is successfully posted!"];
                if ([self.delegate respondsToSelector:@selector(postUpdatedSuccesfully)]) {
                    [self.delegate postUpdatedSuccesfully];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                if ([[dict valueForKey:@"is_blocked"] boolValue] || [[dict valueForKey:@"is_you_blocked"] boolValue]){
                    [Utility showAlertMessage:@"You cannot send a message to this user at this time. If you want to know why, please contact AWM." withTitle:@""];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else {
            DLog(@"Error:%@", error);
            if ([[error localizedDescription] isEqualToString:@"cancelled"])
                [Utility showAlertMessage:@"Post Update Cancelled" withTitle:@""];
            else
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        if (task == kTaskPostUpdate) {
            self.appDel.isPostUploadTaskRunning = NO;
        } else if (task == kTaskPostUpdateOther) {
            self.appDel.isPostUploadOtherTaskRunning = NO;
        }else if (task == kTaskPostUpdateMy) {
            self.appDel.isPostUploadMyTaskRunning = NO;
        }
        self.postUpdateButton.userInteractionEnabled = YES;
        [self clearPostedData];
    }];
}



-(NSString *)getUrlWithoutMExetention:(NSString*)mobileUrl
{
    
    if ([mobileUrl rangeOfString:@"https://m."].location != NSNotFound) {
        
        mobileUrl = [mobileUrl stringByReplacingOccurrencesOfString:@"https://m." withString:@"https://www."];
        
        
    } else if ([mobileUrl rangeOfString:@"http://m."].location != NSNotFound) {
        
        mobileUrl = [mobileUrl stringByReplacingOccurrencesOfString:@"http://m." withString:@"http://www."];
        
    }
    
    return mobileUrl;
}


-(void)testMultipleImage
{
    [self showProgressView];

    NSDictionary *postParameters = @ {
        @"member_id"                    : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
        @"activityPost"                 : [Utility getValidString:self.txtViewPost.text],
        @"activityPostLink"             : (self.attachedImageLinkFullUrl.length > 0 ? self.attachedImageLinkFullUrl : @"" ), //full image url
        @"activityPostImage"            : self.base64StringForAttachPicFromPhotoLibrary ? self.base64StringForAttachPicFromPhotoLibrary : @"",
        @"activityPosWebLink"           : (self.visibleAttachedLinkWithHttpVerb.length > 0 ? self.visibleAttachedLinkWithHttpVerb : @""),  //original site url.
        @"activityType"                 : [NSString stringWithFormat:@"%d",PostTypePublic],
        @"activityVideoLink"            : (self.videoUrl.length > 0 ? self.videoUrl : @""),
        @"other_member_id"              : [Utility getValidString:self.otherMemberId].length > 0 ? [Utility getValidString:self.otherMemberId ]: [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
    };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_PostMultiImage];
    DLog(@"Performing %@ api",requestUrl);
    
    [serviceManager executePostImageServiceWithURL:requestUrl postParameters:postParameters imageArray:self.imageArray object:self forTask:kTaskImageUploading completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"Test multiple image api response:%@", response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                [Utility showAlertMessage:@"" withTitle:@"You Posted Successfully!"];
                if ([self.delegate respondsToSelector:@selector(postUpdatedSuccesfully)]) {
                    [self.delegate postUpdatedSuccesfully];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else {
            DLog(@"Error:%@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self clearPostedData];
    }];
}




-(void)performSendMessageAPI
{
    if ([Utility getValidString:self.otherMemberId].length <1) {
        DLog(@"%s Can not perform this action because other user id is blank",__FUNCTION__);
        return;
    }
    
    if (!([Utility getValidString:self.txtViewPost.text].length > 0 || self.videoUrl.length > 0 || self.imageArray.count > 0 || self.attachedImageLinkFullUrl.length > 0 || self.visibleAttachedLinkWithHttpVerb.length >0)) {
        [Utility showAlertMessage:@"" withTitle:@"Please fill the required fields."];
        return;
    }
    
    NSDictionary *postParameters = @ {
        @"inboxPostMessage"        : [Utility getValidString:self.txtViewPost.text],
        @"inboxPostLink"           : (self.attachedImageLinkFullUrl.length > 0 ? self.attachedImageLinkFullUrl : @"" ), //full image url
        @"inboxPosWebLink"         : (self.visibleAttachedLinkWithHttpVerb.length > 0 ? self.visibleAttachedLinkWithHttpVerb : @""),  //original site url.
        @"inboxVideoLink"          : (self.videoUrl.length > 0 ? self.videoUrl : @""),
        @"member_id"               : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
        @"inbox_member_id"         : [Utility getValidString:self.otherMemberId]
    };
    
    self.postUpdateButton.userInteractionEnabled = NO;
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostInboxMessage];
    
    DLog(@"%s, Performing %@ api /n with parametere:%@", __FUNCTION__, requestUrl,postParameters);
    
    self.appDel.isPostUploadInboxMessageTaskRunning = YES;
    [serviceManager executePostImageServiceWithURL:requestUrl postParameters:postParameters imageArray:self.imageArray object:self forTask:kTaskPostInboxMessage completionHandler:^(id response, NSError *error, TaskType task) {

        DLog(@"%s %@ api response:%@",__FUNCTION__,requestUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                [Utility showAlertMessage:@"" withTitle:@"Your Message Send Successfully!"];
                if ([self.delegate respondsToSelector:@selector(postUpdatedSuccesfully)]) {
                    [self.delegate postUpdatedSuccesfully];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                if ([[dict valueForKey:@"is_blocked"] boolValue] || [[dict valueForKey:@"is_you_blocked"] boolValue]){
                    [Utility showAlertMessage:@"You cannot send a message to this user at this time. If you want to know why, please contact AWM." withTitle:@""];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else {
            DLog(@"Error:%@", error);
            if ([[error localizedDescription] isEqualToString:@"cancelled"])
                [Utility showAlertMessage:@"Message Sending Cancelled" withTitle:@""];
            else
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        self.postUpdateButton.userInteractionEnabled = YES;
        [self clearPostedData];
        self.appDel.isPostUploadInboxMessageTaskRunning = NO;
    }];
}

- (void)clearPostedData
{
    self.txtViewPost.text = @"";
    self.selectedImage = nil;
    self.attachedImageLinkFullUrl = @"";
    self.visibleAttachedLinkWithHttpVerb = @"";
    self.base64StringForAttachPicFromPhotoLibrary = @"";
    self.videoUrl = @"";
    
    self.attachLinkTitleLabel.hidden = YES;
    self.attachLinkLabel.hidden = YES;

    self.attachVideoUrlTitleLabel.hidden = YES;
    self.videoUrlLabel.hidden = YES;
    
    self.attachedImagViewFromLink.hidden = YES;
    self.attachLinkImageContainerButton.userInteractionEnabled = NO;

    self.removeAttachLinkButton.hidden = YES;
    self.removeVideoUrlTextButton.hidden = YES;
    self.removeLinkTextButton.hidden = YES;
    
    [self.postUpdateProgressView removeFromSuperview];
    self.postUpdateProgressView = nil;

    [self.imageArray removeAllObjects];
    [self.assets removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark - AttachLinkViewDelegate

- (void)attachedImageUrl:(NSString*)imageUrl withVisibleUrl:(NSString*)visibleUrl{
    if (self.imageArray.count == 0 ) {
        self.attachedImagViewFromLink.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
        self.attachLinkImageContainerButton.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
        self.removeAttachLinkButton.frame = CGRectMake(self.removeAttachLinkButton.frame.origin.x, 187, 20  , 20);
        
        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 325, 83, 21);
        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 325, 195, 21);
        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 319, 20, 20);
    }
    if (self.imageArray.count > 0 && ![self.videoUrl length] == 0 ) {
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 486, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 486, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 480, 20, 20);
    }else
    {
//    if (![self.videoUrl length] == 0 ) {
                self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 354, 56, 21);
                self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 354, 195, 21);
                self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 348, 20, 20);
    }
    
        
    
   
    
    if (visibleUrl) {
        self.attachLinkLabel.text = visibleUrl;
        self.removeLinkTextButton.hidden = NO;
        self.attachLinkLabel.hidden = NO;
        self.attachLinkTitleLabel.hidden = NO;
        self.visibleAttachedLinkWithHttpVerb = [Utility getUrlStringWithHttpVerb:visibleUrl];
    }
    if (imageUrl.length > 0) {
        self.attachedImageLinkFullUrl = imageUrl;
        self.removeAttachLinkButton.hidden = NO;
        self.attachedImagViewFromLink.hidden = NO;
        self.attachLinkImageContainerButton.userInteractionEnabled = YES;

        [self.attachedImagViewFromLink configureImageForUrl:imageUrl];
    }
    
}

- (IBAction)attachLink:(id)sender {
    
    CGRect frame;
if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]|| [self.callerView isEqualToString:kPostUpdateTypePostUpdateMy] || [self.callerView isEqualToString:kPostUpdateTypeSendMessage]|| [self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage])
    {
        frame = CGRectMake(self.view.frame.origin.x, 63, self.view.frame.size.width,  self.view.frame.size.height);
    }
else{
      frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width,  self.view.frame.size.height);
    }
    self.attachLink = [[AttachLinkView alloc] initWithFrame:frame];
    self.attachLink.delegate = self;
    [self.view addSubview:self.attachLink];
}

#pragma mark - AttachVideoViewDelegate

- (IBAction)attachedVideoButtonTapped:(id)sender {
    CGRect frame ;
    
    if ([self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]|| [self.callerView isEqualToString:kPostUpdateTypePostUpdateMy] || [self.callerView isEqualToString:kPostUpdateTypeSendMessage]|| [self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage])
    {
        frame = CGRectMake(self.view.frame.origin.x, 63, self.view.frame.size.width,  self.view.frame.size.height);
    }
    else{
        frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width,  self.view.frame.size.height);
      }
    
    
    
    self.attachVideoView = [[AttachVideoView alloc] initWithFrame:frame];
    self.attachVideoView.delegate = self;
    [self.view addSubview:self.attachVideoView];
}

- (void)attachedVideoUrl:(NSString*)videoUrl visibleUrl:(NSString*)visibleUrl{
    
    self.videoUrl = videoUrl;
    
    if ((self.imageArray.count == 0) && ([self.visibleAttachedLinkWithHttpVerb length] == 0) && ([self.attachedImageLinkFullUrl length] == 0) ) {
        
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 200, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 200, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 200, 18, 18);
    }
    if ( ![self.attachedImageLinkFullUrl length] == 0 && (self.imageArray.count > 0))
    {
//        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 200, 83, 21);
//        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 200, 195, 21);
//        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 194, 20, 20);
        
        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 486, 56, 21);
        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 486, 195, 21);
        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 480, 20, 20);
    }


    
    if (visibleUrl) {
        self.videoUrlLabel.text = visibleUrl;
        self.removeVideoUrlTextButton.hidden = NO;
        self.attachVideoUrlTitleLabel.hidden = NO;
        self.videoUrlLabel.hidden = NO;
    }
}

- (BOOL)textViewShouldReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.txtViewPost = textView;
}

-(void)tappedOnView:(id)sender {
    [self.view endEditing:YES];
    [self resignFirstResponders];
}


#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.assets = [NSMutableArray arrayWithArray:assets];
    self.imageArray = [self getImagesFromSelectedAssets:self.assets];
    [self.collectionView reloadData];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

//Call when we select asset from Photo library
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{

    if (picker.selectedAssets.count >= 10)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Please select not more than 10 assets"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    return (picker.selectedAssets.count < 10 && asset.defaultRepresentation != nil);
    //return asset.defaultRepresentation != nil;

}

- (NSMutableArray*)getImagesFromSelectedAssets:(NSArray *)assets
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in assets) {
		id obj = [asset valueForProperty:ALAssetPropertyType];
		if (!obj) {
			continue;
		}
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		
		CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
		if (wgs84Location) {
			[workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
		}
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];
        
        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        
        if(assetRep != nil) {
            CGImageRef imgRef = nil;
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            UIImageOrientation orientation = UIImageOrientationUp;
            imgRef = [assetRep fullScreenImage];

            UIImage *img = [UIImage imageWithCGImage:imgRef
                                               scale:1.0f
                                         orientation:orientation];
            [returnArray addObject:img];
        }
		
	}
    return returnArray;
}


#pragma mark - Collectionview Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostUpdateCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectedImageView.image = [self.imageArray objectAtIndex:indexPath.row];
    cell.removePhotoLibraryPicButton.tag = indexPath.row;
    return cell;
}

#pragma mark - Progress View Methods

-(void)showProgressView {
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y - 150;
    
    if (!self.postUpdateProgressView) {
        self.postUpdateProgressView = [[UploadingProgressView alloc] initWithFrame:frame];
    }
    self.postUpdateProgressView.callerView = self.callerView;
    [self.view addSubview:self.postUpdateProgressView];
   
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSString *action = (__bridge NSString*)context;
    float progress = [[change valueForKey:@"new"] floatValue];
    //DLog(@"Uploading action:%@ \n progress:%f",action, progress);

    self.postUpdateProgressView.callerView = action;
    [self.postUpdateProgressView updateProgressBar:progress];
}

#pragma mark - HideKeyboardNotification

- (void)receivedHideKeyboardNotification:(NSNotification *)notification
{
    DLog("Get %@ From RootVC",notification.name);
    if (notification.name) {
        [self resignFirstResponders];
    }
}

- (void)resignFirstResponders
{
    if ([self.txtViewPost isFirstResponder]) {
        [self.txtViewPost resignFirstResponder];
    }
}

- (void)updateFramesForView:(NSString *)imageUrl withLink:(NSString *)attachlink andVideoUrl:(NSString *)videoUrl
{
//    
//    if (self.imageArray.count == 0) {
//        self.attachedImagViewFromLink.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
//        self.attachLinkImageContainerButton.frame = CGRectMake(self.attachedImagViewFromLink.frame.origin.x, 205, 100, 100);
//        self.removeAttachLinkButton.frame = CGRectMake(self.removeAttachLinkButton.frame.origin.x, 187, 18  , 18);
//        
//        self.attachLinkTitleLabel.frame = CGRectMake(self.attachLinkTitleLabel.frame.origin.x, 325, 83, 21);
//        self.attachLinkLabel.frame = CGRectMake(self.attachLinkLabel.frame.origin.x, 325, 195, 21);
//        self.removeLinkTextButton.frame = CGRectMake(self.removeLinkTextButton.frame.origin.x, 319, 18, 18);
//        
//        self.attachVideoUrlTitleLabel.frame = CGRectMake(self.attachVideoUrlTitleLabel.frame.origin.x, 354, 56, 21);
//        self.videoUrlLabel.frame = CGRectMake(self.videoUrlLabel.frame.origin.x, 354, 195, 21);
//        self.removeVideoUrlTextButton.frame = CGRectMake(self.removeVideoUrlTextButton.frame.origin.x, 348, 18, 18);
//    }
//    else if([self.attachedImageLinkFullUrl isEqualToString:@""])
//    {
//        DLog(@"dfdsfdsfdf");
//    }
}


@end

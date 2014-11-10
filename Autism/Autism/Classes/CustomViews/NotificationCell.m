//
//  NotificationCell.m
//  Autism
//
//  Created by Dipak on 6/10/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "NotificationCell.h"
#import "ProfileShowViewController.h"
#import "Utility.h"
#import "STTweetLabel.h"

@interface NotificationCell ()
@property (strong, nonatomic) NSString *notificationId;
@property (strong, nonatomic) IBOutlet STTweetLabel *notificationLabel;

- (IBAction)notificationDeleteButtonPressed:(id)sender;
@end

@implementation NotificationCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (NotificationCell *)cellFromNibNamed:(NSString *)nibName{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    NotificationCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[NotificationCell class]]) {
            customCell = (NotificationCell*)nibItem;
            break; // we have a winner
        }
    }
    
    return customCell;
}

-(void)configureCell:(Notification *)notifcation
{
    self.notificationId = notifcation.notificationId;
    NSString *notificationText = notifcation.notificationText;

    self.notificationLabel.callerView = kTitleNotifications;
    [self.notificationLabel setupFontColorOfHashTag];
    self.notificationLabel.notifcation = notifcation;
    [self.notificationLabel setText:notificationText];

    __weak typeof(self) weakSelf = self;
    
    [self.notificationLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *hotString, NSString *hotWorldID, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[kHotWordHandle, kHotWordHashtag,kHotWordLink, kHotWordNotification];
        NSString *selectedString = [NSString stringWithFormat:@"%@ [%d,%d]: hotWorld: %@, hotWorldID:%@, %@", hotWords[hotWord], (int)range.location, (int)range.length, hotString, hotWorldID,(protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
       
        DLog(@"selected hash String:%@",selectedString);
        //DLog(@"self.tag: %d, \n notificationText:%@, \n notificationType:%@",weakSelf.tag, notificationText, notifcation.notificationType);
        [weakSelf.delegate clickOnHashTag:hotWorldID hashType:hotWords[hotWord] forNotification:notifcation];
    }];
}


- (IBAction)notificationDeleteButtonPressed:(id)sender {
    DLog(@"%s",__FUNCTION__);
    [self deleteNotifcationApiCall];
}


-(void)deleteNotifcationApiCall
{
    DLog(@"%s",__FUNCTION__);
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if ([Utility getValidString:self.notificationId].length < 1)
    {
        DLog(@"Could not delete this notification because NotificationId does not exist");
        return;
    }

    NSDictionary *deleteNotifcationParameter = @{
                                               @"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               @"notification_id":[Utility getValidString:self.notificationId]
                                               };
    
    NSString *deleteNotifcationUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_DeleteNotification];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,deleteNotifcationUrl,deleteNotifcationParameter);
    
    [serviceManager executeServiceWithURL:deleteNotifcationUrl andParameters:deleteNotifcationParameter forTask:kTaskDeleteNotification completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s,%@ api \n response:%@",__FUNCTION__,deleteNotifcationUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"" withTitle:@"Notification Deleted."];
                if ([self.delegate performSelector:@selector(notificationDeletedSuccessfully)]) {
                    [self.delegate notificationDeletedSuccessfully];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else{
                DLog(@"Error:%@",error);
                [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }
    }];
}

@end

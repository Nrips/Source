//
//  NotificationCell.h
//  Autism
//
//  Created by Dipak on 6/10/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"


@protocol NotificationCellDelegate <NSObject>
- (void)notificationDeletedSuccessfully;
- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forNotification:(Notification *)notifcation;

@end

@interface NotificationCell : UITableViewCell

@property (nonatomic,weak) id <NotificationCellDelegate>delegate;

+ (NotificationCell *)cellFromNibNamed:(NSString *)nibName;
- (void)configureCell:(Notification *)notifcation;
@end

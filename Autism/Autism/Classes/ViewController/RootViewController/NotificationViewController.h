//
//  NotificationViewController.h
//  Autism
//
//  Created by Dipak on 6/10/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@protocol NotificationViewControllerDelegate <NSObject>
-(void) notificationCellDidSelectedNotification:(Notification*)notification;

@end

@interface NotificationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) id<NotificationViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end

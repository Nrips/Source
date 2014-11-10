//
//  MessageDetailViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 6/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostViewController.h"

@interface MessageDetailViewController : UIViewController<PostViewControlleDelegate>

@property (nonatomic,strong) NSString *messageIdPass;
@property (nonatomic,strong) NSString *userNamePass;
@property (nonatomic, strong) AppDelegate *appdel;

@property (strong, nonatomic) IBOutlet UITableView *tableMessageDetail;
@property (strong, nonatomic) IBOutlet UIButton* btnSendMessage;
@property(nonatomic,strong) NSString *otherUserId;

@end

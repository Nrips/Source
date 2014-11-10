//
//  InboxCell.h
//  Autism
//
//  Created by Neuron-iPhone on 6/2/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "MessageInInbox.h"

@protocol InboxCellDelegate <NSObject>

@optional
- (void)showReportToAWMViewWithReportID:(NSString*)reportID;
- (void)deleteConversationForRow:(float)row;

@end


@interface InboxCell : UITableViewCell

@property (nonatomic,weak) id<InboxCellDelegate>delegate;

@property (strong, nonatomic) NSString *inboxMemberId;
@property (strong, nonatomic) IBOutlet MyImageView *imag;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessegeDetail;


- (void)configureCell:(MessageInInbox *)member;
+ (InboxCell *)cellFromNibNamed:(NSString *)nibName;

@end

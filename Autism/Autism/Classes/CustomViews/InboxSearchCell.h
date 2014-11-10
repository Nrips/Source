//
//  InboxSearchCell.h
//  Autism
//
//  Created by Neuron Solutions on 7/30/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "MessageSearch.h"
@interface InboxSearchCell : UITableViewCell

+(InboxSearchCell *)cellFromNibNamed:(NSString *)nibName;
- (void)configureCell:(MessageSearch*)member;

@property(nonatomic,strong)IBOutlet MyImageView *memberImage;
@property(nonatomic,strong)IBOutlet UILabel *memberName;
@property(nonatomic,strong)NSString *msgMemberName;
@property(nonatomic,strong)NSString *memberId;

@end

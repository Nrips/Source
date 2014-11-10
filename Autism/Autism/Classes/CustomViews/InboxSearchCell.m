//
//  InboxSearchCell.m
//  Autism
//
//  Created by Neuron Solutions on 7/30/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "InboxSearchCell.h"

@implementation InboxSearchCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (InboxSearchCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    InboxSearchCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[InboxSearchCell class]]) {
            customCell = (InboxSearchCell *)nibItem;
            break; // we have a winner
        }
    }
    
    return customCell;
}


-(void)configureCell:(MessageSearch *)member
{
    self.msgMemberName = member.memberName;
    self.memberId = member.memberId;
}


@end

//
//  CustomEventDetailCell.m
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "CustomEventDetailCell.h"

@implementation CustomEventDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



+ (CustomEventDetailCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    CustomEventDetailCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[CustomEventDetailCell class]]) {
            customCell = (CustomEventDetailCell *)nibItem;
            break; // we have a winner
        }
    }
//    customCell.imageView = [[MyImageView alloc]initWithFrame:CGRectMake(0, 0, 59, 54)];
//    [customCell.imageView setImage:[UIImage imageNamed:@"user-btn.fw.png"]];
//    [customCell addSubview:customCell.imageView];
    return customCell;

}

-(void) configureCell:(EventsDetail *)events
{
    [self.lbleventHeading setText:events.eventHeading];
    [self.lblLocation setText:events.location];
    [self.lblFulldate setText:events.fullDate];
    [self.lblTime setText:events.time];
    [self.lblMonth setText:events.month];
    [self.lblImagDate setText:events.date];
    [self.lblImagDAy setText:events.day];
    self.stringID = events.eventId;
    self.eventIdPass = events.eventId;
    self.eventLocation = events.location;
}

@end

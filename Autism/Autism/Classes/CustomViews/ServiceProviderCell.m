//
//  ServiceProviderCell.m
//  Autism
//
//  Created by Dipak on 5/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ServiceProviderCell.h"
#import "ProviderServices.h"

@implementation ServiceProviderCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (ServiceProviderCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    ServiceProviderCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[ServiceProviderCell class]]) {
            customCell = (ServiceProviderCell *)nibItem;
            break; // we have a winner
        }
    }
    return customCell;
}

- (void)configureCell:(ProviderServices *)providerServices
//-(void)configureCell:(ProviderServices*)review ViewReviewLabelHeight:(float)reviewlabelHeight andCellHeight:(float)cellHeight
{
    
    
//    CGRect cellFrame = self.lblServiceName.frame;
//    cellFrame.size.height = cellHeight;
//    self.frame = cellFrame;
//  
//    CGRect frame = self.lblServiceName.frame;
//    frame.size.height = reviewlabelHeight;
//    self.lblServiceName.frame = frame;
//   
//    CGRect frame1 = self.bgImageView.frame;
//    frame1.size.height = cellHeight;
//    self.bgImageView.frame = frame1;
//
    
    self.lblServiceName.text = providerServices.serviceName;
    self.serviceId = providerServices.serviceID;
}

-(void)configureCell:(ProviderServices *)review ViewReviewLabelHeight:(float)reviewlabelHeight andCellHeight:(float)cellHeight
{
}

@end

//
//  ServiceProviderCell.h
//  Autism
//
//  Created by Dipak on 5/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProviderServices.h"

@protocol ServiceProviderCellDelegate <NSObject>
- (void)tappedOnServiceProviderHeaderForService:(NSString*)serviceId;
@end

@interface ServiceProviderCell : UITableViewCell

+ (ServiceProviderCell *)cellFromNibNamed:(NSString *)nibName;
- (void)configureCell:(ProviderServices *)memberIncircle;
-(void)configureCell:(ProviderServices *)review ViewReviewLabelHeight:(float)reviewlabelHeight andCellHeight:(float)cellHeight;

@property (weak, nonatomic) IBOutlet UILabel *lblServiceName;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;
@property (strong, nonatomic) NSString *serviceId;
@property (nonatomic, weak) id <ServiceProviderCellDelegate>delegate;

@end

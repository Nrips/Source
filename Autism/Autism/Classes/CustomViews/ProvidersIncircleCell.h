//
//  ProvidersIncircleCell.h
//  Autism
//
//  Created by Neuron-iPhone on 5/27/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProviderInCircle.h"

@protocol ProvidersIncircleCellDelegate <NSObject>
- (void)providerAddedSuccessFully;
@end

@interface ProvidersIncircleCell : UITableViewCell

- (void) configureCell:(ProviderInCircle *)providerInCircle;
+ (ProvidersIncircleCell *)cellFromNibNamed:(NSString *)nibName;

@property (nonatomic,weak) id <ProvidersIncircleCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *lblCategory;
@property (strong, nonatomic) IBOutlet UILabel *lblServices;
@property (strong, nonatomic) IBOutlet UILabel *lblProvider;
@property (strong, nonatomic) IBOutlet UIButton *btnPhone;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;

@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *providerId;

@property (strong, nonatomic) IBOutlet UIButton *btnStar1;
@property (strong, nonatomic) IBOutlet UIButton *btnStar2;
@property (strong, nonatomic) IBOutlet UIButton *btnStar3;
@property (strong, nonatomic) IBOutlet UIButton *btnStar4;
@property (strong, nonatomic) IBOutlet UIButton *btnStar5;
- (IBAction)callEvent:(id)sender;

@end

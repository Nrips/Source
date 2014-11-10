//
//  CustomEventDetailCell.h
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventsDetail.h"

@interface CustomEventDetailCell : UITableViewCell

-(void) configureCell:(EventsDetail *)events;
+ (CustomEventDetailCell *)cellFromNibNamed:(NSString *)nibName;

@property (strong, nonatomic) IBOutlet UILabel *lbleventHeading;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;

@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;


@property (strong, nonatomic) IBOutlet UIImageView *imagColorChanger;
@property (strong, nonatomic) IBOutlet UILabel *lblMonth;
@property (strong, nonatomic) IBOutlet UILabel *lblImagDate;
@property (strong, nonatomic) IBOutlet UILabel *lblImagDAy;
@property (strong, nonatomic) IBOutlet UILabel *lblFulldate;
@property (strong, nonatomic) IBOutlet UILabel *lblId;

@property (strong, nonatomic) NSString *stringID;

@property (strong, nonatomic) NSString *eventIdPass;
@property (strong, nonatomic) NSString *eventLocation;


@end

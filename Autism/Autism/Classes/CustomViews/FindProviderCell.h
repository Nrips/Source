//
//  FindProviderCell.h
//  Autism
//
//  Created by Neuron Solutions on 5/13/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "FindProvider.h"

@interface FindProviderCell : UITableViewCell

+(FindProviderCell *)cellFromNibNamed:(NSString *)nibName;
-(void)configureCellAtIndexPath:(NSIndexPath*)indexPath :(FindProvider*)provider;
//-(void)configureCell:(NSIndexPath*)indexPath :(FindProvider *)provider providerLabelHeight:(float)providerlabelHeight andCellHeight:(float)cellHeight;

-(void)configureHeader:(FindProvider *)provider;

@property (nonatomic, strong) MyImageView *imageView;
@property (nonatomic, strong) NSString *providerName;
@property (nonatomic, strong) NSString *providerDescription;
@property (nonatomic, strong) NSString *providerRating;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *providerCategory;
@property (nonatomic, strong) NSString *rating;

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lbldescription;
@property (strong, nonatomic) IBOutlet UILabel *lblCategory;

@property (strong, nonatomic) IBOutlet UIImageView *bgImage;
@property (strong, nonatomic) IBOutlet UIImageView *arrowimage;

@property(nonatomic,strong) NSString *strMessage;
@property (strong,nonatomic)NSString *userId;
@property(nonatomic,strong) NSString *providerId;
@property(nonatomic,strong) NSString *servicId;
@property (nonatomic) BOOL isCheckIncircle;
@property (nonatomic) BOOL isProvider;
@property (nonatomic) BOOL isSelfProvider;

@property (strong, nonatomic) IBOutlet UIButton *btnAddToCircle;
@property (strong, nonatomic) IBOutlet UIButton *btnStar1;
@property (strong, nonatomic) IBOutlet UIButton *btnStar2;
@property (strong, nonatomic) IBOutlet UIButton *btnStar3;
@property (strong, nonatomic) IBOutlet UIButton *btnStar4;
@property (strong, nonatomic) IBOutlet UIButton *btnStar5;


-(IBAction)addToCircleAction:(id)sender;

@end

//
//  ProviderDetailViewController.h
//  Autism
//
//  Created by Neuron Solutions on 5/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProviderDetailViewController : UIViewController
 
@property (strong, nonatomic) IBOutlet UITableView *tblRecentReviews;
@property(nonatomic,strong) NSString *providerId;

@property (strong, nonatomic) IBOutlet UILabel *lblCategory;
@property (strong, nonatomic) IBOutlet UILabel *lblOprateIn;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblPostcode;
@property (strong, nonatomic) IBOutlet UILabel *lblWebsite;
@property (strong, nonatomic) IBOutlet UILabel *lblProvidername;
@property (strong, nonatomic) IBOutlet UILabel *lblProviderCirclePeople;
@property (strong, nonatomic) IBOutlet UITableView *tblService;


@property (strong, nonatomic) IBOutlet UIButton *btnStar1;
@property (strong, nonatomic) IBOutlet UIButton *btnStar2;
@property (strong, nonatomic) IBOutlet UIButton *btnStar3;
@property (strong, nonatomic) IBOutlet UIButton *btnStar4;
@property (strong, nonatomic) IBOutlet UIButton *btnStar5;

@property(nonatomic,strong) NSString *providerRating;
@property(nonatomic,strong) NSString *strProviderRating;


@property (strong, nonatomic) IBOutlet UILabel* lblProviderDetail;
@property (strong, nonatomic) IBOutlet UILabel* lblRecentReview;
@property (strong, nonatomic) IBOutlet UILabel* lblService;
@property (strong, nonatomic) IBOutlet UILabel *lblProviderDetailNotFound ;


@end

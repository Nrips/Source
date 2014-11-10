//
//  ServiceViewController.h
//  Autism
//
//  Created by Neuron Solutions on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ServiceViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lblServiceName;
@property (strong, nonatomic) IBOutlet UILabel *lblRating;
@property (strong, nonatomic) IBOutlet UILabel *lblLocalAuthority;
@property (strong, nonatomic) IBOutlet UILabel *lblCriteria;
@property (strong, nonatomic) IBOutlet UILabel *lblcity;
@property (strong, nonatomic) IBOutlet UILabel *lblPostcode;
@property (strong, nonatomic) IBOutlet UILabel *lblCategories;
@property (strong, nonatomic) IBOutlet UILabel *lblViewDescription;


@property (strong, nonatomic) IBOutlet UIButton *btnStar1;
@property (strong, nonatomic) IBOutlet UIButton *btnStar2;
@property (strong, nonatomic) IBOutlet UIButton *btnStar3;
@property (strong, nonatomic) IBOutlet UIButton *btnStar4;
@property (strong, nonatomic) IBOutlet UIButton *btnStar5;

@property (strong, nonatomic) IBOutlet UIView *ratingView;

@property (strong, nonatomic)NSString *providerRating;
@property (strong, nonatomic)NSString *serviceId;
@property(nonatomic)BOOL isBtnWriteReviewHidden;
@property (strong, nonatomic)NSString *checkReviewed;


@property (strong, nonatomic) IBOutlet UILabel *lblShowServiceName;
@property (strong, nonatomic) IBOutlet UILabel *lblShowPhoneNo;
@property (strong, nonatomic) IBOutlet UILabel *lblShowRating;
@property (strong, nonatomic) IBOutlet UILabel *lblShowCategories;
@property (strong, nonatomic) IBOutlet UILabel *lblShowAuthority;
@property (strong, nonatomic) IBOutlet UILabel *lblShowCriteria;
@property (strong, nonatomic) IBOutlet UILabel *lblShowTown;
@property (strong, nonatomic) IBOutlet UILabel *lblShowEmail;
@property (strong, nonatomic) IBOutlet UILabel *lblShowPostcode;
@property (strong, nonatomic) IBOutlet UILabel *lblShowWebsite;
@property (strong, nonatomic) IBOutlet UILabel *lblShowDescription;


@property (strong, nonatomic) IBOutlet UIImageView *imgServiceName;
@property (strong, nonatomic) IBOutlet UIImageView *imgPhoneNo;
@property (strong, nonatomic) IBOutlet UIImageView *imgAuthority;
@property (strong, nonatomic) IBOutlet UIImageView *imgCategories;
@property (strong, nonatomic) IBOutlet UIImageView *imgPostcode;
@property (strong, nonatomic) IBOutlet UIImageView *imgCriteria;
@property (strong, nonatomic) IBOutlet UIImageView *imgEmail;
@property (strong, nonatomic) IBOutlet UIImageView *imgWebsite;
@property (strong, nonatomic) IBOutlet UIImageView *imgRating;
@property (strong, nonatomic) IBOutlet UIImageView *imgDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imgTown;

@property (strong, nonatomic) IBOutlet UIImageView *imgBaseField;


- (IBAction)viewReviewAction:(id)sender;

// TODO-: Added By Utkarsh Singh -->
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblServiceNameHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblLocalAuthorityHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblEligibilityCriteriaHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescriptionHeightConstraint;


@end

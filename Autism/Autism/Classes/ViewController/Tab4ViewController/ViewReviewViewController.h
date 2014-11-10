//
//  ViewReviewViewController.h
//  Autism
//
//  Created by Neuron Solutions on 5/29/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewReviewViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UITextView *txtviewService;

@property(nonatomic, strong)NSString *profileType;
@property (strong, nonatomic)NSString *serviceId;
@property (strong, nonatomic)NSString *serviceName;

@property (strong, nonatomic) IBOutlet UITableView *tblViewReview;


@end

//
//  FindProvidersViewController.h
//  Autism
//
//  Created by Neuron Solutions on 5/19/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCircleProviderViewController : UIViewController<UITableViewDataSource,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableProvider;
@property(nonatomic,strong) NSString *profileType;
@property(nonatomic,strong) NSString *otherMemberId;

@end

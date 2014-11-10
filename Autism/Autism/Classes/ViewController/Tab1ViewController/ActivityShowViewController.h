//
//  ActivityShowViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ActivityShowViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tablePostActivity;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *activityID;



@end

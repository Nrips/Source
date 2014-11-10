//
//  EventDetailShowViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailShowViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

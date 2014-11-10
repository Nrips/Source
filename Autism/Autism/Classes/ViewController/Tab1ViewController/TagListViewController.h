//
//  SettinhViewController.h
//  ShowLabelAnimation
//
//  Created by Dipak on 5/16/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.

#import <UIKit/UIKit.h>

@interface TagListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray *tagsArray;

@end

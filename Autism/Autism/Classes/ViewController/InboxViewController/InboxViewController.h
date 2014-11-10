//
//  InboxViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 6/2/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxViewController : UIViewController

@property IBOutlet UISearchBar *messageSearchBar;
@property(strong,nonatomic) NSMutableArray *filteredMessageArray;

@end

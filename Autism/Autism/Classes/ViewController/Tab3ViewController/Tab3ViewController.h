
//  Tab3ViewController.h
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomTextField.h"

@interface Tab3ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic)IBOutlet UITextField *txtSearch;

@end
   
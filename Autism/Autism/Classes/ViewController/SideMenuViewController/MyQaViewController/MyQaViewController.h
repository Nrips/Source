//
//  MyQaViewController.h
//  Autism
//
//  Created by Vikrant Jain on 2/15/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyQaViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UITextViewDelegate>

@property(strong,nonatomic)IBOutlet UITableView *tblsearch;
@property(nonatomic,strong) NSString *otherMemberId;
@property(nonatomic,strong) NSString *profileType;
@property (nonatomic, strong) NSString *parentViewControllerName;

@end

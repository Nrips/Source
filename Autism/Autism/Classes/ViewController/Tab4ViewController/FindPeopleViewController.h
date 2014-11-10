//
//  FindPeopleViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/24/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FindPeopleViewControllerDelegate <NSObject>

-(void)setLocalAuthorityValue:(NSString *)localAuthority;

@end

@interface FindPeopleViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

-(void)searchAction;

@property (nonatomic, weak) id<FindPeopleViewControllerDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIImageView *imag;
@property (strong, nonatomic) NSMutableArray *arrData;
@property (strong, nonatomic) NSMutableArray *arrName;
@property (strong, nonatomic) NSMutableArray *arrcity;
@property (strong, nonatomic) NSMutableArray *arrProfilepic;
@property (strong, nonatomic) NSMutableArray *arrRole;
@property (strong, nonatomic) IBOutlet UITableView *tableShowPeople;
@end

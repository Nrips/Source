//
//  CustomPeopleView.h
//  Autism
//
//  Created by Neuron-iPhone on 2/20/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonInFinder.h"
#import "MyImageView.h"

@interface CustomPeopleView : UITableViewCell

-(void)configureCell:(PersonInFinder *)person;
+ (CustomPeopleView *)cellFromNibNamed:(NSString *)nibName;


@property (strong, nonatomic) IBOutlet UILabel *personName;
@property (strong, nonatomic) IBOutlet UILabel *personCity;
@property (strong, nonatomic) IBOutlet UILabel *personRole;
@property (strong, nonatomic) IBOutlet UILabel *personLocalAuthority;

@property (strong, nonatomic) IBOutlet UIImageView *sayHiImage;
@property (strong, nonatomic)IBOutlet MyImageView *myimag;
@property (strong, nonatomic) IBOutlet UIButton *circleBtn;

@property (strong,nonatomic) NSString *userId;
@property (strong,nonatomic) NSString *imageURL;
@property (strong,nonatomic) NSString *userName;
@property(strong,nonatomic)  NSString *locationAuthority;
@property (strong,nonatomic) NSString *userCity;
@property(nonatomic,strong)  NSString *strMessage;
@property (nonatomic) BOOL isCheckIncircle;
@property (nonatomic) BOOL isMemeberBlocked;
@property (strong, nonatomic) IBOutlet UIButton *btnAddToCircle;


- (IBAction)addToCircleAction:(id)sender;


@end

//
//  CustomMyPeopleCell.h
//  Autism
//
//  Created by Neuron-iPhone on 3/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberInCircle.h"
#import "MyImageView.h"

@interface CustomMyPeopleCell : UITableViewCell

-(void) configureCell:(MemberInCircle *) memberIncircle;
+ (CustomMyPeopleCell *)cellFromNibNamed:(NSString *)nibName;

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblCity;
@property (strong, nonatomic) IBOutlet UILabel *lblRole;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblSeprater;

@property (strong, nonatomic)IBOutlet MyImageView *myimag;
@property(strong,nonatomic)  NSString *strUserKey;
@property (strong,nonatomic) NSString *imageURL;
@property (strong,nonatomic) NSString *userName;
@property(strong,nonatomic)  NSString *locationAuthority;
@property(strong,nonatomic)  NSString *userCity;
@property(strong,nonatomic)  NSString *userId;

@property(strong,nonatomic)  NSString *strLocation;
@property(strong,nonatomic)  NSString *strAuthority;
@property(strong,nonatomic)  UIFont *systemFont;


@end

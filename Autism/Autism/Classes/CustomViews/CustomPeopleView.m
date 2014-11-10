//
//  CustomPeopleView.m
//  Autism
//
//  Created by Neuron-iPhone on 2/20/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "CustomPeopleView.h"
#import "MyImageView.h"
#import "Utility.h"


@interface CustomPeopleView()

@property (nonatomic, strong) MyImageView *imageView;
@end

@implementation CustomPeopleView
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
    // Configure the view for the selected state
}

+ (CustomPeopleView *)cellFromNibNamed:(NSString *)nibName {
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    CustomPeopleView *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[CustomPeopleView class]]) {
            customCell = (CustomPeopleView *)nibItem;
            break; // we have a winner
        }
    }
    customCell.imageView = [[MyImageView alloc]initWithFrame:CGRectMake(4, 7, 60, 60)];
    [customCell.imageView setImage:[UIImage imageNamed:@"avatar-140.png"]];
    [customCell addSubview:customCell.imageView];
    return customCell;
}

-(void) configureCell:(PersonInFinder *)person {
    
    [self.imageView configureImageForUrl:person.imageUrl];
    [self.personName setText:person.personName];
    [self.personCity setText:person.city];
    [self.personRole setText:person.role];
    [self.personLocalAuthority setText:person.localAuthority];
    
    self.isCheckIncircle = person.isInCircle;
    self.userId = [person UserID];
    self.imageURL = person.imageUrl;
    self.userName = person.personName;
    self.userCity = person.city;
    self.locationAuthority = person.localAuthority;
    self.isMemeberBlocked = person.isMemeberBlocked;
    
    if (self.isCheckIncircle) {
        
        [self.btnAddToCircle setTitle:kTitleInCircle forState:UIControlStateNormal];
    }
    else{
        [self.btnAddToCircle setTitle:kTitleAddToCircle forState:UIControlStateNormal];
    }
}



- (IBAction)addToCircleAction:(id)sender {
    [self addToCircleApiCall];
}

-(void)addToCircleApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.userId) {
        DLog(@"Person id whom you want to add does not exist");
        return;
    }
    NSDictionary *addToCircleParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                            @"add_member_id" : self.userId,
                                            };
    NSString *addToCircleUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_AddMemberInTeam];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,addToCircleUrl, addToCircleParameters);
    [serviceManager executeServiceWithURL:addToCircleUrl andParameters:addToCircleParameters forTask:kTaskAddMemberInTeam completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,addToCircleUrl, response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if([[dict objectForKey:@"is_memmber_added_incircle"] boolValue]){
                    [Utility showAlertMessage:@"" withTitle:@"Member added successfully to your circle."];
                    [self.btnAddToCircle setTitle:kTitleInCircle forState:UIControlStateNormal];
                } else {
                    [self.btnAddToCircle setTitle:kTitleAddToCircle forState:UIControlStateNormal];
                    [Utility showAlertMessage:@"" withTitle:@"Member successfully removed from your circle."];
                }
            } else if ([[dict valueForKey:@"is_blocked"] boolValue]){
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else {
                [Utility showAlertMessage:@"Member could not be added in your cirlce. Please try again." withTitle:@""];
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

@end

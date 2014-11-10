//
//  FindProviderCell.m
//  Autism
//
//  Created by Neuron Solutions on 5/13/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "FindProviderCell.h"
#import "MyImageView.h"
#import "Utility.h"
#import "ProviderDetailViewController.h"
#import "ServiceViewController.h"

@implementation FindProviderCell
@synthesize imageView;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(FindProviderCell*)cellFromNibNamed:(NSString *)nibName
{
 
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    FindProviderCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[FindProviderCell class]]) {
            customCell = (FindProviderCell*)nibItem;
            break; // we have a winner
        }
    }
    
    return customCell;
}



-(void)configureCellAtIndexPath:(NSIndexPath*)indexPath :(FindProvider*)provider;

{
    //service_category
    
    if (provider.providerServices.count >= indexPath.row) {
        NSArray *service = [provider.providerServices objectAtIndex:indexPath.row];
        [self.lbldescription setText:[service valueForKey:@"service_category"]];
        [self.lblName setText:[service valueForKey:@"service_category"]];
        [self.lblCategory setText:[service valueForKey:@"service_name"]];
        self.servicId = [service valueForKey:@"service_id"];
        self.rating = [service valueForKey:@"service_rating"];
        [self showStarRating];
    }

    self.userId = provider.userId;
    self.btnAddToCircle.hidden = YES;
    self.isSelfProvider = provider.isSelfProvider;
    self.isCheckIncircle = provider.checkInCircle;
    self.providerId = provider.providerId;
    self.isProvider = NO;
    [self setAddToCircleButtonTitle];
}

-(void)configureHeader:(FindProvider *)provider
{
    [self.lbldescription setText:provider.providerDescription];
    [self.lblName setText:provider.providerName];
    [self.lblCategory setText:provider.providerCategory];
    self.userId = provider.userId;
    self.isCheckIncircle = provider.checkInCircle;
    self.providerId = provider.providerId;
    self.isProvider = YES;
    self.rating = provider.providerRating;
    [self showStarRating];

    self.btnAddToCircle.hidden = self.isSelfProvider;
    self.isSelfProvider = provider.isSelfProvider;
    [self setAddToCircleButtonTitle];
}

- (void)setAddToCircleButtonTitle
{
    if (self.isCheckIncircle) {
        [self.btnAddToCircle setTitle:kTitleInCircle forState:UIControlStateNormal];
        [self.btnAddToCircle setBackgroundImage:[UIImage imageNamed:@"qa-search-btn.png"] forState:UIControlStateNormal];
    }
    else{
        [self.btnAddToCircle setTitle:kTitleAddToCircle forState:UIControlStateNormal];
        [self.btnAddToCircle setBackgroundImage:[UIImage imageNamed:@"qa-askquestion-btn.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)containerButtonPressed:(id)sender {
    DLog(@"%s",__FUNCTION__);
    
    if (self.isProvider) {
        
        
        ProviderDetailViewController *providerVC = [[ProviderDetailViewController alloc] initWithNibName:@"ProviderDetailViewController" bundle:nil];
        providerVC.providerId = self.providerId;
        DLog(@"Provider id%@", providerVC.providerId);
        [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
        [[appDelegate rootNavigationController] pushViewController:providerVC animated:YES];
    }
    
    else{
        
        ServiceViewController *providerVC = [[ServiceViewController alloc] initWithNibName:@"ServiceViewController" bundle:nil];
        
        providerVC.serviceId = self.servicId;
        
        DLog(@"service id %@",providerVC.serviceId);
        
        [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
        [[appDelegate rootNavigationController] pushViewController:providerVC animated:YES];
    }
}

- (IBAction)addToCircleAction:(id)sender {
    
   if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.providerId) {
        DLog(@"provider Id does not exist");
        return;
    }
    
    NSDictionary *addProviderInTeamParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                 @"provider_id" : self.providerId,
                                           };
    
    NSString *addProviderUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_AddProviderInTeam];
    DLog(@"%s, Performing %@ api with parameter:%@",__FUNCTION__, addProviderUrl,addProviderInTeamParameters);
    
    [serviceManager executeServiceWithURL:addProviderUrl andParameters:addProviderInTeamParameters forTask:kTaskAddProviderInTeam completionHandler:^(id response, NSError *error, TaskType task) {
        
        NSLog(@"%s, Performing %@ api Response:%@",__FUNCTION__, addProviderUrl,response);
        
        if (!error && response){
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if([[dict objectForKey:@"is_provider_added_incircle"] boolValue]){
                    [self.btnAddToCircle setTitle:kTitleInCircle forState:UIControlStateNormal];
                    [self.btnAddToCircle setBackgroundImage:[UIImage imageNamed:@"qa-search-btn.png"] forState:UIControlStateNormal];

                    [Utility showAlertMessage:@"" withTitle:@"Provider added to your circle."];
                } else {
                    [self.btnAddToCircle setTitle:kTitleAddToCircle forState:UIControlStateNormal];
                    [self.btnAddToCircle setBackgroundImage:[UIImage imageNamed:@"qa-askquestion-btn.png"] forState:UIControlStateNormal];
                    [Utility showAlertMessage:@"" withTitle:@"Provider removed from your circle successfully."];
                }
            }
            else if ([[dict valueForKey:@"is_blocked"] boolValue]){
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
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

- (void)showStarRating
{
    BOOL showHalfRating = NO;
    int rating = [self.rating floatValue];
    float floatRating = [self.rating floatValue];

    if (ceilf(floatRating) > floorf(floatRating)) {
        showHalfRating = YES;
    }
    for(int i = 1; i <=5; i++) {
        UIButton *button = (UIButton*)[self.contentView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-normal.png"] forState:UIControlStateNormal];
    }
   
    for(int i = 1; i <=rating ; i++) {
        UIButton *button = (UIButton*)[self.contentView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-active.png"] forState:UIControlStateNormal];
    }
    if (showHalfRating) {
        UIButton *button = (UIButton*)[self.contentView viewWithTag: rating+1];
        [button setBackgroundImage:[UIImage imageNamed:@"star-half-selected.png"] forState:UIControlStateNormal];
    }
}

@end

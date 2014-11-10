//
//  ProvidersIncircleCell.m
//  Autism
//
//  Created by Neuron-iPhone on 5/27/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ProvidersIncircleCell.h"
#import "Utility.h"

@interface ProvidersIncircleCell()
{
     UIWebView *mCallWebview;
}
@property (weak, nonatomic) IBOutlet UIButton *addToCircleButton;
//@property (strong, nonatomic) NSString *providerId;
@property (nonatomic) BOOL isProviderInCircle;

- (IBAction)addToCircleButtonPressed:(id)sender;

@end


@implementation ProvidersIncircleCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (ProvidersIncircleCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    ProvidersIncircleCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[ProvidersIncircleCell class]]) {
            customCell = (ProvidersIncircleCell *)nibItem;
            break;
        }
    }
    return customCell;
}

- (void) configureCell:(ProviderInCircle *)providerInCircle
{
   
    [self.lblServices setText:providerInCircle.services];
    [self.lblServices sizeToFit];
    [self.lblProvider setText:providerInCircle.name];
    [self.lblProvider sizeToFit];
    [self.lblCategory setText:providerInCircle.categoryName];
    [self.lblAddress setText:providerInCircle.address];
    [self.btnPhone setTitle:providerInCircle.phoneNumber forState:UIControlStateNormal];
    self.rating  = providerInCircle.rating;
    self.providerId = providerInCircle.providerId;
    self.isProviderInCircle = providerInCircle.isProviderInCircle;
    
    [self.addToCircleButton setTitle:(self.isProviderInCircle ? kTitleInCircle : kTitleAddToCircle) forState:UIControlStateNormal];

    [self showStarRating];
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

- (IBAction)addToCircleButtonPressed:(id)sender {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.providerId) {
        DLog(@"provider Id does not exist");
        return;
    }
    
    NSDictionary *addProviderInTeamParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]
                                                 ,@"provider_id" : self.providerId,
                                                 };
    
    NSString *addProviderUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_AddProviderInTeam];
    DLog(@"%s, Performing %@ api with parameter:%@",__FUNCTION__, addProviderUrl,addProviderInTeamParameters);
    
    [serviceManager executeServiceWithURL:addProviderUrl andParameters:addProviderInTeamParameters forTask:kTaskAddProviderInTeam completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, Performing %@ api Response:%@",__FUNCTION__, addProviderUrl,response);
        if (!error && response){
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if([[dict objectForKey:@"is_provider_added_incircle"] boolValue]){
                    //[self.addToCircleButton setTitle:kTitleInCircle forState:UIControlStateNormal];
                    [Utility showAlertMessage:@"" withTitle:@"Provider added to your circle."];
                } else {
                    //[self.addToCircleButton setTitle:kTitleAddToCircle forState:UIControlStateNormal];
                    [Utility showAlertMessage:@"" withTitle:@"Provider removed from your circle successfully."];
                }
                if ([self.delegate respondsToSelector:@selector(providerAddedSuccessFully)]) {
                    [self.delegate providerAddedSuccessFully];
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
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}
- (IBAction)callEvent:(id)sender {
   
    NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",self.btnPhone.titleLabel.text];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
    if (!mCallWebview)
        mCallWebview = [[UIWebView alloc] init];
    
    [mCallWebview loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
   }
@end

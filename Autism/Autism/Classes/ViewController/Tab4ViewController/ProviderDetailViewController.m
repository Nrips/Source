//
//  ProviderDetailViewController.m
//  Autism
//
//  Created by Neuron Solutions on 5/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ProviderDetailViewController.h"
#import "Utility.h"
#import "FindProviderCell.h"
#import "RecentReviewViewCell.h"
#import "ProviderServices.h"
#import "ServiceProviderCell.h"
#import "ServiceViewController.h"
#import "ProviderDetail.h"

#define ServiceTableCellHieght 52
#define ReviewTableCellHieght 95


@interface ProviderDetailViewController ()<UITextFieldDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>
{
    UIWebView *mCallWebview;
    
    float reviewLabelHeight;
    float rowHeight;
    float providerDetailLabelHeight;

}

@property(nonatomic,strong) NSArray *providerData;
@property(nonatomic,strong) NSArray *providerdetailArray;
@property(nonatomic,strong) NSArray *serviceArray;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *noRatingFoundLabel;

@property (strong, nonatomic) IBOutlet UIButton *btnEmail;
@property (weak, nonatomic) IBOutlet UILabel *providerServiceLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoneNum;
@property (strong ,nonatomic) UIFont* reviewFont;
- (IBAction)callEvent:(id)sender;
- (IBAction)emailSendEvent:(id)sender;

@end

@implementation ProviderDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Provider";
    [self resetViews];
    [self getProviderDetail];
    //self.scrollView.frame = CGRectMake(0, 0, 320, 560);
    //[self.scrollView setContentSize:CGSizeMake(320,800)];
    self.noRatingFoundLabel.hidden = YES;
    
    self.reviewFont = [UIFont systemFontOfSize:13];
    
       
   }

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)calculateLabelHight
{
    providerDetailLabelHeight =[self calculateProviderDetailStringHeight:self.lblProviderDetail.text];
   
    CGRect labelFrame = self.lblProviderDetail.frame;
    labelFrame.size.height = providerDetailLabelHeight;
    self.lblProviderDetail.frame = labelFrame;
    
    CGRect recentLabelFrame = self.lblRecentReview.frame;
    recentLabelFrame.origin.y = self.lblProviderDetail.frame.origin.y + providerDetailLabelHeight;
    recentLabelFrame.size.height = PROVIDER_DETAIL_LABEL_HIGHT;
    self.lblRecentReview.frame = recentLabelFrame;
    
    
    CGRect tableFrame = self.tblRecentReviews.frame;
    tableFrame.origin.y = self.lblRecentReview.frame.origin.y + PROVIDER_DETAIL_LABEL_HIGHT;
    self.tblRecentReviews.frame = tableFrame;
    
}

-(void)resetViews{
    
    //Set Recent Reviews Table View
    long recentReviewsTableHeight =  self.providerdetailArray.count * ReviewTableCellHieght;
    
    CGRect tblRecentReviewsFrame = self.tblRecentReviews.frame;
    tblRecentReviewsFrame.size.height = recentReviewsTableHeight;
    self.tblRecentReviews.frame = tblRecentReviewsFrame;
    int noRatingFoundLabelHeight = 0;
    if (self.providerdetailArray.count == 0)
    {
        CGRect noRatingLabelFrame = self.noRatingFoundLabel.frame;
        noRatingLabelFrame.origin.y = self.tblRecentReviews.frame.origin.y;
        self.noRatingFoundLabel.frame = noRatingLabelFrame;
        noRatingFoundLabelHeight = self.noRatingFoundLabel.frame.size.height;
    }
    self.noRatingFoundLabel.hidden = self.providerdetailArray.count;

    int providerServiceLblYAxis = self.tblRecentReviews.frame.origin.y + self.tblRecentReviews.frame.size.height + noRatingFoundLabelHeight;
   
    
    //Set Provider Service Label
    CGRect providerServiceLabelFrame = self.providerServiceLabel.frame;
    providerServiceLabelFrame.origin.y = providerServiceLblYAxis;
    self.providerServiceLabel.frame = providerServiceLabelFrame;
    
    //Set Provider Service Table height
    int providerServiceTableYAxis = providerServiceLabelFrame.origin.y + providerServiceLabelFrame.size.height;
    
    CGRect providerServiceTblFrame = self.tblService.frame;
    providerServiceTblFrame.origin.y = providerServiceTableYAxis + 7;
    long serviceTableHeight =  self.serviceArray.count * ServiceTableCellHieght;
    providerServiceTblFrame.size.height = serviceTableHeight;
    self.tblService.frame = providerServiceTblFrame;
   
    //Set Scroll view frame
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.size.height = self.tblService.frame.origin.y + self.tblService.frame.size.height;
    //self.scrollView.frame = scrollViewFrame;
    [self.scrollView setContentSize:CGSizeMake(320, scrollViewFrame.size.height + 60)];
}

-(void)getProviderDetail
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.providerId)
    {
        DLog(@"ProviderDetail api call not perform because providerId is not exist");
        return;
    }
    
        NSDictionary *findProviderDetailParameter =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                      @"provider_id":self.providerId,
                                                    };
        
        NSString *findProviderUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ServiceProviderDetail];
        
       // DLog(@"%s Performing %@ Api  \n with Parameter:%@",__FUNCTION__,findProviderUrl,findProviderDetailParameter);
        [serviceManager executeServiceWithURL:findProviderUrl andParameters:findProviderDetailParameter forTask:kTaskFindProviderDetail completionHandler:^(id response, NSError *error, TaskType task) {
       
           // DLog(@"%s Performing %@ Api  \n response:%@",__FUNCTION__,findProviderUrl, response);
            
            if (!error && response) {
                NSDictionary *dict = [[NSDictionary alloc]init];
                dict = (NSDictionary *)response;
                if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
        
                    dispatch_async(dispatch_get_main_queue(), ^{
                    self.providerdetailArray = [parsingManager parseResponse:response forTask:task];
                       [self.tblRecentReviews reloadData];
                        self.serviceArray = [parsingManager parseResponse:response forTask:kTaskParseProviderServices];
                        [self.tblService reloadData];
                        self.providerData = [dict objectForKey:@"data"];
                        [self getDetail:self.providerData];
                        [self resetViews];
                    });
                }
                if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                    
                    self.lblProviderDetailNotFound.hidden = NO;
                }
                else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                    [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
            }
            else{
                  DLog(@"%s Error:%@",__FUNCTION__,error);
                  [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            }
        }];
}

-(void) getDetail :(NSArray *) providerDetailData
{
    self.lblCategory.text = [[providerDetailData valueForKey:@"provider_category"] componentsJoinedByString:@""];
    self.lblOprateIn.text = [[providerDetailData valueForKey:@"operates_in"] componentsJoinedByString:@""];;
    self.lblAddress.text = [[providerDetailData valueForKey:@"provider_street_address"] componentsJoinedByString:@""];
    NSString *phoneString = [[providerDetailData valueForKey:@"provider_phone"] componentsJoinedByString:@""];
    [self.btnPhoneNum setTitle:phoneString forState:UIControlStateNormal];
    self.lblPostcode.text = [[providerDetailData valueForKey:@"provider_postcode"] componentsJoinedByString:@""];
    self.lblWebsite.text = [[providerDetailData valueForKey:@"provider_url"] componentsJoinedByString:@""];
    NSString *email = [[providerDetailData valueForKey:@"provider_email"]componentsJoinedByString:@""];
    [self.btnEmail setTitle:email forState:UIControlStateNormal];
    DLog(@"%@",self.btnEmail.titleLabel.text);
    self.lblProvidername.text = [[providerDetailData valueForKey:@"provider_name"]componentsJoinedByString:@""];
    self.lblProviderCirclePeople.text = [[providerDetailData valueForKey:@"provider_count_in_cirlce"]componentsJoinedByString:@""];
    [self.lblProviderCirclePeople sizeToFit];
    self.lblProviderDetail.text = [[providerDetailData valueForKey:@"provider_description"] componentsJoinedByString:@""];
    
    self.providerRating = [[providerDetailData valueForKey:@"provider_rating"]componentsJoinedByString:@""];
    
    [self showStarRating];
    
    [self calculateLabelHight];
}


- (void)showStarRating
{
    BOOL showHalfRating = NO;
    int rating = [self.providerRating floatValue];
    float floatRating = [self.providerRating floatValue];
    
    if (ceilf(floatRating) > floorf(floatRating)) {
        showHalfRating = YES;
    }
    for(int i = 1; i <=5; i++) {
        UIButton *button = (UIButton*)[self.scrollView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-normal.png"] forState:UIControlStateNormal];
    }
    
    for(int i = 1; i <=rating ; i++) {
        UIButton *button = (UIButton*)[self.scrollView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-active.png"] forState:UIControlStateNormal];
    }
    if (showHalfRating) {
        UIButton *button = (UIButton*)[self.scrollView viewWithTag: rating+1];
        [button setBackgroundImage:[UIImage imageNamed:@"star-half-selected.png"] forState:UIControlStateNormal];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
   
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tblRecentReviews]) {
        return [self.providerdetailArray count];
    }
    else{
        return self.serviceArray.count;
        //return 0;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([tableView isEqual:self.tblRecentReviews]) {
        static NSString * cellId =@"cell";
        RecentReviewViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [RecentReviewViewCell cellFromNibNamed:@"RecentReviewViewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
         float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
        [cell configureCell:[self.providerdetailArray objectAtIndex:indexPath.row] ViewReviewLabelHeight:reviewLabelHeight andCellHeight:cellHeight];
        return cell;
    }
    else{
        static NSString * cellId =@"serviceCell";
        ServiceProviderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) {
            cell = [ServiceProviderCell cellFromNibNamed:@"ServiceProviderCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configureCell:[self.serviceArray objectAtIndex:indexPath.row]];
        return cell;
    }
    
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tblRecentReviews]) {
        return [self calculateRowHeightAtIndexPath:indexPath];
    }{
        return ServiceTableCellHieght;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tblRecentReviews])
    {
       // ProviderServices *providerServices = (ProviderServices*)([self.serviceArray objectAtIndex:indexPath.row]);
       // DLog(@"ServiceID:%@",providerServices.serviceID);
    }
    else{
         ProviderServices *providerServices = (ProviderServices*)([self.serviceArray objectAtIndex:indexPath.row]);
        
        ServiceViewController *providerVC = [[ServiceViewController alloc] initWithNibName:@"ServiceViewController" bundle:nil];
        
        providerVC.serviceId = providerServices.serviceID;
        
        [self.navigationController pushViewController:providerVC animated:YES];
    }
   }




-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    ProviderDetail *review  = [self.providerdetailArray objectAtIndex:[indexPath row]];
    reviewLabelHeight = [self calculateMessageStringHeight:review.reviewDetail];
    rowHeight =  reviewLabelHeight + RATING_LABEL_YAXIS + BUTTON_VIEW_HEIGHT;
    rowHeight += CELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(262, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.reviewFont} context:nil];
    return textRect.size.height;
    
}

-(float)calculateProviderDetailStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(262, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.reviewFont} context:nil];
    return textRect.size.height;
    
}





- (IBAction)callEvent:(id)sender {
    NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",self.btnPhoneNum.titleLabel.text];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
    if (!mCallWebview)
        mCallWebview = [[UIWebView alloc] init];
    
    [mCallWebview loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

- (IBAction)emailSendEvent:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Mail Alert" message:@"Email cannot be configured. Go to iPhone settings and configure your mail account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }else {
        
        NSArray *toRecipents = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@",self.btnEmail.titleLabel.text]];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:toRecipents];
        //[picker setSubject:subject];
        //[picker setMessageBody:body isHTML:YES];
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            DLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            DLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            DLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

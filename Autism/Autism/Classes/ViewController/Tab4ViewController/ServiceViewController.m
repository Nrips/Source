//
//  ServiceViewController.m
//  Autism
//
//  Created by Neuron Solutions on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ServiceViewController.h"
#import "Utility.h"
#import "ViewReviewViewController.h"
#import "WriteReviewView.h"
#import "ReportToAWMView.h"

@interface ServiceViewController ()<WriteReviewViewDelegate,MFMailComposeViewControllerDelegate,ReportToAWMViewDelegate>
{
    UIWebView *mCallWebview;
    
    float serviceNameLabelHeight;
    float phonenNoLabelHeight;
    float ratingLabelHeight;
    float categoriesLabelHeight;
    float authorityLabelHeight;
    float criteriaLabelHeight;
    float townLabelHeight;
    float emailLabelHeight;
    float postcodeLabelHeight;
    float websiteLabelHeight;
    float descriptionLabelHeight;
}

@property (strong, nonatomic) IBOutlet UIButton *btnEmailOpen;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoneNum;
@property (strong, nonatomic) IBOutlet UIButton *btnReportToAWM;

@property(strong,nonatomic)NSString *phoneString;
@property(strong,nonatomic)NSString *emailText;

@property(nonatomic,strong)NSArray* providerData;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (nonatomic) BOOL isAlreadyReviewed;
@property (nonatomic) BOOL isAlreadyReported;
@property (weak, nonatomic) IBOutlet UIButton *viewReviewButton;
@property (strong, nonatomic) IBOutlet UIButton *btnWebAddress;
@property (nonatomic, strong) ReportToAWMView *reportToAWMView;
@property (strong, nonatomic) UIView* view;
@property(strong,nonatomic)UIFont*serviceFont;

- (IBAction)openWebUrl:(id)sender;
- (IBAction)phoneAction:(id)sender;
- (IBAction)emailOpenEvent:(id)sender;

@end

@implementation ServiceViewController

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
    self.serviceFont = [UIFont systemFontOfSize:13];
    [self getServiceDetail];
    self.title = @"Service";
     self.scrollView.frame = CGRectMake(0, 0, 320, 560);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidLayoutSubviews
{
}

-(void)resizeView
{
    serviceNameLabelHeight = [self calculateServiceDetailStringHeight:self.lblServiceName.text];
    //phonenNoLabelHeight = [self calculateServiceDetailStringHeight:self.phoneString];
    //ratingLabelHeight = [self calculateServiceDetailStringHeight:self.phoneString];
    categoriesLabelHeight = [self calculateServiceDetailStringHeight:self.lblCategories.text];
    authorityLabelHeight  = [self calculateServiceDetailStringHeight:self.lblLocalAuthority.text];
    criteriaLabelHeight  = [self calculateServiceDetailStringHeight:self.lblCriteria.text];
    townLabelHeight      = [self calculateServiceDetailStringHeight:self.lblcity.text];
    postcodeLabelHeight  = [self calculateServiceDetailStringHeight:self.lblPostcode.text];
    descriptionLabelHeight = [self calculateServiceDetailStringHeight:self.lblViewDescription.text];
    
    CGRect ImageFrame = self.imgBaseField.frame;
    ImageFrame.size.height = serviceNameLabelHeight + categoriesLabelHeight + authorityLabelHeight + criteriaLabelHeight +townLabelHeight + postcodeLabelHeight + descriptionLabelHeight +EMAIL_LABEL_HEIGHT + RATING_VIEW_HEIGHT
    +WEBSITE_LABEL_HEIGHT + SERVICE_BASEIMAGE_HEIGHT;
    self.imgBaseField.frame = ImageFrame;

    
    
    
    CGRect frame = self.lblShowServiceName.frame;
    frame.origin.y = SERVICE_DETAIL_LABEL_STARTING_Y_POSITION-2;
    self.lblShowServiceName.frame = frame;
    
    CGRect serviceFrame  = self.lblServiceName.frame;
    serviceFrame.origin.y = SERVICE_DETAIL_LABEL_STARTING_Y_POSITION;
    serviceFrame.size.height = serviceNameLabelHeight;
    self.lblServiceName.frame = serviceFrame;
    
    CGRect imgServiceFrame  = self.imgServiceName.frame;
    imgServiceFrame.origin.y = self.lblServiceName.frame.origin.y + serviceNameLabelHeight + SERVICE_DETAIL_LABEL_MARGIN + 4;
    self.imgServiceName.frame = imgServiceFrame;
    
    
    CGRect showPhoneframe = self.lblShowPhoneNo.frame;
    showPhoneframe.origin.y = self.imgServiceName.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowPhoneNo.frame = showPhoneframe;
    
    CGRect phoneFrame  = self.btnPhoneNum.frame;
    phoneFrame.origin.y = self.imgServiceName.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    phoneFrame.size.height = PHONE_LABEL_HEIGHT;
    self.btnPhoneNum.frame = phoneFrame;
    
    
    CGRect imgPhoneFrame  = self.imgPhoneNo.frame;
    imgPhoneFrame.origin.y = self.btnPhoneNum.frame.origin.y + PHONE_LABEL_HEIGHT + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgPhoneNo.frame = imgPhoneFrame;

   
    
    CGRect showRatingframe = self.lblShowRating.frame;
    showRatingframe.origin.y = self.imgPhoneNo.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN - 6;
    self.lblShowRating.frame = showRatingframe;
    
    CGRect ratingFrame  = self.btnStar1.frame;
    ratingFrame.origin.y = self.imgPhoneNo.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    ratingFrame.size.height = RATING_VIEW_HEIGHT;
    self.btnStar1.frame = ratingFrame;
    
    CGRect ratingFrame1  = self.btnStar2.frame;
    ratingFrame1.origin.y = self.imgPhoneNo.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    ratingFrame1.size.height = RATING_VIEW_HEIGHT;
    self.btnStar2.frame = ratingFrame1;
    
    CGRect ratingFrame3  = self.btnStar3.frame;
    ratingFrame3.origin.y = self.imgPhoneNo.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    ratingFrame3.size.height = RATING_VIEW_HEIGHT;
    self.btnStar3.frame = ratingFrame3;
    
    CGRect ratingFrame4  = self.btnStar4.frame;
    ratingFrame4.origin.y = self.imgPhoneNo.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    ratingFrame4.size.height = RATING_VIEW_HEIGHT;
    self.btnStar4.frame = ratingFrame4;
    
    CGRect ratingFrame5  = self.btnStar5.frame;
    ratingFrame5.origin.y = self.imgPhoneNo.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    ratingFrame5.size.height = RATING_VIEW_HEIGHT;
    self.btnStar5.frame = ratingFrame5;
    
   
    
    CGRect imgRatingFrame   =  self.imgRating.frame;
    imgRatingFrame.origin.y = self.lblShowRating.frame.origin.y + RATING_VIEW_HEIGHT + SERVICE_DETAIL_LABEL_MARGIN + 3;
    self.imgRating.frame = imgRatingFrame;
    
    
    
  CGRect showCategoriesframe = self.lblShowCategories.frame;
    showCategoriesframe.origin.y = self.imgRating.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowCategories.frame = showCategoriesframe;

    CGRect categoriesFrame  = self.lblCategories.frame;
    categoriesFrame.origin.y = self.imgRating.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    categoriesFrame.size.height = categoriesLabelHeight;
    self.lblCategories.frame = categoriesFrame;
    
   
    CGRect imgCategoriesFrame  = self.imgCategories.frame;
    imgCategoriesFrame.origin.y = self.lblCategories.frame.origin.y + categoriesLabelHeight + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgCategories.frame = imgCategoriesFrame;
    
    
    
    CGRect showAuthorityframe = self.lblShowAuthority.frame;
    showAuthorityframe.origin.y = self.imgCategories.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowAuthority.frame = showAuthorityframe;
   
    
    
    CGRect AuthorityFrame  = self.lblLocalAuthority.frame;
    AuthorityFrame.origin.y = self.imgCategories.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    AuthorityFrame.size.height = authorityLabelHeight;
    self.lblLocalAuthority.frame = AuthorityFrame;
    
    CGRect imgAuthorityFrame  = self.imgAuthority.frame;
    imgAuthorityFrame.origin.y = self.lblLocalAuthority.frame.origin.y + authorityLabelHeight + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgAuthority.frame = imgAuthorityFrame;
    

    CGRect showcriteriaframe = self.lblShowCriteria.frame;
    showcriteriaframe.origin.y = self.imgAuthority.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowCriteria.frame = showcriteriaframe;
    
    CGRect criteriaFrame  = self.lblCriteria.frame;
    criteriaFrame.origin.y = self.imgAuthority.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    criteriaFrame.size.height = criteriaLabelHeight;
    self.lblCriteria.frame = criteriaFrame;
    
    
    CGRect imgCriteriaFrame  = self.imgCriteria.frame;
    imgCriteriaFrame.origin.y = self.lblCriteria.frame.origin.y + criteriaLabelHeight + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgCriteria.frame = imgCriteriaFrame;

    CGRect showCityframe = self.lblShowTown.frame;
    showCityframe.origin.y = self.imgCriteria.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowTown.frame = showCityframe;

    
    CGRect cityFrame  = self.lblcity.frame;
    cityFrame.origin.y = self.imgCriteria.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    cityFrame.size.height = townLabelHeight;
    self.lblcity.frame = cityFrame;

    CGRect imgCityFrame  = self.imgTown.frame;
    imgCityFrame.origin.y = self.lblcity.frame.origin.y + townLabelHeight + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgTown.frame = imgCityFrame;

    CGRect showEmailframe = self.lblShowEmail.frame;
    showEmailframe.origin.y = self.imgTown.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowEmail.frame = showEmailframe;
    
    
    CGRect emailFrame  = self.btnEmailOpen.frame;
    emailFrame.origin.y = self.imgTown.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    emailFrame.size.height = EMAIL_LABEL_HEIGHT;
    self.btnEmailOpen.frame = emailFrame;

    CGRect imgEmailFrame  = self.imgEmail.frame;
    imgEmailFrame.origin.y = self.btnEmailOpen.frame.origin.y + EMAIL_LABEL_HEIGHT + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgEmail.frame = imgEmailFrame;
    
    CGRect showPostcodeframe = self.lblShowPostcode.frame;
    showPostcodeframe.origin.y = self.imgEmail.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowPostcode.frame = showPostcodeframe;
    
    CGRect postcodeFrame  = self.lblPostcode.frame;
    postcodeFrame.origin.y = self.imgEmail.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    postcodeFrame.size.height = postcodeLabelHeight;
    self.lblPostcode.frame = postcodeFrame;

    CGRect imgPostcodeFrame  = self.imgPostcode.frame;
    imgPostcodeFrame.origin.y = self.lblPostcode.frame.origin.y + postcodeLabelHeight + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgPostcode.frame = imgPostcodeFrame;
    
    
    CGRect showWebsiteframe = self.lblShowWebsite.frame;
    showWebsiteframe.origin.y = self.imgPostcode.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowWebsite.frame = showWebsiteframe;

    CGRect websiteFrame  = self.btnWebAddress.frame;
    websiteFrame.origin.y = self.imgPostcode.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    websiteFrame.size.height = WEBSITE_LABEL_HEIGHT;
    self.btnWebAddress.frame = websiteFrame;
    
    CGRect imgWebsiteFrame  = self.imgWebsite.frame;
    imgWebsiteFrame.origin.y = self.btnWebAddress.frame.origin.y + WEBSITE_LABEL_HEIGHT + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgWebsite.frame = imgWebsiteFrame;


    CGRect showDescriptionframe = self.lblShowDescription.frame;
    showDescriptionframe.origin.y = self.imgWebsite.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN-3;
    self.lblShowDescription.frame = showDescriptionframe;
    
    CGRect descriptionFrame  = self.lblViewDescription.frame;
    descriptionFrame.origin.y = self.imgWebsite.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;;
    descriptionFrame.size.height = descriptionLabelHeight;
    self.lblViewDescription.frame = descriptionFrame;
    
    [self.lblViewDescription sizeToFit];
    
    CGRect imgDescriptionFrame  = self.imgDescription.frame;
    imgDescriptionFrame.origin.y = self.lblViewDescription.frame.origin.y + descriptionLabelHeight + SERVICE_DETAIL_LABEL_MARGIN;
    self.imgDescription.frame = imgDescriptionFrame;
    
    
    CGRect viewReviewFrame = self.viewReviewButton.frame;
    viewReviewFrame.origin.y = self.imgDescription.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;
    self.viewReviewButton.frame = viewReviewFrame;
    
    
    CGRect writeReviewFrame = self.writeReviewButton.frame;
    writeReviewFrame.origin.y = self.imgDescription.frame.origin.y + SERVICE_DETAIL_LABEL_MARGIN;
    self.writeReviewButton.frame = writeReviewFrame;
    
    
    
    [self.scrollView setContentSize:CGSizeMake(320,self.imgBaseField.frame.origin.y + self.imgBaseField.frame.size.height)];
    
    
}

-(float)calculateServiceDetailStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(176,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.serviceFont} context:nil];
    return textRect.size.height;
    
}


-(void)getServiceDetail
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.serviceId)
    {
        DLog(@"ProviderDetail api call not perform because serviceId is not exist");
        return;
    }

    
    NSDictionary *serviceDetailParameter =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"service_id":self.serviceId,
                                                  
                                                  };
    
    NSString *serviceDetailUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_GetServiceDetail];
    
    DLog(@"%s Performing %@ Api \n with Parameter:%@",__FUNCTION__, serviceDetailUrl, serviceDetailParameter);
    
    [serviceManager executeServiceWithURL:serviceDetailUrl andParameters:serviceDetailParameter forTask:kTaskServiceDetail completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s, %@ Api \n ServiceResponse:%@",__FUNCTION__, serviceDetailUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.providerData = [dict objectForKey:@"data"];
                dispatch_async(dispatch_get_main_queue(),^{
                    [self getDetail:self.providerData];
                    
               });
            }
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                
                //self.scrollView.hidden = YES;
                [Utility showAlertMessage:@"Service detail not found" withTitle:@"Message"];
             }
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                
                //self.scrollView.hidden = YES;
                [Utility showAlertMessage:@"Service detail not found" withTitle:@"Message"];
             }

            else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }
        else{
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:@""];
        }
    }];
}


-(void) getDetail :(NSArray *) providerDetailData
{
    self.lblServiceName.text = [[providerDetailData valueForKey:@"service_name"] componentsJoinedByString:@""];
    
    // --------------------------------
    
    CGSize ShouldFitTheContent1 = [_lblServiceName sizeThatFits:_lblServiceName.frame.size];
    _lblServiceNameHeightConstraint.constant = ShouldFitTheContent1.height;
    
    // ----------------------------------

    
    self.phoneString = [[providerDetailData valueForKey:@"service_phone_no"] componentsJoinedByString:@""];
    [self.btnPhoneNum setTitle:_phoneString forState:UIControlStateNormal];
    self.lblLocalAuthority.text = [[providerDetailData valueForKey:@"service_local_authority"] componentsJoinedByString:@""];
    
    // --------------------------------
    
    CGSize ShouldFitTheContent2 = [_lblLocalAuthority sizeThatFits:_lblLocalAuthority.frame.size];
    _lblLocalAuthorityHeightConstraint.constant = ShouldFitTheContent2.height;
    
    // ----------------------------------

    
    self.lblPostcode.text = [[providerDetailData valueForKey:@"service_postcode"] componentsJoinedByString:@""];;
    NSString *btnWebString = [[providerDetailData valueForKey:@"service_website"] componentsJoinedByString:@""];
    [self.btnWebAddress setTitle:btnWebString forState:UIControlStateNormal];
    DLog(@"button web %@",self.btnWebAddress.titleLabel.text);
    
    NSString *criteria = [[providerDetailData valueForKey:@"service_eligibility_creiteria"]componentsJoinedByString:@""];
    if ([Utility getValidString:criteria].length <= 0 || [criteria isEqualToString:@"<null>"]) {
        DLog(@"Null occur in criteria");
    }
    else
    {
       self.lblCriteria.text = criteria;
        
        // --------------------------------
        
        CGSize ShouldFitTheContent3 = [_lblCriteria sizeThatFits:_lblCriteria.frame.size];
        _lblEligibilityCriteriaHeightConstraint.constant = ShouldFitTheContent3.height;
        
        // ----------------------------------
      //[self.lblCriteria setNumberOfLines:0];
    }
    
    self.lblcity.text = [[providerDetailData valueForKey:@"service_town"]componentsJoinedByString:@""];
    self.emailText = [[providerDetailData valueForKey:@"service_email"]componentsJoinedByString:@""];
    [self.btnEmailOpen setTitle:_emailText forState:UIControlStateNormal];
    self.lblCategories.text = [[providerDetailData valueForKey:@"service_category"]componentsJoinedByString:@""];
    
    self.lblViewDescription.text = [[providerDetailData valueForKey:@"service_description"]componentsJoinedByString:@""];
    
    // --------------------------------
    
    CGSize ShouldFitTheContent4 = [_lblViewDescription sizeThatFits:_lblViewDescription.frame.size];
    _lblDescriptionHeightConstraint.constant = ShouldFitTheContent4.height;
    
    // ----------------------------------

    //[self.lblViewDescription setNumberOfLines:0];
    
    
    self.providerRating = [[providerDetailData valueForKey:@"service_rating"]componentsJoinedByString:@""];
    self.isAlreadyReviewed = [[[providerDetailData valueForKey:@"is_already_reviewed"]componentsJoinedByString:@""] boolValue];
    self.writeReviewButton.hidden = self.isAlreadyReviewed;
    
    
 // ----------------- Changes Made By -- > Utkarsh Singh - 30 Sep. 2014
    
    if (self.writeReviewButton.hidden) {
        
        NSDictionary *viewsDictionary = @{@"viewReviewButton":self.viewReviewButton};
        
        
        // 3. Define the "viewReviewButton" Position when "writeReviewButton is hidden" ---->
        
        // Define leading and trailing-->
        
        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-112-[viewReviewButton]-112-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        [self.view addConstraints:constraint_POS_H];
        
}
//--------------------
    
    DLog(@"rating value %@",self.providerRating);
    [self showStarRating];
    
     [self.scrollView setContentSize:CGSizeMake(320,self.imgBaseField.frame.origin.y + self.imgBaseField.frame.size.height - 10)];
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

-(IBAction)viewReviewAction:(id)sender
{
    ViewReviewViewController *review  = [[ViewReviewViewController alloc]initWithNibName:@"ViewReviewViewController" bundle:Nil];
    review.serviceId = self.serviceId;
    review.serviceName = self.lblServiceName.text;
    
    DLog(@"service name %@",review.serviceId);
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:review];
    
    [self presentViewController:nav animated:YES completion:Nil];
}

-(IBAction)WriteReviewAction:(id)sender {
    WriteReviewView *writeReviewView = [[WriteReviewView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    writeReviewView.serviceId = self.serviceId;
    writeReviewView.delegate = self;
    [self.view addSubview:writeReviewView];
}

#pragma mark - WriteReviewViewDelegate

- (void)reviewSubmittedSuccessfully
{
    self.isBtnWriteReviewHidden = NO;
    self.isBtnWriteReviewHidden = self.writeReviewButton.hidden = YES;
    self.writeReviewButton.tag = 1;
    CGRect frame = self.viewReviewButton.frame;
    frame.origin.x = frame.origin.x - 61;
    self.viewReviewButton.frame = frame;
}

- (IBAction)openWebUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.btnWebAddress.titleLabel.text]]];
}

- (IBAction)phoneAction:(id)sender {
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",self.btnPhoneNum.titleLabel.text];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
    if (!mCallWebview)
        mCallWebview = [[UIWebView alloc] init];
    [mCallWebview loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

- (IBAction)emailOpenEvent:(id)sender {
    
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Mail Alert" message:@"Email is not configured. Go to iPhone settings and configure your mail account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
       
        return;
    }else {
   
    NSArray *toRecipents = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@",self.btnEmailOpen.titleLabel.text]];
    
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

#pragma mark ReportToAWMViewDelegate

- (void)reportToAWMVDSuccessfullySubmitted {
    [self.reportToAWMView removeFromSuperview];
    self.isAlreadyReported = YES;
}


- (IBAction)reportToAWMButtonPressed:(id)sender{
    
    if (self.isAlreadyReported) {
        [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Already Reported"];
        return;
    }
    //CGRect frame = self.view.frame;
    
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:CGRectMake(0, -60, 320, 503)];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeReportService;
    self.reportToAWMView.selectedQuestionId = self.serviceId;
    [self.view addSubview:self.reportToAWMView];
}


@end

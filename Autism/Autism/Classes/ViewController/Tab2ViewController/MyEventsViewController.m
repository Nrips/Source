
//
//  MyEventsViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/27/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "MyEventsViewController.h"
#import "CustomLoadingView.h"
#import "MyImageView.h"
#import "ReportToAWMView.h"
#import "Utility.h"
#import "NSDictionary+HasValueForKey.h"

@interface MyEventsViewController ()<ReportToAWMViewDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate,UITextFieldDelegate,UITextViewDelegate>

{
    UIImageView  *imag2;
    EKEventStore *eventStore;
    NSString     *startDate ;
    NSString     *endDate;
    
    NSString *trimStartDate;
    NSString *trimEndDate;
    NSString *eventTitle;
    NSString *eventTime;
    NSString *eventLocation;
    NSString *StartEventTimeInMiliSec;
    NSString *EndEventTimeInMiliSec;
    
    NSTimeInterval start_ms;
    NSTimeInterval end_ms;
    
    NSDate *startNSDate;
    NSDate *endNSDate;
    
    float addressLabelHeight;
    float cityLabelHeight;
    float localAuthorityLabelHeight;
    float postcodeHeight;
    float webUrlLabelHeight;
    float orgizerNameLabelHeight;
    float typeLabelHeight;
    float whoAttendLabelHeight;
    float phoneLabelHeight;
    float detailTextHeight;
    float organiserEmailHeight;
}

@property (strong, nonatomic)MyImageView *imag;
@property (nonatomic,strong) NSDictionary *detailDict;
@property (nonatomic,strong) NSDictionary *arrData;
@property (nonatomic,strong) NSArray *arrTitle;
@property (nonatomic) BOOL isAlreadyReported;
@property (nonatomic) BOOL isEventAttend;

@property (nonatomic,strong)NSString *email;
@property (nonatomic,strong)NSString *StrPhoneNo;
@property (nonatomic,strong)NSString *organizerName;
@property (nonatomic,strong)NSString *webUrl;
@property (nonatomic,strong)NSString *btnAttendTitle;

@property (nonatomic, strong) CustomLoadingView *loadingView;
@property (nonatomic, strong) ReportToAWMView *reportToAWMView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic)UIFont *eventFont;

/*
 @property (strong, nonatomic) IBOutlet UIImageView *imgEvent;
 @property (strong, nonatomic) IBOutlet UIImageView *imgDate;
 @property (strong, nonatomic) IBOutlet UIImageView *imgTime;
 
 @property (strong, nonatomic) IBOutlet UILabel *lblAbout;*/
 @property (strong, nonatomic) IBOutlet UILabel *lblDetailNotFound;


@property (strong, nonatomic) IBOutlet UIButton *btnWebUrl;
@property (strong, nonatomic) IBOutlet UIButton *btnAttendEvent;
@property (strong, nonatomic) IBOutlet UIButton *btnAddToIphone;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoneNum;
- (IBAction)phoneAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnOrganiserEmail;
- (IBAction)emailEvent:(id)sender;
- (IBAction)openWebUrl:(id)sender;

@end

@implementation MyEventsViewController

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
    DLog(@"%s",__FUNCTION__);
    
    [super viewDidLoad];
    
    // TODO-: Added by Utkarsh Singh-->
    [_txtViewDescription setDelegate:self];
    
    CGSize sizeThatShouldFitTheContent = [_txtViewDescription sizeThatFits:_txtViewDescription.frame.size];
    _txtViewDescriptionHeightConst.constant = sizeThatShouldFitTheContent.height;
    

    
    
    self.lblDetailNotFound.hidden = YES;
    self.eventFont = [UIFont systemFontOfSize:13];
    // Do any additional setup after loading the view from its nib.
      self.title = @"Event";
    
    //[self labelHight];
    [self eventDetailApiCall];
    
    eventStore = [[EKEventStore alloc]init];
    
    self.detailDict = [[NSDictionary alloc] init];
    self.arrData =[NSDictionary new];
    int increaseHeight = 0;
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications] && !IS_IPHONE_5) {
        increaseHeight += 88;
       
    }
    self.scrollView.frame = CGRectMake(0, 0, 320, 560);
    //[self.scrollView setContentSize:CGSizeMake(320,760 + increaseHeight)];
    
    
    /*
     UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
     initWithTitle:@"Cancel"
     style:UIBarButtonItemStyleBordered
     target:self
     action:@selector(cancelButtonPressed:)];
     
     self.navigationItem.rightBarButtonItem = cancelButton;
     */
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self getEventAttend];
}


/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }*/

-(void) eventDetailApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *eventDeatils = @{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                   @"event_id": self.strEventId,
                                   };
    
    
    NSString *strEventDetail = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_ShowingEventDetails];
    DLog(@"%s Performing event detail %@ api \n with parameter:%@",__FUNCTION__,strEventDetail,eventDeatils);
    
    [serviceManager executeServiceWithURL:strEventDetail andParameters:eventDeatils forTask:kTaskEventDetailShowing completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s event detail  api %@ \n Response:%@",__FUNCTION__,strEventDetail,response);
        
        if (!error && response) {
            NSDictionary *dict =[NSDictionary new];
            dict = (NSDictionary*)response;
            BOOL isPrivate = [[dict valueForKey:@"is_private"]boolValue];

            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.lblDetailNotFound.hidden = YES;
                    self.arrData = [response objectForKey:@"data"];
                    [self getDetail:self.arrData];
                });
            }
            
            if (isPrivate) {
                
                self.scrollView.hidden = YES;
                [Utility showAlertMessage:@"You do not have access to view this event detail" withTitle:@"Message"];
             }

            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0001"]) {
                
                self.scrollView.hidden = YES;
                [Utility showAlertMessage:@"Event detail not found" withTitle:@"Message"];
            }
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                
                self.scrollView.hidden = YES;
                [Utility showAlertMessage:@"Event detail not found" withTitle:@"Message"];
            }

         else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }
        else
        {
            DLog(@"%s error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:@""];
        }
    }];
}

-(void) getDetail :(NSDictionary *) eventData
{
    self.lblCity.text       =   [[eventData valueForKey:@"event_city"] componentsJoinedByString:@""];
    startDate     =   [[eventData valueForKey:@"event_start_date"] componentsJoinedByString:@""];
    self.lblDate.text       =   [NSString stringWithFormat:@"%@ to",startDate];
    self.lblTime.text       =   [[eventData valueForKey:@"event_start_time"] componentsJoinedByString:@""];
    self.lblLocation.text   =   [[eventData valueForKey:@"event_location"] componentsJoinedByString:@""];
    
    //---------
    CGSize ShouldFitTheContent1 = [_lblLocation sizeThatFits:_lblLocation.frame.size];
    _lblLocationHeightConstraint.constant = ShouldFitTheContent1.height;
    //---------

    
    self.lblAddress.text    =   [[eventData valueForKey:@"event_address1"] componentsJoinedByString:@""];
    
    //---------
    CGSize ShouldFitTheContent = [_lblAddress sizeThatFits:_lblAddress.frame.size];
    _lblAddressHeightConstraint.constant = ShouldFitTheContent.height;
    //---------

    self.lblLocalAuthority.text =   [[eventData valueForKey:@"event_local_authority"] componentsJoinedByString:@""];
    self.lblPostcode.text    =   [[eventData valueForKey:@"event_postcode"] componentsJoinedByString:@""];
    self.lblType.text        =   [[eventData valueForKey:@"event_type"] componentsJoinedByString:@""];
    self.lblOrganiser.text   =   [[eventData valueForKey:@"event_organiser"] componentsJoinedByString:@""];
    self.lblWhoAttend.text   =   [[eventData valueForKey:@"event_who_attend"] componentsJoinedByString:@""];
    
    //---------
    CGSize ShouldFitTheContent2 = [_lblWhoAttend sizeThatFits:_lblWhoAttend.frame.size];
    _lblWhoShouldAttendHeightConstraint.constant = ShouldFitTheContent2.height;
    //---------
    
    
    self.lblEventName.text   =   [[eventData valueForKey:@"event_name"] componentsJoinedByString:@""];
    self.eventDescription    =   [[eventData valueForKey:@"event_description"] componentsJoinedByString:@""];
    
    self.lblEndDate.text     =   [[eventData valueForKey:@"event_end_date"] componentsJoinedByString:@""];
    self.isSelfEvent      =   [[eventData valueForKey:@"event_self"]componentsJoinedByString:@""];
    StartEventTimeInMiliSec  =   [[eventData valueForKey:@"event_start_time_ms"] componentsJoinedByString:@""];
    EndEventTimeInMiliSec    =   [[eventData valueForKey:@"event_end_time_ms"] componentsJoinedByString:@""];
    EndEventTimeInMiliSec    =   [[eventData valueForKey:@"event_end_time_ms"] componentsJoinedByString:@""];
    self.isAlreadyReported = [[[eventData valueForKey:@"is_already_reported"] componentsJoinedByString:@""] boolValue];
    self.isEventAttend = [[[eventData valueForKey:@"event_is_attend"] componentsJoinedByString:@""] boolValue];
    NSString *isEventOrganiser = [[eventData valueForKey:@"is_event_organiser"] componentsJoinedByString:@""];
    self.lblLocation.text = self.strLocation;
    [self.lblLocation sizeToFit];
    self.email = [NSString stringWithFormat:@"%@",[[eventData valueForKey:@"event_organiser_email"] componentsJoinedByString:@""]];
    self.StrPhoneNo = [NSString stringWithFormat:@"%@",[[eventData valueForKey:@"event_organiser_phone"] componentsJoinedByString:@""]];
    self.organizerName = [NSString stringWithFormat:@"%@",[[eventData valueForKey:@"event_organiser_name"] componentsJoinedByString:@""]];
    self.webUrl = [[eventData valueForKey:@"event_organiser_weburl"] componentsJoinedByString:@""];
    
    if ([isEventOrganiser isEqualToString:@"1"]) {
        DLog(@"No mail");
        self.btnOrganiserEmail.userInteractionEnabled = NO;
        self.btnWebUrl.userInteractionEnabled = NO;
    }
    else{
        DLog(@"organiser %@",self.email);
        [self.btnOrganiserEmail setTitle:self.email forState:UIControlStateNormal];
        [self.btnPhoneNum setTitle:self.StrPhoneNo forState:UIControlStateNormal];
        [self.btnWebUrl setTitle:self.webUrl forState:UIControlStateNormal];
        self.lblOrganiser.text = self.organizerName;
        self.btnOrganiserEmail.userInteractionEnabled = YES;
        self.btnWebUrl.userInteractionEnabled = YES;
    }
    
    // ------------------------------------------------
    
    
    _txtViewDescription.text = self.eventDescription;
    
    CGSize sizeThatShouldFitTheContent = [_txtViewDescription sizeThatFits:_txtViewDescription.frame.size];
    _txtViewDescriptionHeightConst.constant = sizeThatShouldFitTheContent.height;
    
    // ------------------------------------------------

    
    
    
    [self.btnAttendEvent setTitle: (self.isEventAttend ?  @"Unattend Event" : @"Attend Event") forState:UIControlStateNormal];
    if (self.isEventAttend) {
        
        self.btnAttendTitle = kTitleUnAttendEvent;
    }
    else
    {
       self.btnAttendTitle = kTitleAttendEvent;
    }
    
    endDate = self.lblEndDate.text;
    
    start_ms = [StartEventTimeInMiliSec doubleValue];
    end_ms   = [EndEventTimeInMiliSec doubleValue];
    
    startNSDate = [NSDate dateWithTimeIntervalSince1970:start_ms];
    endNSDate   = [NSDate dateWithTimeIntervalSince1970:end_ms];
    
    //    DLog(@"Actual event start date : %@",startDate);
    //    DLog(@"Actual event end date : %@",endDate);
    //
    //    DLog(@"Converted event start date from milisec to NSDate : %@",startNSDate);
    //    DLog(@"Converted event end date from milisec to NSDate : %@",endNSDate);
    
    eventTitle = [NSString stringWithFormat:@"%@",self.lblEventName.text];
    eventTime = [NSString stringWithFormat:@"%@",self.lblTime.text];
    eventLocation = [NSString stringWithFormat:@"%@",self.lblLocation.text];
    
    
    NSString * imgUrl = [[eventData valueForKey:@"event_image"] componentsJoinedByString:@""];
    if (imgUrl) {
        [self.imageEvent configureImageForUrl:imgUrl];
        DLog(@"Image \n%@",imgUrl);
        
        if ([self.isSelfEvent boolValue])
            self.btnReportToAwm.hidden = YES;
    }
    
    [self resizeView];
}

-(void)resizeView{
    
    addressLabelHeight = [self calculateEventDetailStringHeight:self.lblAddress.text];
    cityLabelHeight = [self calculateEventDetailStringHeight:self.lblCity.text];
    localAuthorityLabelHeight = [self calculateEventDetailStringHeight:self.lblLocalAuthority.text];
    postcodeHeight = [self calculateEventDetailStringHeight:self.lblPostcode.text];
    webUrlLabelHeight = [self calculateEventDetailStringHeight:self.webUrl];
    orgizerNameLabelHeight = [self calculateEventDetailStringHeight:self.organizerName];
    typeLabelHeight = [self calculateEventDetailStringHeight:self.lblType.text];
    whoAttendLabelHeight = [self calculateEventDetailStringHeight:self.lblWhoAttend.text];
    phoneLabelHeight = [self calculateEventDetailStringHeight:self.StrPhoneNo];
    organiserEmailHeight = [self calculateEventDetailStringHeight:self.email];
    detailTextHeight = [self calculateEventDetailStringHeight:self.lblDescription.text];
    
    CGRect eventImageFrame = self.imgBaseField.frame;
    eventImageFrame.size.height = addressLabelHeight + cityLabelHeight +localAuthorityLabelHeight +postcodeHeight + webUrlLabelHeight +orgizerNameLabelHeight + typeLabelHeight + whoAttendLabelHeight + phoneLabelHeight +organiserEmailHeight + detailTextHeight + EVENT_DETAIL_BASEIMAGE_HEIGHT;
    
     self.imgBaseField.frame = eventImageFrame;
    
    CGRect frame = self.showLabelAddress.frame;
    frame.origin.y = EVENT_DETAIL_LABEL_STARTING_YPOSITION;
    self.showLabelAddress.frame = frame;
    
    CGRect addressFrame  = self.lblAddress.frame;
    addressFrame.origin.y = EVENT_DETAIL_LABEL_STARTING_YPOSITION;
    addressFrame.size.height = addressLabelHeight;
    self.lblAddress.frame = addressFrame;
    
    CGRect imgArrdessFrame  = self.imgAddress.frame;
    imgArrdessFrame.origin.y = self.lblAddress.frame.origin.y + addressLabelHeight + EVENT_DETAIL_LABEL_MARGIN + 4;
    self.imgAddress.frame = imgArrdessFrame;
    
    
    CGRect showCityAddress = self.showLabelCity.frame;
    showCityAddress.origin.y = self.imgAddress.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelCity.frame = showCityAddress;
    
    /*CGRect showCityAddress = self.showLabelCity.frame;
    showCityAddress.origin.y = self.imgAddress.frame.origin.y + 5;
    self.showLabelCity.frame = showCityAddress;*/
    
    CGRect cityFrame = self.lblCity.frame;
    cityFrame.origin.y = self.imgAddress.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    cityFrame.size.height = cityLabelHeight;
    self.lblCity.frame = cityFrame;
    
    CGRect imgCityFrame  = self.imgCity.frame;
    imgCityFrame.origin.y = self.lblCity.frame.origin.y + cityLabelHeight+ EVENT_DETAIL_LABEL_MARGIN;
    self.imgCity.frame = imgCityFrame;
    
    CGRect showAuthorityFrame = self.showLabelLocalAuthority.frame;
    showAuthorityFrame.origin.y =  self.imgCity.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelLocalAuthority.frame = showAuthorityFrame;
    
    CGRect authorityFrame = self.lblLocalAuthority.frame;
    authorityFrame.origin.y = self.imgCity.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    authorityFrame.size.height = localAuthorityLabelHeight;
    self.lblLocalAuthority.frame =authorityFrame;
    
    CGRect imgAuthorityFrame  = self.imgLocalAuthority.frame;
    imgAuthorityFrame .origin.y = self.lblLocalAuthority.frame.origin.y + localAuthorityLabelHeight +EVENT_DETAIL_LABEL_MARGIN;
    self.imgLocalAuthority.frame = imgAuthorityFrame;
    
    
    CGRect showPostCodeFrame = self.showLabelPostcode.frame;
    showPostCodeFrame.origin.y = self.imgLocalAuthority.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelPostcode.frame = showPostCodeFrame;
    
    CGRect postcodeFrame = self.lblPostcode.frame;
    postcodeFrame.origin.y =  self.imgLocalAuthority.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    postcodeFrame.size.height = cityLabelHeight;
    self.lblPostcode.frame = postcodeFrame;
    
    CGRect imgPostcodeFrame  = self.imgPostcode.frame;
    imgPostcodeFrame .origin.y = self.lblPostcode.frame.origin.y + postcodeHeight +EVENT_DETAIL_LABEL_MARGIN;
    self.imgPostcode.frame = imgPostcodeFrame;
    
   CGRect showEventFrame = self.showLabelType.frame;
    showEventFrame.origin.y = self.imgPostcode.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelType.frame = showEventFrame;
    
    CGRect evenFrame = self.lblType.frame;
    evenFrame.origin.y = self.imgPostcode.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    evenFrame.size.height = typeLabelHeight;
    self.lblType.frame = evenFrame;
    
    CGRect imgTypeFrame = self.imgType.frame;
    imgTypeFrame.origin.y = self.lblType.frame.origin.y + typeLabelHeight+ EVENT_DETAIL_LABEL_MARGIN;
    self.imgType.frame = imgTypeFrame;

    
    
    CGRect showAttendFrame = self.showLabelWhoAttend.frame;
    showAttendFrame.origin.y = self.imgType.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelWhoAttend.frame = showAttendFrame;
    
    CGRect AttendFrame = self.lblWhoAttend.frame;
    AttendFrame.origin.y = self.imgType.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    AttendFrame.size.height = whoAttendLabelHeight;
    self.lblWhoAttend.frame = AttendFrame;
    
    CGRect imgAttendFrame = self.imgWhoAttend.frame;
    imgAttendFrame.origin.y = self.lblWhoAttend.frame.origin.y + whoAttendLabelHeight+ EVENT_DETAIL_LABEL_MARGIN;
    self.imgWhoAttend.frame = imgAttendFrame;

    
    CGRect showOrganiserFrame = self.showLabelOrganiser.frame;
    showOrganiserFrame.origin.y = self.imgWhoAttend.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelOrganiser.frame = showOrganiserFrame;
    
    CGRect OrganiserFrame = self.lblOrganiser.frame;
    OrganiserFrame.origin.y = self.imgWhoAttend.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    OrganiserFrame.size.height = orgizerNameLabelHeight;
    self.lblOrganiser.frame = OrganiserFrame;
    
    CGRect imgOrganiserFrame = self.imgOrganizer.frame;
     imgOrganiserFrame.origin.y = self.lblOrganiser.frame.origin.y + orgizerNameLabelHeight + EVENT_DETAIL_LABEL_MARGIN;
    self.imgOrganizer.frame = imgOrganiserFrame;

    
    CGRect showWebUrlFrame = self.showLabelWebURL.frame;
    showWebUrlFrame .origin.y = self.imgOrganizer.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelWebURL.frame = showWebUrlFrame;
    
    CGRect WebUrlFrame = self.btnWebUrl.frame;
    WebUrlFrame .origin.y = self.imgOrganizer.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    //WebUrlFrame.size.height = webUrlLabelHeight;
    self.btnWebUrl.frame = WebUrlFrame;
    
    CGRect imgwebFrame = self.imgWebUrl.frame;
                                              //Here we set alignment for Weburl Button so Add two times EVENT_DETAIL_LABEL_MARGIN
    imgwebFrame .origin.y = self.btnWebUrl.frame.origin.y+ EVENT_DETAIL_LABEL_MARGIN + EVENT_DETAIL_LABEL_MARGIN;
    self.imgWebUrl.frame = imgwebFrame;
    
    
    CGRect showEmailFrame = self.showLabelOrganizerEmail.frame;
    showEmailFrame .origin.y = self.imgWebUrl.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelOrganizerEmail.frame = showEmailFrame;
    
    CGRect emailFrame = self.btnOrganiserEmail.frame;
    emailFrame.origin.y = self.imgWebUrl.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    emailFrame.size.height = organiserEmailHeight;
    self.btnOrganiserEmail.frame = emailFrame;
    
    CGRect imgEmailFrame = self.imgEmail.frame;
    imgEmailFrame .origin.y = self.btnOrganiserEmail.frame.origin.y + organiserEmailHeight + EVENT_DETAIL_LABEL_MARGIN;
    self.imgEmail.frame = imgEmailFrame;
    
    CGRect showPhoneFrame = self.showLabelPhone.frame;
    showPhoneFrame .origin.y = self.imgEmail.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelPhone.frame = showPhoneFrame;
    
    CGRect PhoneFrame = self.btnPhoneNum.frame;
    PhoneFrame .origin.y = self.imgEmail.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    PhoneFrame.size.height = phoneLabelHeight;
    self.btnPhoneNum.frame = PhoneFrame;
    
    CGRect imgPhoneFrame = self.imgPhoneNum.frame;
    imgPhoneFrame.origin.y = self.btnPhoneNum.frame.origin.y + phoneLabelHeight + EVENT_DETAIL_LABEL_MARGIN;
    self.imgPhoneNum.frame = imgPhoneFrame;
    
    CGRect showDetailFrame = self.showLabelDescription.frame;
    showDetailFrame .origin.y = self.imgPhoneNum.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    self.showLabelDescription.frame = showDetailFrame;
    
    CGRect detailFrame = self.lblDescription.frame;
    detailFrame.origin.y = self.imgPhoneNum.frame.origin.y + EVENT_DETAIL_LABEL_MARGIN;
    detailFrame.size.height = detailTextHeight;
    self.lblDescription.frame = detailFrame;
    
    CGRect eventButtonFrame = self.btnAttendEvent.frame;
    eventButtonFrame .origin.y = self.lblDescription.frame.origin.y + detailTextHeight + 20;
    eventButtonFrame.size.height = 30;
    self.btnAttendEvent.frame = eventButtonFrame;

    CGRect calenderButtonFrame = self.btnAddToIphone.frame;
    calenderButtonFrame .origin.y = self.lblDescription.frame.origin.y + detailTextHeight + 20;
    calenderButtonFrame.size.height = 30;
    self.btnAddToIphone.frame = calenderButtonFrame;

    
    
    [self.scrollView setContentSize:CGSizeMake(320,self.imgBaseField.frame.origin.y + self.imgBaseField.frame.size.height)];
    
}

-(float)calculateEventDetailStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(156,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.eventFont} context:nil];
    return textRect.size.height;
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//TODO remove
-(void)getEventAttend
{
    NSDictionary *attendEventParameter =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                          @"event_id": self.strEventId,
                                          };
    
    NSString *strEventAttendUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_AttendEvent];
    DLog(@"%@ api \n  with paramenter%@",strEventAttendUrl, attendEventParameter);
    
    [serviceManager executeServiceWithURL:strEventAttendUrl andParameters:attendEventParameter forTask:kTaskAttendEvent completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%@ api \n response: %@",strEventAttendUrl,response);
        
        if (!error && response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.strMessage =[response objectForKey:@"message"];
                if ([self.strMessage isEqualToString:@"Event Attend Succussfully"]) {
                    [self.btnAttendEvent setTitle:@"Unattend Event" forState:UIControlStateNormal];
                }
                else{
                    [self.btnAttendEvent setTitle:@"Attend Event" forState:UIControlStateNormal];
                }
            });
        }
    }];
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
    CGRect frame = self.view.frame;
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        frame.origin.y -= 130;
    }
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:CGRectMake(0,-60, 320, 568)];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeReportEvent;
    self.reportToAWMView.selectedQuestionId = self.strEventId;
    [self.view addSubview:self.reportToAWMView];
}

- (IBAction)attendEvent:(id)sender {
    
    if ([self.btnAttendTitle isEqualToString:kTitleUnAttendEvent]) {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                          message:@"Are you sure you want to unattend this event ?"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"No", @"Yes", nil];
        myAlert.tag = kTagEventAttendAlert;
        [myAlert show];
    }
 else{
       [self attenEventAction];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != kTagEventAttendAlert) {
        return;
    }
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
    }
    else if (buttonIndex == 1)
    {
        [self attenEventAction];
    }
}



-(void)attenEventAction
{

    NSDictionary *attendEventParameter =@ {@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
        @"event_id": self.strEventId,
    };
    
    NSString *strEventAttendUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_AttendEvent];
    DLog(@"%s Performing Attend event api %@  \n with Parameter : %@",__FUNCTION__,strEventAttendUrl,attendEventParameter);
    
    [serviceManager executeServiceWithURL:strEventAttendUrl andParameters:attendEventParameter forTask:kTaskAttendEvent completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s Attend event api : %@ \n response %@",__FUNCTION__,strEventAttendUrl, response);
        
        if (!error && response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.strMessage = [response objectForKey:@"message"];
               
                DLog(@"Response event detail : %@",response);
                
                if ([self.strMessage isEqualToString:@"Event Attend Succussfully"]) {
                    
                    [self.btnAttendEvent setTitle:@"Unattend Event" forState:UIControlStateNormal];
                    
                     self.btnAttendTitle = kTitleUnAttendEvent;
                }
                else{
                    [self.btnAttendEvent setTitle:@"Attend Event" forState:UIControlStateNormal];
                      self.btnAttendTitle = kTitleAttendEvent;
                    if ([self.delegate respondsToSelector:@selector(didReloadMyEventView)]) {
                        [self.delegate didReloadMyEventView];
                    }
                }
            });
        }
    }];

}



- (IBAction)addToCalender:(id)sender {
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        //[dateFormatter setDateFormat:@"MMMM-dd-yyyy"];
        event.title = eventTitle;
        event.location = eventLocation;
        
        // TODO pass start date
        event.startDate = startNSDate ;
        event.endDate = endNSDate;
        
        // Set 1 Day Before Alarm
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-(60*1440) ];
        event.alarms = [NSArray arrayWithObject:alarm];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        
        NSError *err = nil;
        
        [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
        dispatch_async(dispatch_get_main_queue(), ^{
            if(savedEventId.length == 0)
            {
                [Utility showAlertMessage:@"Failed to add to your iPhone calendar. Please check your calendar settings from settings menu" withTitle:@"Event "];
            }
            else
            {
                [Utility showAlertMessage:@"Event successfully added to your iPhone calendar" withTitle:@"Event"];
            }
        });
        
        
        //DLog(@"Event Identifier(for future use) %@",savedEventId);
        //[Utility showAlertMessage:@"Event successfully added to iPhone calendar." withTitle:@"Event"];
        
    }];
    
}
- (IBAction)phoneAction:(id)sender {
    
    UIWebView *mCallWebview;
    /*NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",self.btnPhoneNum.titleLabel.text];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
    if (!mCallWebview)
        mCallWebview = [[UIWebView alloc] init];
    
    [mCallWebview loadRequest:[NSURLRequest requestWithURL:phoneURL]];*/
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",self.StrPhoneNo];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
    if (!mCallWebview)
        mCallWebview = [[UIWebView alloc] init];
    
    
    [mCallWebview loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
}
- (IBAction)emailEvent:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Mail Alert" message:@"Email cannot be configured. Go to iPhone settings and configure your mail account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }else {
        
        NSArray *toRecipents = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@",self.btnOrganiserEmail.titleLabel.text]];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:toRecipents];
        //[picker setSubject:subject];
        //[picker setMessageBody:body isHTML:YES];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)openWebUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.btnWebUrl.titleLabel.text]]];
}

#pragma mark - Mailcomposer Delegate
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    textView.backgroundColor = [UIColor whiteColor];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


@end





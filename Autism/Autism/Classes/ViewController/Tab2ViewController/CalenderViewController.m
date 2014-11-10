//
//  CalenderViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 5/5/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "CalenderViewController.h"
#import "CKCalendarView.h"
#import "CustomEventDetailCell.h"
#import "MyEventsViewController.h"
#import "MFSideMenu.h"
#import "Utility.h"
#import "EventCountOnMonth.h"

@interface CalenderViewController ()
<CKCalendarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSString *selectedDate;
    NSMutableArray *arrayOfNSDates;
    NSString *dateMonthYear;
    NSDate *dates;
    
}

@property(nonatomic, weak) CKCalendarView *calendar;
@property(nonatomic, strong) CKDateItem *dateItem;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;

@property (nonatomic,strong) NSArray *eventDetailArray;
@property(nonatomic, strong) NSArray *eventCountOnMonthArray;
@property (strong, nonatomic) IBOutlet UILabel *lblNoEventFound;

//@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *tableEventDetails;



@end

@implementation CalenderViewController

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
    // Do any additional setup after loading the view.
    DLog(@"%s",__FUNCTION__);
    
    if (!IS_IPHONE_5) {
        self.tableEventDetails.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }

    [self.navigationController setTitle:@"Calendar"];
    //[self getCheckEventDatesOnLoad];
    
    // Selected date from calendar
    NSDateFormatter *formatter = [NSDateFormatter new] ;
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    selectedDate = [NSString new];
    selectedDate = [NSString stringWithFormat:@"%@",dateString];
    [self sendIdGetEventDetails];
    
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.calendar = calendar;
    calendar.delegate = self;
    
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    //self.minimumDate = [self.dateFormatter dateFromString:@"20/09/2013"];
    //self.minimumDate = [NSDate date];
    
    UIColor *myColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Untitled-1.png"]];
    calendar.backgroundColor = myColor;
    
    
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    calendar.frame = CGRectMake(10, 67, 300, 260);
    [self.view addSubview:calendar];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(calendar.frame) + 4, self.view.bounds.size.width, 24)];
    [self.view addSubview:self.dateLabel];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    [dateFormat1 setDateFormat:@"yyyy-MM-dd"];
    // set english locale
    dateFormat1.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger month = [components month];
    
    dateFormat1.dateFormat=@"yyyy";
    NSString  *YearStringPost = [[dateFormat1 stringFromDate:[NSDate date]] capitalizedString];
    
    dateMonthYear = [NSString stringWithFormat:@"%@-%ld",YearStringPost,(long)month];
    //[self getCheckEventDatesOnLoad];

    
    
}

-(void)dismissViewEvent
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)localeDidChange {
    [self.calendar setLocale:[NSLocale currentLocale]];
}

- (BOOL)dateIsDisabled:(NSDate *)date {
    for (NSDate *disabledDate in self.disabledDates) {
        if ([disabledDate isEqualToDate:date]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)showColorOnEventDates:(NSDate *)date {
    for (NSDate *eventDate in arrayOfNSDates) {
        if ([eventDate isEqualToDate:date]) {
            DLog(@"Date : %@",date);
            return YES;
        }
    }
    return NO;
}

#pragma mark - Service  Method

- (void)sendIdGetEventDetails
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    DLog(@"Selected date %@",selectedDate);
    
    NSDictionary *memberIdDict =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                  @"date" : ObjectOrNull(selectedDate)};
    
    
    NSString *strEventDetail = [NSString stringWithFormat:@"%@%@",BASE_URL,WEb_URL_GetEventDetail];
    DLog(@"%s %@ api \n with parameters : %@",__FUNCTION__,strEventDetail,memberIdDict);
    [serviceManager executeServiceWithURL:strEventDetail andParameters:memberIdDict forTask:kTaskGetEventDetails completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n with response : %@",__FUNCTION__,strEventDetail,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.eventDetailArray = [parsingManager parseResponse:response forTask:task];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.lblNoEventFound.hidden = YES;
                    [self.tableEventDetails reloadData];
                    
                });
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                self.eventDetailArray = nil;
                [self.tableEventDetails reloadData];
                self.lblNoEventFound.hidden = NO;
                
            }
        }else{
            DLog(@"%s Error:%@",__FUNCTION__,error);
            
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

- (void)getCheckEventDatesOnLoad
{
//    if ([NSDate date]) {
//        
//    }
//    else
//    {
    
    DLog(@"DAtemonthYear : %@",dateMonthYear);
    NSDictionary *eventDatesInCalendarParams = @{ @"event_date" : dateMonthYear
                                                  };
    
    NSString *eventDatesInCalendarURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_EventAndCalendar];
    
    DLog(@"Performing EventAndCalendar Dates with parameter:%@",eventDatesInCalendarParams);
    
    [serviceManager executeServiceWithURL:eventDatesInCalendarURL andParameters:eventDatesInCalendarParams forTask:kTaskEventAndCalendar completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s EventAndCalendar Dates Api response :%@",__FUNCTION__,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.eventCountOnMonthArray = [response objectForKey:@"data"];
                
                NSMutableArray *localarray = [NSMutableArray new];
                NSMutableArray *localCountArray = [NSMutableArray new];
                localarray = [self.eventCountOnMonthArray valueForKey:@"event_date"];
                localCountArray = [self.eventCountOnMonthArray valueForKey:@"event_total"];
                DLog(@"Localarray :  %@",localarray);
                
                arrayOfNSDates = [NSMutableArray new];
                for (NSString* dateAsDate in localarray) {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd"];
                    NSDate *dateAsStr = [dateFormat dateFromString:dateAsDate];
                    [arrayOfNSDates addObject:dateAsStr];
                }
                DLog(@"Array :  %@",arrayOfNSDates);
                
                 if ([self showColorOnEventDates:dates])
                {
                    self.dateItem.backgroundColor = [UIColor grayColor];
                    self.dateItem.textColor = [UIColor purpleColor];
                }


                [self calendar:self.calendar configureDateItem:self.dateItem forDate:dates];
                
            } else {
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {
                    [appDelegate userAutismSessionExpire];
                }
                else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"])
                {   self.eventDetailArray = nil;
                    [self.tableEventDetails reloadData];
                }
            }
        } else
        {
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    
}


#pragma mark - CKCalendarDelegate

- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    //DLog(@"DateItem : %@",date);
    /*
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    [dateFormat1 setDateFormat:@"yyyy-MM-dd"];
    // set english locale
    dateFormat1.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger month = [components month];
    
    dateFormat1.dateFormat=@"yyyy";
    NSString  *YearStringPost = [[dateFormat1 stringFromDate:[NSDate date]] capitalizedString];
    
    dateMonthYear = [NSString stringWithFormat:@"%@-%ld",YearStringPost,(long)month];
    //[self getCheckEventDatesOnLoad];
    */

    // TODO: play with the coloring if we want to...
    if ([self dateIsDisabled:date]) {
        dateItem.backgroundColor = [UIColor redColor];
        dateItem.textColor = [UIColor whiteColor];
    }
    else if ([self showColorOnEventDates:date])
    {
        dateItem.backgroundColor = [UIColor grayColor];
        dateItem.textColor = [UIColor purpleColor];
    }
}

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    return ![self dateIsDisabled:date];
}

//Select date and call service method
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    DLog(@"Current selected date %@",[self.dateFormatter stringFromDate:date]);
    selectedDate = [NSString stringWithFormat:@"%@",[self.dateFormatter stringFromDate:date]];
    [self sendIdGetEventDetails];
   
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    DLog(@"month %@",date);
    
    
    UIColor *myColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Untitled-1.png"]];
    if ([date laterDate:self.minimumDate] == date) {
        
        self.calendar.backgroundColor = myColor;
        return YES;
    } else {
        self.calendar.backgroundColor = myColor ;
        return NO;
    }
}

- (void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame {
    DLog(@"calendar layout: %@", NSStringFromCGRect(frame));
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date
{
    /*
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    [dateFormat1 setDateFormat:@"yyyy-MM-dd"];
    
    // set english locale
    dateFormat1.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger month = [components month];
    
    dateFormat1.dateFormat=@"yyyy";
    NSString  *YearStringPost = [[dateFormat1 stringFromDate:date] capitalizedString];
    
    dateMonthYear = [NSString stringWithFormat:@"%@-%ld",YearStringPost,(long)month];
    [self getCheckEventDatesOnLoad];
     */

}


#pragma mark - tableview datasource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.eventDetailArray.count>0)
    {
        //self.scrollView.contentSize = CGPointMake(320, self.tableEventDetails.frame.origin.y);
    }
    DLog(@"Tableview Height : %f",self.tableEventDetails.frame.origin.y);
    return [self.eventDetailArray count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    
    CustomEventDetailCell *cell =[self.tableEventDetails dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        
        cell =[CustomEventDetailCell cellFromNibNamed:@"CustomEventDetailCell"];
    }
    
    [cell configureCell:[self.eventDetailArray objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

#pragma mark - tableview delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomEventDetailCell *cell = (CustomEventDetailCell *)[self.tableEventDetails cellForRowAtIndexPath:indexPath];
    MyEventsViewController *eventVC = [[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    
    eventVC.strEventId = cell.eventIdPass;
    //DLog(@"MY id %@",eventVC.strEventId);
    
    //[[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
    //[[appDelegate rootNavigationController] pushViewController:eventVC animated:YES];
    [self.navigationController pushViewController:eventVC animated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

}

@end

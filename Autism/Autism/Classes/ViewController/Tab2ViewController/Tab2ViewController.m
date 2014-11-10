//
//  Tab2ViewController.m
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

typedef enum {
    
    kTabEvent,
    kTabCalendar
    
}TabAction;

#import "Tab2ViewController.h"
#import "EventDetailShowViewController.h"
#import "CalenderViewController.h"
#import "MFSideMenu.h"


@interface Tab2ViewController ()
{
    TabAction currentTabAction;
}

@property (nonatomic, strong) UINavigationController *tabEventNavController;
@property (nonatomic, strong) UINavigationController *tabCalenderNavController;


- (IBAction)tabBtnAction:(id)sender;
@end

@implementation Tab2ViewController

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
    DLog(@" ");

	// Do any additional setup after loading the view.
    
    self.tabEventNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailShowViewController"];
    [self.tabEventNavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width,self.rootView.frame.size.height )];
    [self.tabEventNavController.view setHidden:NO];
    [self.rootView addSubview:self.tabEventNavController.view];
    
    
    
//    self.tabCalenderNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"CalenderShowViewController"];
//    [self.tabCalenderNavController.view setFrame:CGRectMake(0, -50, self.rootView.frame.size.width, self.rootView.frame.size.height)];
//    [self.tabCalenderNavController.view setHidden:YES];
//    [self.rootView addSubview:self.tabCalenderNavController.view];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tabBtnAction:(id)sender {
    
    [self.tabEventNavController.view setHidden:YES];
    [self.tabCalenderNavController.view setHidden:YES];
    
    currentTabAction = (unsigned)[sender tag];
    
    switch (currentTabAction) {
            
        case kTabEvent:
            [self.tabEventNavController.view setHidden:NO];
            
            [self.baseImageView setImage:[UIImage imageNamed:@"events-calendar.png"]];
            break;
            
        case kTabCalendar:
        {
            CalenderViewController *cal = [self.storyboard instantiateViewControllerWithIdentifier:@"CalenderViewController"];
            //[[appDelegate rootNavigationController] presentViewController:cal animated:YES completion:nil];
            [self.tabCalenderNavController.view setHidden:YES];
            [self.tabEventNavController.view setHidden:NO];
            //[self.baseImageView setImage:[UIImage imageNamed:@"calendar-events.png"]];
            [self.baseImageView setImage:[UIImage imageNamed:@"events-calendar.png"]];

            
            [[appDelegate rootNavigationController]popToRootViewControllerAnimated:NO];
            [[appDelegate rootNavigationController]pushViewController:cal animated:YES];
            
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
            break;
        default:
            break;
    }
}
@end

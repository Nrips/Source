//
//  MyCircleViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 3/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

typedef enum
{
    kTabFindProvider,
    kTabFindPeople
    
}TabAction;


#import "MyCircleViewController.h"
#import "CustomMyPeopleCell.h"
#import "ProfileShowViewController.h"
#import "MyCircleProviderViewController.h"
#import "MyCircleFindPeopleViewController.h"

@interface MyCircleViewController ()
{
    TabAction currentTabAction;
}

@property (nonatomic, strong) UINavigationController *tabPeopleNavController;
@property (nonatomic, strong) UINavigationController *tabFinderNavController;

@property (nonatomic,strong)  NSArray *arrMemberInCircle;
@property (nonatomic,strong) UIRefreshControl *refreshControl;

@end

@implementation MyCircleViewController

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
    DLog(@"%s",__FUNCTION__);
    // Do any additional setup after loading the view from its nib.
    
    
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
                //TODO Apply better approch
                //*> Navigation Isssue
                //[self updateViewForNotificationScreen];
            }
    
    if ([self.parentViewControllerName isEqualToString:kCallerViewQADetail]||[self.parentViewControllerName isEqualToString:kCallerViewHelpful]||[self.parentViewControllerName isEqualToString:kCallerViewReply]) {
        //TODO Apply better approch
         //*> Navigation Isssue
        //[self updateViewForNotificationScreen];
    }

    if ([self.profileType isEqualToString:kProfileTypeOther]) {
     MyCircleProviderViewController *myCircleProviderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCircleProviderViewController"];
        self.title = @"Circle";
        myCircleProviderVC.profileType = kProfileTypeOther;
        myCircleProviderVC.otherMemberId = self.otherMemberId;
        self.tabFinderNavController = [[UINavigationController alloc] initWithRootViewController:myCircleProviderVC];

        MyCircleFindPeopleViewController *myCircleFindPeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCircleFindPeopleViewController"];
        myCircleFindPeopleVC.profileType = kProfileTypeOther;
        myCircleFindPeopleVC.otherMemberId = self.otherMemberId;
       // myCircleFindPeopleVC.parentViewControllerName = self.parentViewControllerName;
        self.tabPeopleNavController = [[UINavigationController alloc] initWithRootViewController:myCircleFindPeopleVC];
    }else{
        self.title = @"My Circle";
        self.tabFinderNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCircleProviderViewController"];
        self.tabPeopleNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCircleFindPeopleViewController"];

    }
  
   // self.tabFinderNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCircleProviderViewController"];
    [self.tabFinderNavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width,self.rootView.frame.size.height )];
    [self.tabFinderNavController.view setHidden:NO];
    [self.rootView addSubview:self.tabFinderNavController.view];
    
    //self.tabPeopleNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCircleFindPeopleViewController"];
    [self.tabPeopleNavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width,self.rootView.frame.size.height )];
    [self.tabPeopleNavController.view setHidden:YES];
    [self.rootView addSubview:self.tabPeopleNavController.view];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//*> Navigation Isssue
-(void)updateViewForNotificationScreen
{
        CGRect frame;
    
    frame = self.rootView.frame;
    frame.origin.y -= 64;
    self.rootView.frame = frame;
    
    frame = self.baseImageView.frame;
    frame.origin.y -= 64;
    self.baseImageView.frame = frame;
    
    frame = self.btnFindPeople.frame;
    frame.origin.y -= 64;
    self.btnFindPeople.frame = frame;
    
    frame = self.btnFindProvider.frame;
    frame.origin.y -= 64;
    self.btnFindProvider.frame = frame;
    
    }

- (IBAction)tabBtnAction:(id)sender {
    [self.tabFinderNavController.view setHidden:YES];
    [self.tabPeopleNavController.view setHidden:YES];
    
    currentTabAction = (int)[sender tag];
    
    switch (currentTabAction) {
            
        case kTabFindProvider:
            [self.baseImageView setImage:[UIImage imageNamed:@"providers-people.png"]];
            [self.tabFinderNavController.view setHidden:NO];
            //[self.tableMyCircle setFrame:CGRectMake(0, 250, 320, 400)];
            break;
            
        case kTabFindPeople:
           [self.baseImageView setImage:[UIImage imageNamed:@"people-providers.png"]];
            [self.tabPeopleNavController.view setHidden:NO];

            break;
        default:
            break;
    }
}

@end

//
//  Tab4ViewController.m
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "Tab4ViewController.h"
#import "PersonInFinder.h"
#import "CustomLabel.h"
#import "CustomTextField.h"
#import "CustomPeopleView.h"
#import "FindPeopleViewController.h"

typedef enum
{
    
    kTabFindProviders,
    kTabFindPeople

}TabAction;


@interface Tab4ViewController ()
{
    TabAction currentTabAction;
}

@property (nonatomic, strong) UINavigationController *tabPeopleNavController;
@property (nonatomic, strong) UINavigationController *tabProvidersNavController;
@property (nonatomic, strong) AppDelegate *appDel;
@property (nonatomic, strong) FindPeopleViewController *findPeopleVC;

- (IBAction)tabBtnAction:(id)sender;


@end

@implementation Tab4ViewController

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
   
    DLog(@"------------");
	// Do any additional setup after loading the view.

    self.appDel = [[UIApplication sharedApplication] delegate];

    self.tabProvidersNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindProviderViewController"];
    [self.tabProvidersNavController.view setFrame:CGRectMake(0, -50, self.rootView.frame.size.width,self.rootView.frame.size.height )];
    [self.tabProvidersNavController.view setHidden:NO];
    [self.rootView addSubview:self.tabProvidersNavController.view];
    
     self.tabPeopleNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindPeopleViewController"];
    [self.tabPeopleNavController.view setFrame:CGRectMake(0, -50, self.rootView.frame.size.width, self.rootView.frame.size.height)];
    [self.tabPeopleNavController.view setHidden:YES];
    [self.rootView addSubview:self.tabPeopleNavController.view];
}

-(void)viewDidAppear:(BOOL)animated
{
   
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)tabBtnAction:(id)sender {
    
    [self.tabProvidersNavController.view setHidden:YES];
    [self.tabPeopleNavController.view setHidden:YES];
    
    
    currentTabAction = (int)[sender tag];
    
    switch (currentTabAction) {
            
        case kTabFindProviders:
            [self.tabProvidersNavController.view setHidden:NO];
            [self.baseImageView setImage:[UIImage imageNamed:@"findproviders-findpeoples.png"]];
           
            self.appDel.strKeyboardHideNotificationName = kHideKeyboardFromFindProviderViewController;

            [[NSNotificationCenter defaultCenter] postNotificationName:kHideKeyboardFromFindPeopleViewController object:nil];
            

            break;
            
        case kTabFindPeople:
            [self.tabPeopleNavController.view setHidden:NO];
            [self.baseImageView setImage:[UIImage imageNamed:@"findpeoples-findproviders.png"]];
            
            self.appDel.strKeyboardHideNotificationName = kHideKeyboardFromFindPeopleViewController;

            [[NSNotificationCenter defaultCenter] postNotificationName:kHideKeyboardFromFindProviderViewController object:nil];

            break;
        default:
            break;
    }
}
@end

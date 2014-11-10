//
//  Tab1ViewController.m
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Neuron Solutions. All rights reserved.
//

typedef enum
{
    kTabActivity,
    kTabPostUpdate
    
}TabAction;



#import "Tab1ViewController.h"
#import "PostViewController.h"


@interface Tab1ViewController ()
{
   TabAction currentTabAction;
}

@property (nonatomic, strong) UINavigationController *tabPostNavController;
@property (nonatomic, strong) UINavigationController *tabActivityNavController;


- (IBAction)tabBtnAction:(id)sender;
@end

@implementation Tab1ViewController

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
    DLog(@" ");
    self.tabActivityNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityShowViewController"];
    [self.tabActivityNavController.view setFrame:CGRectMake(0, 0, self.rootView.frame.size.width, self.rootView.frame.size.height)];
    [self.tabActivityNavController.view setHidden:NO];
    [self.rootView addSubview:self.tabActivityNavController.view];
    

    self.tabPostNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];

    [self.tabPostNavController.view setFrame:CGRectMake(0, 80, self.rootView.frame.size.width,self.rootView.frame.size.height )];
    [self.tabPostNavController.view setHidden:YES];
    [self.rootView addSubview:self.tabPostNavController.view];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tabBtnAction:(id)sender {
    
    [self.tabPostNavController.view setHidden:YES];
    [self.tabActivityNavController.view setHidden:YES];
    
    currentTabAction = (int)[sender tag];
    
    switch (currentTabAction) {
            
        case kTabActivity:
            [self.tabActivityNavController.view setHidden:NO];
            [self.baseImageView setImage:[UIImage imageNamed:@"activity-post-btn.png"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideKeyboardFromPostViewController object:nil];

            break;
            
        case kTabPostUpdate:
            [self.tabPostNavController.view setHidden:NO];
            
            [self.baseImageView setImage:[UIImage imageNamed:@"post-activity-btn.png"]];
            break;
        default:
            break;
    }
}

            
@end

//
//  SideMenuViewController.m
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MyStoryViewController.h"
#import "MyFamilyViewController.h"
#import "MyQaViewController.h"
#import "MFSideMenu.h"
#import "ProfileShowViewController.h"
#import "HomeViewController.h"
#import "AboutUsViewController.h"
#import "MyUpdateViewController.h"
#import "MyCircleViewController.h"
#import "MyImageView.h"
#import "SideMenuCustomCellTableViewCell.h"
#import "MyEventLeftMenuViewController.h"
#import "ContactUsViewController.h"
#import "InboxViewController.h"
#import "Utility.h"
#import "OtherStoryViewController.h"
#import "Tab3ViewController.h"
#import "PostViewController.h"
#import "FindPeopleViewController.h"
#import "FindProviderViewController.h"

@interface SideMenuViewController ()<ProfileShowViewControllerDelegate>

{
    UIView *customHeaderView;
    UIView *customPageHeaderView;
}
@property (strong, nonatomic) MyImageView *userProfileImageView;


@end

@implementation SideMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.frame = CGRectMake(0,200 , 320 ,self.view.frame.size.height);
    
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    //self.tableView.backgroundColor = [UIColor colorWithWhite:0.60f alpha:0.30f];
    
    [self.tableView setSeparatorColor:[UIColor grayColor]];

    
    //self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue-blank-btn.png"]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    arrHeaderElements =[[NSMutableArray alloc] initWithObjects:@"",@"PAGES", nil];
    arrRowsItems =[[NSMutableArray alloc] initWithObjects:@"My Update",@"My Story",@"My Family",@"My Circle",@"My Events",@"My Q+A",@"" ,nil];
    arrRowsPagesItems =[[NSMutableArray alloc] initWithObjects:@"About",@"Contact Us",@"Log Out", nil];
    
    arrOfImages =[[NSMutableArray alloc] initWithObjects:@"left-menu-my-update.png",@"left-menu-my-story.png",@"left-menu-my-family.png",@"left-menu-my-cirle.png",@"left-menu-my-events.png",@"left-menu-my-qa.png",@"left-menu-inbox.png", nil];
    
    arrOfImagesPage =[[NSMutableArray alloc] initWithObjects:@"left-menu-about.png",@"left-menu-contact.png",@"left-menu-sign-out.png", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return [arrHeaderElements count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return [arrRowsItems count];
    } else {
        return [arrRowsPagesItems count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SideMenuCustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell ==nil) {
        NSArray *nibarray = [[NSBundle mainBundle] loadNibNamed:@"SideMenuCustomCellTableViewCell" owner:self options:nil];
        cell = [nibarray objectAtIndex:0];
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //cell.baseImag.image = [arrOfImages objectAtIndex:indexPath.row];
    
    if ([indexPath section ] ==0) {
        cell.baseImag.image =[UIImage imageNamed:[arrOfImages objectAtIndex:[indexPath row]]];
        
        
    } else {
        cell.baseImag.image =[UIImage imageNamed:[arrOfImagesPage objectAtIndex:[indexPath row]]];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIColor *altcolor=[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
    cell.textLabel.textColor =[UIColor whiteColor];
    cell.backgroundColor =altcolor;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [arrHeaderElements objectAtIndex:section];
}

//-(void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    //UIColor *headColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"big-signin-blank.fw.png"]];
//    
//    UIColor *headColor = [UIColor grayColor];
//    UITableViewHeaderFooterView* castView = (UITableViewHeaderFooterView*) view;
//    UIView* content = castView.contentView;
//    content.backgroundColor =headColor;
//    content.alpha =0.9;
//
//}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if ( section ==0) {
        return 85;
    }
    else if(section == 1)
    {
        return  30;
    }
    return 0;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    //int height = 80; //you can change the height
    if(section==0)
    {
        customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 85)];
        [customHeaderView setBackgroundColor:[UIColor colorWithRed:67/255.0f green:78/255.0f blue:93/255.0f alpha:1.0]];
        [self.view addSubview:customHeaderView];
        
        
        UIButton *btnProfileShow = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnProfileShow setFrame:CGRectMake(0, 0, 200, 85)];
        [btnProfileShow addTarget:self action:@selector(myProfileEvent) forControlEvents:UIControlEventTouchUpInside];
        [customHeaderView addSubview:btnProfileShow];
        
        
        UILabel  * lblRole = [[UILabel alloc] initWithFrame:CGRectMake(90, 20, 150, 30)];
        lblRole.backgroundColor = [UIColor clearColor];
        //label.textAlignment = UITextAlignmentCenter; // UITextAlignmentCenter, UITextAlignmentLeft
        lblRole.textColor=[UIColor whiteColor];
        //lblRole.text = @"Alicia Doe";
        lblRole.text = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_NAME] ? [[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_NAME] : @"No Name";
        [customHeaderView addSubview:lblRole];
        
        UILabel  * lblviewMyProfile = [[UILabel alloc] initWithFrame:CGRectMake(90, 50, 150, 30)];
        lblviewMyProfile.backgroundColor = [UIColor clearColor];
        lblviewMyProfile.font = [UIFont fontWithName:@"helvetica" size:10.0f];
        lblviewMyProfile.textColor=[UIColor whiteColor];
        lblviewMyProfile.text = @"View my Profile";
        
        [customHeaderView addSubview:lblviewMyProfile];
        
        //Add Profile Pic
        self.userProfileImageView = [[MyImageView alloc] initWithFrame:CGRectMake(10, 20, 60, 60)];
        self.userProfileImageView.image = [UIImage imageNamed:@"avatar-140"];
        if ([[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL]) {
            [self.userProfileImageView configureImageForUrl:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_USER_DEFAULTS_USER_PROFILE_PIC_URL]];
        } else
        {
            self.userProfileImageView.image =[UIImage imageNamed:@"avatar-140.png"];
        }
        
        [customHeaderView addSubview:self.userProfileImageView];
      
        return customHeaderView;
    }
    else if (section==1)
    {   customPageHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        [customPageHeaderView setBackgroundColor:[UIColor grayColor]];
        UIImageView *imag= [[UIImageView alloc] initWithFrame:CGRectMake(0,0 , 320, 30)];
        [imag setImage:[UIImage imageNamed:@"left-menu-pages.png"]];
        [customPageHeaderView addSubview:imag];
        
        return customPageHeaderView;
    }
    return 0;
}

-(void) myProfileEvent
{
    
    ProfileShowViewController *profShow =[[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
    [profShow setDelegate:self];
    [[appDelegate rootNavigationController] pushViewController:profShow animated:YES];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
}

#pragma mark- UItableView delegates

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        switch (indexPath.row) {
            case 0:
            {
                MyUpdateViewController *profShow =[[MyUpdateViewController alloc] initWithNibName:@"MyUpdateViewController" bundle:nil];
                
                [[appDelegate rootNavigationController] pushViewController:profShow animated:YES];
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

            }
                
                break;
                
                case 1:
            {
               OtherStoryViewController *myStory = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherStoryViewController"];
                
                
                //MyStoryViewController *myStory = [self.storyboard instantiateViewControllerWithIdentifier:@"MyStoryViewController"];
                
                //[self presentViewController:myStory animated:YES completion:nil];
                
                [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                [[appDelegate rootNavigationController] pushViewController:myStory animated:YES];
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
                break;
                
                case 2:
            {
                MyFamilyViewController *myFAmilyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFamilyViewController"];
                
                [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                [[appDelegate rootNavigationController] pushViewController:myFAmilyVC animated:YES];
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
                break;
                
            case 3:
                
            {
                MyCircleViewController *myCircleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCircleViewController"];
                
                [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                [[appDelegate rootNavigationController] pushViewController:myCircleVC animated:YES];
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }

                
                break;
                
            case 4:
            {
                MyEventLeftMenuViewController *myEventVC =[self.storyboard instantiateViewControllerWithIdentifier:@"MyEventLeftMenuViewController"];
                
                [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                [[appDelegate rootNavigationController] pushViewController:myEventVC animated:YES];
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

            }
                break;
            case 5:
              {
                  MyQaViewController *show = [self.storyboard instantiateViewControllerWithIdentifier:@"MyQaViewController"];
                  
                  [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                  [[appDelegate rootNavigationController] pushViewController:show animated:YES];
                  
                  [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                  
               }
                break;
                
            case 6:
            {
                InboxViewController *inbox= [self.storyboard instantiateViewControllerWithIdentifier:@"InboxViewController"];
                [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                [[appDelegate rootNavigationController] pushViewController:inbox animated:YES];

                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
                break;

            default:
                break;
        }
    }
    
    else if ([indexPath section] == 1)
    {
        switch (indexPath.row) {
            case 0:
            {
                AboutUsViewController *about = [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController" bundle:nil];
                
                [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                [[appDelegate rootNavigationController] pushViewController:about animated:YES];
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
                
                break;
                
            case 1:
            {
                ContactUsViewController *contactUsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactUsViewController"];
                
                [[appDelegate rootNavigationController] popToRootViewControllerAnimated:NO];
                [[appDelegate rootNavigationController] pushViewController:contactUsViewController animated:YES];
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }

                break;
                
            case 2:
            {
                [self fbDidLogout];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)fbDidLogout
{
    [self logoutApiCall];

    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
    appdel.isUserLoggedIn = NO;
    appdel.doNotShowLoginPop = YES;
    [appDelegate showHomeScreen];
    [appDelegate clearDefaultValues]; // Facebook session method
}

-(void)logoutApiCall
{
     [userDefaults removeObjectForKey:@"isUserLogin"];
    
    if (![userDefaults objectForKey:DEVICE_ID])
    {
        DLog(@"device id not exist so do not perform logout api.");
        return;
    }
    
    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
    
    if (![appDelegate isNetworkAvailable])
    {
        appdel.isLogoutRequestPending = YES;
        appdel.loggedInMemberID = [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID];
        return;
    }
    appdel.isLogoutRequestPending = NO;

    NSDictionary *logoutApiParameter = @{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           @"device_id": [userDefaults objectForKey:DEVICE_ID] ? [userDefaults objectForKey:DEVICE_ID] :@"",
                                           @"certification_type" : [appDelegate certifcateType]
                                        };
    
    NSString *logoutApiUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_Logout];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__, logoutApiUrl, logoutApiParameter);
    
    [serviceManager executeServiceWithURL:logoutApiUrl andParameters:logoutApiParameter forTask:kTaskLogout completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response:%@",__FUNCTION__,logoutApiUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                DLog(@"User logout Successfully");
            }else {
            }
        }else{
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

#pragma mark - custom delegates
- (void)updateUsersProfileImage:(UIImage *)image
{
    self.userProfileImageView.image = image;
}

@end

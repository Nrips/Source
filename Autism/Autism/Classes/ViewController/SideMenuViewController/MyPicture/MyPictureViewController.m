//
//  MyPictureViewController.m
//  Autism
//
//  Created by Neuron Solutions on 7/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MyPictureViewController.h"
#import "PictureAlbumCell.h"
#import "Utility.h"
#import "AlbumListVC.h"
#import "AlbumList.h"
#import "MFSideMenu.h"
#import <objc/runtime.h>

const char AlertAlbumIdKey;

@interface MyPictureViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,UIAlertViewDelegate>
{
    UIBarButtonItem *addButton;
}
@property (strong, nonatomic) IBOutlet UITableView *tablePictureAlbum;
@property (strong, nonatomic) NSMutableArray *arrAlbumList;
@property (strong, nonatomic) UILongPressGestureRecognizer *longGesture;
@property (strong, nonatomic) NSString *userID;


@end

@implementation MyPictureViewController

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
    
    self.title = @"Albums";
    if (!IS_IPHONE_5) {
        self.tablePictureAlbum.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    
    self.arrAlbumList = [NSMutableArray new];
    //[self callGetAlbumListService];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        self.userID = self.otherMemberId;
        [self callGetAlbumListService:self.userID];
    }
    else{
        addButton = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                     target:self action:@selector(addAlbumEvent)];
        self.navigationItem.rightBarButtonItem = addButton;
        
        self.userID = [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID];
        [self callGetAlbumListService:self.userID];
    }
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrAlbumList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PictureAlbumCell *cell = [self.tablePictureAlbum dequeueReusableCellWithIdentifier:@"PictureAlbumCell" forIndexPath:indexPath];
    [cell configureCell:self.arrAlbumList[indexPath.row]];
    
    if (![self.profileType isEqualToString:kProfileTypeOther])
        cell.rightUtilityButtons = [self rightButtons];
    
    cell.delegate = self;
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PictureAlbumCell *cell = (PictureAlbumCell *)[self.tablePictureAlbum cellForRowAtIndexPath:indexPath];
    AlbumListVC *albumListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AlbumListVC"];
    albumListVC.albumId = cell.albumId;
    albumListVC.title   = cell.albumName;
    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        albumListVC.profileType = self.profileType;
    }
    [cell hideUtilityButtonsAnimated:YES];
    [self.navigationController pushViewController:albumListVC animated:YES];
}

#pragma mark - service manager methods
- (void)callGetAlbumListService:(NSString *)userId
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *postParams =@{    @"member_id": ObjectOrNull([userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]),
                                    @"other_member_id": ObjectOrNull(userId)
                                    };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetALbumList];
    DLog(@"%s Performing %@",__FUNCTION__,urlString);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTaskAlbumList completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s %@ api response :%@",__FUNCTION__,urlString,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.arrAlbumList = [parsingManager parseResponse:response forTask:task];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tablePictureAlbum reloadData];
                });
                
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                
                if ([self.profileType isEqualToString:kProfileTypeOther]) {
                    self.arrAlbumList = nil;
                    self.lblNoRecordFound.hidden = NO;
                  }
                else {
                     self.arrAlbumList = nil;
                     self.lblNoRecordFound.hidden = NO;
                  }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tablePictureAlbum reloadData];
                });

            }
            else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                }
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:@""];
        }
    }];

}

- (void)callAddAlbumService:(NSString *)albumName
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (![Utility getValidString:albumName].length > 0) {
        [Utility showAlertMessage:@"Please enter album name." withTitle:@"Add Album"];
    }
    else{
    NSDictionary *postParams =@{    @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                    @"album_name" : ObjectOrNull(albumName)
                                };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_AddAlbum];
    DLog(@"%s Performing %@",__FUNCTION__,urlString);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTaskAddAlbum completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
       // NSLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                DLog(@"Album created successfully");
                //[self.tablePictureAlbum reloadData];
                [self callGetAlbumListService:self.userID];
                
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                }
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    }
}

- (void)callDeleteAlbumService:(NSString *)albumId
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *postParams =@{    @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                    @"album_id" : ObjectOrNull(albumId)
                                    };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_DeleteAlbum];
    DLog(@"%s Performing %@",__FUNCTION__,urlString);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTaskDeleteAlbum completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                DLog(@"Album created successfully");
                //[self.tablePictureAlbum reloadData];
                [self callGetAlbumListService:self.userID];
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                }
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

- (void)callRenameAlbumService:(NSString *)albumId andName:(NSString *)albumName
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *postParams =@{    @"member_id"  : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                    @"album_id"   : ObjectOrNull(albumId),
                                    @"album_name" : ObjectOrNull(albumName)
                                    };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_RenameAlbum];
    DLog(@"%s Performing %@ with parameters \n %@",__FUNCTION__,urlString,postParams);
    
    [serviceManager executeServiceWithURL:urlString andParameters:postParams forTask:kTaskRenameAlbum completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
        //NSLog(@" %s, %@ api response :%@",__FUNCTION__,urlString,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                DLog(@"Album created successfully");
                //[self.tablePictureAlbum reloadData];
                [self callGetAlbumListService:self.userID];
                
            } else {
                if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"]) {
                    [Utility showAlertMessage:@"Please rename album with proper name" withTitle:@"Edit Album"];
                } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0001"])
                {
                    [Utility showAlertMessage:@""withTitle:@"Error"];
                }
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    
}

#pragma mark - Private methods
- (void)addAlbumEvent
{
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"New Album"
                                message:@"Enter a name for this album"
                                delegate:self cancelButtonTitle:@"Cancel"
                                otherButtonTitles:@"Add", nil];
    alert.tag = 100;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

// Create Cell Buttons
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    UIColor *appColor = appUIGreenColor;
    [rightUtilityButtons sw_addUtilityButtonWithColor:appColor  title:@"Rename"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"Delete"];
    
    return rightUtilityButtons;
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101 && buttonIndex == 1) {
        [self callRenameAlbumService:objc_getAssociatedObject(alertView, &AlertAlbumIdKey) andName:[[alertView textFieldAtIndex:0] text]];
    }
    else if (alertView.tag == 100 && buttonIndex == 1) {
        DLog(@"Add new album");
        [self callAddAlbumService:[[alertView textFieldAtIndex:0] text]];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] < 20 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            DLog(@"utility buttons closed");
            break;
        case 1:
            DLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *cellIndexPath = [self.tablePictureAlbum indexPathForCell:cell];
    PictureAlbumCell *cellAlbum = (PictureAlbumCell *)[self.tablePictureAlbum cellForRowAtIndexPath:cellIndexPath];
    switch (index) {
        case 0:
        {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Edit Album"
                                                          message:@"Enter a new name for this album"
                                                         delegate:self cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Done", nil];
            alert.tag = 101;
            NSString *albumId = cellAlbum.albumId;
            objc_setAssociatedObject(alert ,&AlertAlbumIdKey ,albumId ,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            [self callDeleteAlbumService:cellAlbum.albumId];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        default:
            break;
    }
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return YES;
}


@end

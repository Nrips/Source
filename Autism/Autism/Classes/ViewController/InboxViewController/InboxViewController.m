//
//  InboxViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 6/2/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "InboxViewController.h"
#import "InboxCell.h"
#import "MessageDetailViewController.h"
#import "NewMessegeViewController.h"
#import "ReportToAWMView.h"
#import "Utility.h"
#import "MyImageView.h"
#import "InboxSearchCell.h"
#import "MessageSearch.h"

@interface InboxViewController ()
<UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate, NewMessageViewDelegate,ReportToAWMViewDelegate, InboxCellDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    float selectRowForDelete;
}
@property (strong, nonatomic) NSMutableArray *messageInInboxArray;
@property (strong, nonatomic) NSMutableArray *msgSearchInboxArray;
@property (strong, nonatomic) NSMutableArray *messageDataArray;
@property (strong, nonatomic) NSMutableArray *arrMessageMemberId;
@property (strong, nonatomic) NSMutableArray *arrMessageMemberName;
@property (strong, nonatomic) NSMutableArray *messageMemberImageDataArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UITableView *tableInbox;
@property (strong, nonatomic) ReportToAWMView *reportToAWMView;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecord;
@property (nonatomic, strong) NSMutableArray *searchResult;

@property(nonatomic,strong)NSString *msgMemberName;
@property(nonatomic,strong)NSString *memberId;



- (IBAction)newMessageAction:(id)sender;
@end

@implementation InboxViewController

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
    
    self.messageSearchBar.delegate =self;
    //self.messageSearchBar.showsCancelButton = YES;
    //[self.view addSubview:self.messageSearchBar];
    //[self.messageSearchBar becomeFirstResponder];
    
    DLog(@"%s",__FUNCTION__);
    self.title = @"Inbox";
    [self getMyInboxMessages];
    [self getMyInboxSearchMessages];

    if (!IS_IPHONE_5) {
        self.tableInbox.contentInset = UIEdgeInsetsMake(0, 0, 22, 0); //values passed are - top, left, bottom, right
    }
    else
    {
        self.tableInbox.contentInset = UIEdgeInsetsMake(0, 0, -66, 0); //values passed are - top, left, bottom, right
    }
     self.tableInbox.tableHeaderView = nil;
    [self.messageSearchBar setFrame:CGRectMake(0,65,320,44)];
    
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithTitle:@"New Message" style: UIBarButtonItemStyleBordered target:self action:@selector(newMessageAction)];
    self.navigationItem.rightBarButtonItem = messageButton;

    
    //Refresh control setup
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(getMyInboxMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableInbox addSubview:self.refreshControl];


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getMyInboxMessages];
    //[self.messageSearchBar setFrame:CGRectMake(0,65,320,44)];
    //[self.searchDisplayController.searchBar setFrame:CGRectMake(0,20,320,43)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SearchDisplayController Delegate Methods

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
   [searchBar setShowsCancelButton:YES animated:YES];
   [searchBar becomeFirstResponder];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    [controller.searchBar setFrame:CGRectMake(0,20,320,43)];
    [self.searchDisplayController.searchResultsTableView setDelegate:self];
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
   [self.messageSearchBar setFrame:CGRectMake(0,65,320,44)];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	 searchBar.text = nil;
	//[searchBar resignFirstResponder];
     //searchBar.hidden = YES;
    [self.messageSearchBar setFrame:CGRectMake(0,65,320,44)];
    

}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResult removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"memberName contains[c] %@", searchText];
    
    self.searchResult = [NSMutableArray arrayWithArray: [self.msgSearchInboxArray filteredArrayUsingPredicate:resultPredicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"Array count \n %lu",(unsigned long)self.messageInInboxArray.count);

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult count];
    }
    else
    {
        return [self.messageInInboxArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
         static NSString *cellId = @"cell1";
        
         MessageSearch *search = nil;
        InboxSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        tableView.frame = CGRectMake(0,0,320,510);
        
        if (cell == nil)
         {
             cell = [InboxSearchCell cellFromNibNamed:@"InboxSearchCell"];
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
          search = [self.searchResult objectAtIndex:indexPath.row];
          cell.memberName.text = search.memberName;
         [cell.memberImage configureImageForUrl:search.memberImageUrl];
        return cell;
      }
    
    else{
         static NSString *cellId = @"cell";
    InboxCell *cell = [self.tableInbox dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [InboxCell cellFromNibNamed:@"InboxCell"];
    }
    cell.delegate = self;
    cell.tag = indexPath.row;
  
        [cell configureCell:[self.messageInInboxArray objectAtIndex:indexPath.row]];
        
         return cell;
    }
    return 0;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 44;
    }
 else{
      return 70;
     }
}

#pragma mark - tableview delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ MessageSearch *search = nil;
    MessageDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailViewController"];
   
     if (tableView == self.searchDisplayController.searchResultsTableView){
         
         if (self.searchDisplayController.active) {
             indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
             search = [_searchResult objectAtIndex:indexPath.row];
             
             detail.messageIdPass = search.memberId;
             detail.userNamePass = search.memberName;
          }
       }
    else{
        InboxCell *cell = (InboxCell *)[self.tableInbox cellForRowAtIndexPath:indexPath];
        detail.messageIdPass = cell.inboxMemberId;
        detail.userNamePass = cell.lblName.text;
     }
   [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - service methods

- (void)getMyInboxMessages
{ if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *inboxMemberParams = @{@"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]};
    
    NSString *inboxMemberURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_InboxMemberList];
    
    DLog(@"%s %@ \n with parameter:%@",__FUNCTION__,inboxMemberURL,inboxMemberParams);
    
    [serviceManager executeServiceWithURL:inboxMemberURL andParameters:inboxMemberParams forTask:kTaskInboxMemberList completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api response :%@",__FUNCTION__,inboxMemberURL,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.messageInInboxArray = [parsingManager parseResponse:response forTask:task];
                
                 dispatch_async(dispatch_get_main_queue(),^{
                    self.lblNoRecord.hidden = YES;
                    [self.tableInbox reloadData];
                });
                
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {
                    [appDelegate userAutismSessionExpire];
                }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"])
            {
                self.lblNoRecord.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.messageInInboxArray = nil;
                    [self.tableInbox reloadData];
                });
            }
            
        } else
        {
           DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void)newMessageAction{
  /*  NewMessegeViewController *newMessageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewMessegeViewController"];
    newMessageVC.delegate = self;
    [[appDelegate rootNavigationController] presentViewController:newMessageVC animated:YES completion:nil];*/
    
    UIStoryboard *mainStoryBoard = IS_IPHONE ? [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil]:[UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
    
    NewMessegeViewController *messageVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NewMessegeViewController"];
    [messageVC setDelegate:self];
     messageVC.title = @"New Message";
    
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   
                                   initWithRootViewController:messageVC];
    
    [self presentViewController:nav animated:YES completion:NULL];

    
    
}

#pragma mark - Delete messege API call

- (void)deleteConversation
{
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    MessageInInbox *messageInInbox = [self.messageInInboxArray objectAtIndex:selectRowForDelete];
    if ([Utility getValidString:messageInInbox.memberId].length < 1) {
        DLog(@"Could not delete this Conversation because member id does not exist.");
        return;
    }
    
    NSDictionary *deleteConversationParams = @{ @"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                                @"inbox_member_id" : [Utility getValidString:messageInInbox.memberId]
                                                };
    
    NSString *deleteConversationURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_DeleteConversation];
    
    DLog(@"%s Performing api %@ \n with parameter:%@",__FUNCTION__,deleteConversationURL,deleteConversationParams);
    
    [serviceManager executeServiceWithURL:deleteConversationURL andParameters:deleteConversationParams forTask:kTaskDeleteConversation completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,deleteConversationURL,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                    dispatch_async(dispatch_get_main_queue(),^{
                    [Utility showAlertMessage:@"Conversation deleted successfully." withTitle:@""];
                    [self.messageInInboxArray removeObjectAtIndex:selectRowForDelete];
                    [self.tableInbox reloadData];
                });
                [self getMyInboxMessages];
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {
                    [appDelegate userAutismSessionExpire];
            } else{
                [Utility showAlertMessage:@"This message not deleted " withTitle:@"Error!"];
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}

#pragma mark - New message view delegate
- (void)didReloadInboxTable
{
    [self getMyInboxMessages];
}



-(void)getMyInboxSearchMessages
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    NSDictionary *inboxSearchMemberParams = @{@"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]};
    
    NSString *inboxSearchMemberURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_InboxMemberSearchList];
    
    DLog(@"%s %@ \n with parameter:%@",__FUNCTION__,inboxSearchMemberURL,inboxSearchMemberParams);
    
    [serviceManager executeServiceWithURL:inboxSearchMemberURL andParameters:inboxSearchMemberParams forTask:kTaskInboxSearchMember completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api response :%@",__FUNCTION__,inboxSearchMemberParams,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                self.msgSearchInboxArray = [parsingManager parseResponse:response forTask:task];
               
                DLog(@"messageData %@",self.msgSearchInboxArray);
                
                NSArray *arr = [dict objectForKey:@"data"];
                self.messageDataArray = [arr valueForKeyPath:@"name"];
                self.messageMemberImageDataArray = [arr valueForKey:@"avatar"];
                self.arrMessageMemberId = [arr valueForKeyPath:@"id"];
                                
               // DLog(@"messageData %@ \nand image url%@",self.messageDataArray,self.arrMessageMemberId);
                
                dispatch_async(dispatch_get_main_queue(),^{
                    self.lblNoRecord.hidden = YES;
                    [self.tableInbox reloadData];
                });
                
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {
                [appDelegate userAutismSessionExpire];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"])
            {
                self.lblNoRecord.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.messageInInboxArray = nil;
                    [self.tableInbox reloadData];
                });
            }
            
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    [self.refreshControl endRefreshing];
}



- (void)showReportToAWMViewWithReportID:(NSString*)inboxMemberID
{
    DLog(@"%s, inboxMemberID: %@",__FUNCTION__, inboxMemberID);
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:self.view.frame];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.selectedQuestionId = inboxMemberID;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeInboxMember;
    [self.view addSubview:self.reportToAWMView];
}

- (void)reportToAWMVDSuccessfullySubmitted
{
    DLog(@"%s",__FUNCTION__);
    [self getMyInboxMessages];
}

- (void)deleteConversationForRow:(float)row {
    
    selectRowForDelete = row;
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                      message:@"Once you delete conversation, it cannot be retrieved. Are you sure?"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"No", @"Yes", nil];
    myAlert.tag = kTagDeleteActivityAlert;
    [myAlert show];
   
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != kTagDeleteActivityAlert) {
        return;
    }
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        
    }
    else if (buttonIndex == 1)
    {
        [self deleteConversation];
    }
}

@end

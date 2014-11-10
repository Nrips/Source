//
//  MessageDetailViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 6/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Utility.h"
#import "MessageDetailCell.h"
#import "InboxDetailMessage.h"
#import "PostViewController.h"

@interface MessageDetailViewController ()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

{
    float inboxMessageLabelHeight;
    float rowHeight;
    
    NSString *listOfMessageIDs;
    NSArray *totalMessageIdArray;

}
@property (strong, nonatomic) InboxDetailMessage *messageDetail;
@property (strong, nonatomic) NSMutableArray *inboxDetailArray;
//@property (strong, nonatomic) IBOutlet UITableView *tableMessageDetail;
@property (strong ,nonatomic) UIFont* inboxMessageFont;
@property (strong, nonatomic) IBOutlet UILabel *lblNoMessage;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *btnReplyMessage;

- (IBAction)deleteAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@end

@implementation MessageDetailViewController

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
    // Do any additional setup after loading the view.
    self.title = self.userNamePass;
    
    totalMessageIdArray = [NSArray new];
/*
    if (!IS_IPHONE_5) {
        self.tableMessageDetail.contentInset = UIEdgeInsetsMake(0, 0, -88, 0); //values passed are - top, left, bottom, right
    }else
    {
        self.tableMessageDetail.contentInset = UIEdgeInsetsMake(0, 0, -66, 0); //values passed are - top, left, bottom, right
    }
 */

    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMessages)];
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.inboxMessageFont = [UIFont systemFontOfSize:14];
   [self getMessageDetail];
    
    if (IS_IPHONE_5) {
       
        [self.tableMessageDetail setFrame:CGRectMake(0,-60, 320,555)];
        self.btnSendMessage.frame = CGRectMake(72.0, 515.0, 168, 30);
        self.tableMessageDetail.contentInset = UIEdgeInsetsMake(0, 0, -88, 0); //values passed are - top, left, bottom, right

    }
    else{
        
        [self.tableMessageDetail setFrame:CGRectMake(0, -60, 320,500)];
         self.btnSendMessage.frame = CGRectMake(72.0, 442.0, 168, 30);
        self.tableMessageDetail.contentInset = UIEdgeInsetsMake(0, 0, -66, 0); //values passed are - top, left, bottom, right
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Message Detail service method
- (void)getMessageDetail
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    NSDictionary *getDetailMessageParams = @{ @"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                              @"inbox_member_id" :ObjectOrNull(self.messageIdPass)
                                              };
    
    NSString *getDetailMessageURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMessageconversation];
    
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,getDetailMessageURL,getDetailMessageParams);
    
    [serviceManager executeServiceWithURL:getDetailMessageURL andParameters:getDetailMessageParams forTask:kTaskGetMessageConversation completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api \n response :%@",__FUNCTION__,getDetailMessageURL,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.inboxDetailArray = nil;
                
                [self.btnSendMessage setTitle:@"Reply" forState:UIControlStateNormal];
                self.inboxDetailArray = [parsingManager parseResponse:response forTask:task];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.lblNoMessage.hidden = YES;
                    [self.tableMessageDetail reloadData];
                    [self updateButtonsToMatchTableState];
                });
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0002"])
            {
                self.lblNoMessage.hidden = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.inboxDetailArray = nil;
                    [self.btnSendMessage setTitle:@"Send Message" forState:UIControlStateNormal];
                    [self.tableMessageDetail reloadData];
                    [self updateButtonsToMatchTableState];
                    self.navigationItem.rightBarButtonItem = nil;
                });
            }

            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"] ) {
                 self.lblNoMessage.hidden = NO;
                [self.btnSendMessage setTitle:@"Send Message" forState:UIControlStateNormal];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {
                [appDelegate userAutismSessionExpire];
            }
            
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    
}

#pragma mark - Delete messages
- (void)deleteMessages
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    DLog(@"Message Ids :%@",listOfMessageIDs);
    NSDictionary *messageDetailDeleteParams = @{ @"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                 @"message_ids" : (listOfMessageIDs.length > 0 ? listOfMessageIDs : @"")
                                                 
                                              };
    
    NSString *messageDetailDeleteURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_InboxMessageDetailDelete];
    
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,messageDetailDeleteURL,messageDetailDeleteParams);
    
    [serviceManager executeServiceWithURL:messageDetailDeleteURL andParameters:messageDetailDeleteParams forTask:kTaskMessageDetailDelete completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ Api\n Parameter %@\n response :%@",__FUNCTION__,messageDetailDeleteURL,messageDetailDeleteParams, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
          
            
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.inboxDetailArray = nil;
                    
                    // Exit editing mode after the deletion.
                    [self.tableMessageDetail setEditing:NO animated:YES];
                    //[self.tableMessageDetail reloadData];
                    [self getMessageDetail];
                  
                    //[self updateButtonsToMatchTableState];
                });
                
            } else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] )
                {
                    [appDelegate userAutismSessionExpire];
                }
//                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"])
//                {
//                    //[Utility showAlertMessage:@"Enter valid message" withTitle:@"Message"];
//                }
            
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];

}

#pragma mark - tableview datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"No rows %@", self.inboxDetailArray);
    return self.inboxDetailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"MessageDetailCell";
    
    MessageDetailCell *cell = (MessageDetailCell *)[self.tableMessageDetail dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [self.tableMessageDetail dequeueReusableCellWithIdentifier:identifier];
    }
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
   
    [cell configureCell:[self.inboxDetailArray objectAtIndex:[indexPath row]] detailLabelHeight:inboxMessageLabelHeight andCellHeight:cellHeight];
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateRowHeightAtIndexPath:indexPath];
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    InboxDetailMessage *inboxDetailMessage = [self.inboxDetailArray objectAtIndex:[indexPath row]];
    inboxMessageLabelHeight = [self calculateMessageStringHeight:inboxDetailMessage.message];
    rowHeight =  inboxMessageLabelHeight + MESSAGE_DETAIL_LABEL_YAXIS + CELL_CONTENT_MARGIN;
    if (inboxDetailMessage.imagesArray.count > 0) {
        rowHeight += INBOX_IMAGE_VIEW_HEIGHT + CELL_CONTENT_MARGIN;
    }
    
    if ([Utility getValidString:inboxDetailMessage.attachLinkUrl].length > 0) {
        
        rowHeight += INBOX_ATTACH_LINK_LABEL_HEIGHT + CELL_CONTENT_MARGIN;
     }
    
    if ([Utility getValidString:inboxDetailMessage.attachLinkImageUrl].length > 0) {
        
        rowHeight += INBOX_ATTACH_IMAGE_VIEW_HEIGHT;
    }

    rowHeight += CELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)message
{
    CGRect textRect = [message boundingRectWithSize: CGSizeMake(INBOX_MESSAGELABEL_WIDTH, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.inboxMessageFont} context:nil];
    return textRect.size.height;
}

#pragma mark - tableview delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonsToMatchTableState];
}

-(IBAction)sendMessageButtonPressed:(id)sender {
    DLog(@"%s",__FUNCTION__ );
    
  /*if (!self.appdel.sendDetailMessageVC) {
        self.appdel.sendDetailMessageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.appdel.sendDetailMessageVC];
    self.appdel.sendDetailMessageVC.callerView = kPostUpdateTypeSendDetailMessage;
    self.appdel.sendDetailMessageVC.delegate = self;
    self.appdel.sendDetailMessageVC.otherMemberId = self.otherUserId;
    
    [self presentViewController:navigationController animated:YES completion:nil];*/
    
 PostViewController* postview = [self.storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];

   UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postview];
        postview.callerView = kPostUpdateTypeSendDetailMessage;
        postview.delegate = self;
        postview.otherMemberId = self.messageIdPass;
    
    
    DLog(@"message id %@",self.messageIdPass);

    
  [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Edit methods
- (void)editMessages
{
    [self.tableMessageDetail setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

#pragma mark - Updating button state
-(void)updateButtonsToMatchTableState
{
    if (self.tableMessageDetail.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        [self updateDeleteButtonTitle];
        
        // Show the delete button.
        self.navigationItem.leftBarButtonItem = self.deleteButton;
    }
    else
    {
        // Not in editing mode.

       [self.navigationItem setLeftBarButtonItem:nil animated:NO];
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.inboxDetailArray.count > 0)
        {
           self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableMessageDetail indexPathsForSelectedRows];
    listOfMessageIDs = @"";
    totalMessageIdArray = [self.inboxDetailArray valueForKey:@"messageId"];
    //DLog(@"Your array %@",myarray);
    for(NSIndexPath *index in selectedRows)
    {
        
        NSString *messageID = [totalMessageIdArray objectAtIndex:index.row];
        if([selectedRows lastObject]!=index)
        {
            listOfMessageIDs = [listOfMessageIDs stringByAppendingString:[messageID stringByAppendingString:@","]];
        }
        else
        {
            listOfMessageIDs = [listOfMessageIDs stringByAppendingString:messageID];
            
        }
    }
    
    DLog(@"%s Comma separated string is %@",__FUNCTION__,listOfMessageIDs);
    
    
    BOOL allItemsAreSelected = selectedRows.count == self.inboxDetailArray.count;
    DLog(@"%d",allItemsAreSelected);
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

#pragma mark - Navigation Item Actions

- (IBAction)deleteAction:(id)sender {
	UIAlertView *myAlert;
    DLog(@"Slected index %d",[[self.tableMessageDetail indexPathsForSelectedRows] count]);
    if ( ([[self.tableMessageDetail indexPathsForSelectedRows] count] == 0 )) {
        //actionTitle = NSLocalizedString(@"Are you sure you want to remove all messages?", @"");
        DLog(@"%s",__FUNCTION__);
        
        
        if (self.inboxDetailArray == nil) {
            myAlert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                 message:@"You have no message to delete"
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles: nil];
            
            
        }
        else
        {
            myAlert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                 message:@"Are you sure want to delete all messages.?"
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:@"No", @"Yes", nil];
            myAlert.tag = kTagDeleteAllMessagesAlert;
            
            totalMessageIdArray = [self.inboxDetailArray valueForKey:@"messageId"];
            listOfMessageIDs = [totalMessageIdArray componentsJoinedByString:@","];
            DLog(@"joinedString is : %@", listOfMessageIDs);
        }

       
    }
    else
    {
        //actionTitle = NSLocalizedString(@"Are you sure you want to remove selected messages?", @"");
        DLog(@"%s",__FUNCTION__);
        myAlert = [[UIAlertView alloc] initWithTitle:@"Message"
                                             message:@"Are you sure want to delete selected message.?"
                                            delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:@"No", @"Yes", nil];
        myAlert.tag = kTagDeleteSelectedMessagesAlert;
    }
     [myAlert show];
    
}


-(void)postUpdatedSuccesfully
{
    [self getMessageDetail];
}


- (IBAction)cancelAction:(id)sender {
    [self.tableMessageDetail setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != kTagDeleteSelectedMessagesAlert && alertView.tag != kTagDeleteAllMessagesAlert) {
        return;
    }
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        DLog(@"%s Selected messages",__FUNCTION__);
    }
    else if (buttonIndex == 1)
    {
        DLog(@"%s All messages",__FUNCTION__);
        [self deleteMessages];
    }
}
@end

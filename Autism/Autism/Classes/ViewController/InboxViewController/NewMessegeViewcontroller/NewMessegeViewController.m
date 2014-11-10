//
//  NewMessegeViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 6/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "NewMessegeViewController.h"
#import "CirclePeopleListViewController.h"
#import "Utility.h"

@interface NewMessegeViewController ()
<UITextViewDelegate,CirclePeopleListDelegate>
{
    __block NSMutableArray *nameArray;
    __block NSMutableArray *idForNameArray;
    NSMutableString *strPassId;
    NSMutableString *contactNameString;
    NSMutableArray *myArray;
}
@property (strong, nonatomic) NSMutableArray *contactInCircleArray;

@property(nonatomic, retain) UIColor *barTintColor;
@property (strong, nonatomic) IBOutlet UITextView *tvText;
@property (strong, nonatomic) IBOutlet UITextView *tvTitleContact;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelAction;
- (IBAction)cancelAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnSendMessage;
- (IBAction)sendMessage:(id)sender;
- (IBAction)openContacts:(id)sender;

@end

@implementation NewMessegeViewController

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
        [self.btnSendMessage setFrame:CGRectMake(205,230 ,110 ,30 )];
        [self.tvText setFrame:CGRectMake(10,70 ,300 ,120 )];
    }
    
    [self getMyCircleContact];
    
    UIButton *favButton = [[UIButton alloc]initWithFrame:CGRectMake(240, 44, 30, 30)];

    [favButton setImage:[UIImage imageNamed:@"plus-circle-1.png"] forState:UIControlStateNormal];
    [favButton addTarget:self action:@selector(openContacts)
        forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithCustomView:favButton];
    
    self.navigationItem.rightBarButtonItem = button;
    
    CGColorRef myColor = [UIColor purpleColor].CGColor;
    self.tvText.layer.borderColor = myColor;
    self.tvText.layer.borderWidth = 1.50f;
    self.tvText.layer.cornerRadius = 4.0f;
    [self.tvText becomeFirstResponder];
    
    self.tvText.clipsToBounds = YES;
    self.tvText.delegate = self;
    
    self.btnSendMessage.layer.cornerRadius = 4.0f;
    self.btnSendMessage.clipsToBounds = YES;
    
    self.tvText.delegate = self;
    self.tvTitleContact.delegate = self;
   

    
       /*
    UIToolbar  *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.tintColor = [UIColor darkGrayColor];
    
    UITextView *textEdit =[[UITextView alloc] initWithFrame:CGRectMake(80, 3, 150, 40)];
    [keyboardToolbar addSubview:textEdit];
    UIBarButtonItem* save =[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* cancel =   [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
    [keyboardToolbar setItems:[NSArray arrayWithObjects: save, flexSpace, cancel, nil] animated:NO];
    
    [self.tvText setInputAccessoryView:keyboardToolbar];
    */
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tvText becomeFirstResponder];
}

- (void)done
{
    
}

- (void)close
{
    if(self.tvText){
    [self.tvText resignFirstResponder];
    }
    else
    {
        [self.tvTitleContact resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMyCircleContact
{
    NSDictionary *getMemberContactParams = @{@"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID                ]};
    
    NSString *getMemberContactURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_GetMemberContact];
    
    DLog(@"%s Performing GetMemberCircle api %@ with parameter:%@",__FUNCTION__,getMemberContactURL,getMemberContactParams);
    
    [serviceManager executeServiceWithURL:getMemberContactURL andParameters:getMemberContactParams forTask:kTaskGetMemberContact completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s GetMemberCircle Api response :%@",__FUNCTION__,response);
        
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.contactInCircleArray = [parsingManager parseResponse:response forTask:task];
                //DLog(@"Contact : %@",self.contactInCircleArray);
                nameArray = [[NSMutableArray alloc]init];
                idForNameArray = [[NSMutableArray alloc]init];

                DLog(@"response %@",response);
                
                //[array addObject:[[self.contactInCircleArray valueForKey:@"name"] objectAtIndex:1] ];
                
                for (int i = 0; i<self.contactInCircleArray.count; i++) {
                    NSDictionary *dict =  [[self.contactInCircleArray valueForKey:@"name"] objectAtIndex:i];
                    NSDictionary *dict1 =  [[self.contactInCircleArray valueForKey:@"memberId"] objectAtIndex:i];
                    [nameArray addObject:dict];
                    [idForNameArray addObject:dict1];
                   
                }
                
            } else {
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {
                    [appDelegate userAutismSessionExpire];
                }
            }
        } else
        {
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];

}

- (void)postMessage
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
   
    NSMutableString *passMemberIds;
    if(strPassId == nil)
    {
        passMemberIds = [NSMutableString string];
        [passMemberIds setString:@""];
    }
    else 
    {
        passMemberIds = [NSMutableString stringWithString:strPassId];
        [passMemberIds deleteCharactersInRange:NSMakeRange([passMemberIds length]-1, 1)];
    }
    
    if (![Utility getValidString:self.tvText.text].length > 0) {
        [Utility showAlertMessage:@"Please enter your message and select contact" withTitle:@"Message"];
    }
    else
    {
        
    DLog(@"IdPass : %@",passMemberIds );
    NSDictionary *postMessageParams = @{ @"member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                         @"message_member_id" :ObjectOrNull(passMemberIds),
                                         @"message" : ObjectOrNull(self.tvText.text)
                                        };
    
    NSString *postMessageURL = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_PostMessege];
    
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,postMessageURL,postMessageParams);
    
    [serviceManager executeServiceWithURL:postMessageURL andParameters:postMessageParams forTask:kTaskPostMessege completionHandler:^(id response, NSError *error, TaskType task) {
       
        DLog(@"%s %@ Api \n response :%@",__FUNCTION__,postMessageURL,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utility showAlertMessage:@"Message sent successfully" withTitle:@"Message"];
                    if ([self.delegate respondsToSelector:@selector(didReloadInboxTable)]) {
                        
                        [self.delegate didReloadInboxTable];
                    }
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                });
                
            } else {
                if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"] ) {
                    [appDelegate userAutismSessionExpire];
                }
                else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0003"])
                {
                    [Utility showAlertMessage:@"Please select contact " withTitle:@"Message"];
                }
            }
        } else
        {
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)sendMessage:(id)sender {
    [self postMessage];
}


-(void)openContacts
{
    CirclePeopleListViewController *circleList = [self.storyboard instantiateViewControllerWithIdentifier:@"CirclePeopleListViewController"];
    circleList.memberIdArray = idForNameArray;
    circleList.memberNameArray = nameArray;
    [circleList setDelegate:self];
    [self presentViewController:circleList animated:YES completion:nil];
}

- (IBAction)openContacts:(id)sender {
    
    CirclePeopleListViewController *circleList = [self.storyboard instantiateViewControllerWithIdentifier:@"CirclePeopleListViewController"];
    circleList.memberIdArray = idForNameArray;
    circleList.memberNameArray = nameArray;
    [circleList setDelegate:self];
    [self presentViewController:circleList animated:YES completion:nil];
}

#pragma mark - other class delegate
- (void)didSelectContactNameAndId:(NSMutableArray *)memberId :(NSMutableArray *)name
{
  
    myArray = [NSMutableArray new];
    strPassId = [NSMutableString new];
    contactNameString = [NSMutableString new];
    for( NewMessegeViewController *myObject1 in name) {
        [contactNameString appendString:[NSString stringWithFormat:@"%@, ", myObject1]];
    }
    self.tvTitleContact.text = contactNameString;
    
    for( NewMessegeViewController *myObject2 in memberId) {
        [strPassId appendString:[NSString stringWithFormat:@"%@,", myObject2]];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}
  
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end

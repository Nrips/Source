//
//  OtherStoryViewController.m
//  Autism
//
//  Created by Dipak on 6/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "OtherStoryViewController.h"
#import "NSDictionary+HasValueForKey.h"
#import "OtherStoryCell.h"
#import "ReportToAWMView.h"
#import "UIPlaceHolderTextView.h"
#import "Utility.h"
#import "CustomLabel.h"

static NSString * const kOtherStoryCellIdentifier = @"OtherStoryCell";

@interface OtherStoryViewController () <ReportToAWMViewDelegate,OtherStoryCellProtocol,UITextViewDelegate>
{
    float storyLabelHeight;
    float storyLabel1Height;
    float rowHeight;
    BOOL  keyboardIsShowing;
    int tableViewHeight;
}

@property (nonatomic, strong) NSArray *storyArray;
@property (weak, nonatomic) IBOutlet UILabel *myStoryLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *myStoryLabel1;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *myStoryTextView;

@property (strong, nonatomic) ReportToAWMView *reportToAWMView;
@property (strong, nonatomic) IBOutlet UIImageView *imagQa;
@property (strong, nonatomic) IBOutlet UIImageView *imagA;
@property (strong, nonatomic) IBOutlet UIButton *btnAWM;
@property (nonatomic) BOOL isAlreadyReported;
@property (strong ,nonatomic) UIFont* storyFont;
@property(nonatomic,strong) NSString *firstQuestionText;
@property (nonatomic, strong) NSMutableDictionary *answersDict;
@property (nonatomic, strong) NSMutableArray *answerArray;
@property (nonatomic) float cellRowHeight;
@property(nonatomic, strong) UITextView *activeTextView;

-(IBAction)reportToAWMButtonPressed:(id)sender;

@end

@implementation OtherStoryViewController

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
    
    // Add GestureRecognizer, so we can remove keyboard on view's tap
	UIGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	viewTapGestureRecognizer.cancelsTouchesInView = FALSE;
	[self.view addGestureRecognizer:viewTapGestureRecognizer];
    

    self.answersDict = [[NSMutableDictionary alloc]init];

    self.storyFont = [UIFont systemFontOfSize:12];
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
        self.title = @"Story";
        
        //self.imagQa.hidden = NO;
        //self.imagA.hidden  = NO;
        
        self.myStoryLabel1.hidden = YES;
        
         self.otherStoryTableView.frame = CGRectMake(0,96,320,503);
    }
    else{
        self.title = @"My Story";
        
        self.arrQuestionID = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8", nil];
        
        self.imagQa.hidden = YES;
        self.imagA.hidden  = YES;
        self.myStoryLabel.hidden = YES;
        self.myStoryLabel1.hidden = YES;
        self.btnAWM.hidden = YES;
        
        self.otherStoryTableView.frame = CGRectMake(0,63,320,503);
          
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style: UIBarButtonItemStyleBordered target:self action:@selector(postAnswers:)];
        self.navigationItem.rightBarButtonItem =saveButton;
      }

    //self.otherUserId = @"1";
    
    if (!IS_IPHONE_5) {
        self.otherStoryTableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    
    [self getMemberStoryApiCall];
    tableViewHeight = self.otherStoryTableView.frame.size.height;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	// Register notification when keyboard will be show
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
    
	// Register notification when keyboard will be hide
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

// To remove keyboard notification
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)labelHight
{
   
    storyLabel1Height = [self calculateMessageStringHeight:self.firstQuestionText];
    
    CGRect frame = self.myStoryLabel1.frame;
    frame.size.height = storyLabel1Height;
    self.myStoryLabel1.frame = frame;
    self.myStoryLabel1.text = self.firstQuestionText;
    
    CGRect tableFrame = self.otherStoryTableView.frame;
    tableFrame.origin.y = self.myStoryLabel1.frame.origin.y + storyLabel1Height + 5;
    self.otherStoryTableView.frame = tableFrame;

}

-(void)updateViewForNotificationScreen
{
    CGRect frame;
    
    frame = self.myStoryLabel.frame;
    frame.origin.y -= 64;
    self.myStoryLabel.frame = frame;
    
    frame = self.myStoryLabel1.frame;
    frame.origin.y -= 64;
    self.myStoryLabel1.frame = frame;
    
    frame = self.myStoryTextView.frame;
    frame.origin.y -= 64;
    self.myStoryTextView.frame = frame;
    
    frame = self.otherStoryTableView.frame;
    frame.origin.y -= 64;
    self.otherStoryTableView.frame = frame;
    
    frame = self.imagQa.frame;
    frame.origin.y -= 64;
    self.imagQa.frame = frame;
    
    frame = self.imagA.frame;
    frame.origin.y -= 64;
    self.imagA.frame = frame;
    
    frame = self.btnAWM.frame;
    frame.origin.y -= 64;
    self.btnAWM.frame = frame;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -Tableview Datasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.profileType isEqualToString:kProfileTypeOther]){
    if (self.storyArray.count > 0) {
        return self.storyArray.count;
    }
    return 0;
   }
    else
    {
        return [self.storyArray count];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [self calculateRowHeightAtIndexPath:indexPath];
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	OtherStoryCell *cell = (OtherStoryCell *)[tableView dequeueReusableCellWithIdentifier:kOtherStoryCellIdentifier];
	if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:kOtherStoryCellIdentifier];
   
    }
 
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
  if ([self.profileType isEqualToString:kProfileTypeOther]){
    
        cell.otherStoryTextView.userInteractionEnabled = NO;
        cell.otherStoryTextView.hidden = YES;
        cell.otherStoryTextView.delegate = self;
        cell.profileType = self.profileType;
        [cell configureCell:[self.storyArray objectAtIndex:indexPath.row] detailLabelHeight:storyLabelHeight + 15 andCellHeight:cellHeight];
      }
    
 else{
    self.cellRowHeight = cellHeight;
      [cell setDelegate:self];
      [cell setCurrentSection:indexPath.row];
      cell.imgAnswer.hidden = YES;
      cell.otherStoryTextView.userInteractionEnabled = YES;
      cell.otherStoryLabel.hidden = YES;
    
      [cell configureCell:[self.storyArray objectAtIndex:indexPath.row] detailLabelHeight:storyLabelHeight + 20 andCellHeight:cellHeight];
     //if([Utility getValidString:cell.otherStoryTextView.text].length > 0){
     cell.otherStoryTextView.text = [self.answersDict valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
     //}
     }
    return cell;
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    NSString* answer = [[self.storyArray objectAtIndex:indexPath.row]valueForKeyPath:@"answer"];
    storyLabelHeight = [self calculateMessageStringHeight:answer];
    DLog(@"label hight %f",storyLabelHeight);
    rowHeight =  storyLabelHeight + MESSAGE_DETAIL_LABEL_YAXIS + 40;
    rowHeight += CELL_CONTENT_MARGIN ;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(278,10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.storyFont} context:nil];
    return textRect.size.height;
    
}


-(void)getMemberStoryApiCall
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
if ([self.profileType isEqualToString:kProfileTypeOther]) {
        if (!self.otherUserId) {
        DLog(@"Other Person does not exist id whom story you want show");
        return;
    }
}
    NSDictionary *getMemberStoryParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               @"other_member_id" :[self.profileType isEqualToString:kProfileTypeOther] ? self.otherUserId: [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                           };
    
    NSString *getMemberStoryUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_GetMemberStory];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,getMemberStoryUrl,getMemberStoryParameters);
    
    [serviceManager executeServiceWithURL:getMemberStoryUrl andParameters:getMemberStoryParameters forTask:kTaskGetMemberStory completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s %@ api \n Response:%@",__FUNCTION__,getMemberStoryUrl, response);
        
        if (!error && response) {
            NSDictionary *dataDict = [[NSDictionary alloc]init];
            dataDict = [response objectForKey:@"data"];
            
            if ([[response valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.isAlreadyReported = [[dataDict valueForKey:@"member_story_is_reported"] boolValue] ;
                if ([dataDict hasValueForKey:@"stories"]) {
                    
                    self.storyArray = [dataDict objectForKey:@"stories"];
                    self.answerArray = [self.storyArray valueForKey:@"answer"];
                    
                    for (int i = 0; i < self.answerArray.count ; ++i) {
                        DLog(@"%d \n Answer:%@",i, [self.answerArray objectAtIndex:i]);
                        [self.answersDict setValue:[self.answerArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i]];
                    }
                    
                }
            if ([self.profileType isEqualToString:kProfileTypeOther]){
                if (self.storyArray.count > 0) {
                    NSDictionary *myQuestion = [self.storyArray objectAtIndex:0];
                    DLog(@"myQuestion:%@",myQuestion);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([myQuestion hasValueForKey:@"question"]) {
                            self.myStoryLabel.text = [myQuestion objectForKey:@"question"];
                        }
                        if ([myQuestion hasValueForKey:@"answer"]) {
                            self.firstQuestionText = [myQuestion objectForKey:@"answer"];
                            //[self labelHight];
                         }
                        [self.otherStoryTableView reloadData];
                    });
                }
            }
            else{  dispatch_async(dispatch_get_main_queue(), ^{

                [self.otherStoryTableView reloadData];
                });
              }
            }else if ([[response valueForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.storyArray = nil;
                    [self.otherStoryTableView reloadData];
                });

            }
            else if ([[response valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:@""];
        }
    }];
}


#pragma mark -CustomCellProtocol

-(void) didSelectedTextViewOnSection:(NSString *)answerText sectionNumber:(int)sectionNumber {
    
    [self.answersDict setValue:answerText forKey:[NSString stringWithFormat:@"%ld",(long)sectionNumber]];
}

-(void)assignActiveTextView:(UITextView*) textView {
    self.activeTextView = textView;
}

static id StoryObjectOrNull(id object)
{
    return object ?: [NSNull null];
}

- (IBAction)postAnswers:(id)sender
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    DLog(@"Value dictionary ... %@",self.answersDict);
    BOOL isValidMyStoryString = NO;
    int i;
    for (i=0; i<8 ; i++) {
        NSString *story = [self.answersDict valueForKey:[NSString stringWithFormat:@"%d",i]];
        if ([Utility getValidString:story].length > 1) {
            isValidMyStoryString = YES;
            break;
        }
    }
    if (!isValidMyStoryString) {
        [Utility showAlertMessage:@"My story all answerfield is empty" withTitle:@"Message"];
        DLog(@"My story post answer api call not perform because textfield is empty");
        
        return;
    }
    NSMutableArray *arrAnswers = [NSMutableArray new];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"0"])];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"1"])];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"2"])];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"3"])];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"4"])];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"5"])];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"6"])];
    [arrAnswers addObject:StoryObjectOrNull([self.answersDict valueForKey:@"7"])];
    
    NSDictionary *postAnswers =@{  @"sq_id" :self.arrQuestionID,
                                   @"m_id" :[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                   @"ms_text" :arrAnswers
                                   };
    NSString *getQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_PostAnswers];
    
    DLog(@"%@_PostAnswers parameter",postAnswers);
    
    [serviceManager executeServiceWithURL:getQuestionUrl andParameters:postAnswers forTask:kTAskPostStoryAnswers completionHandler:^(id response, NSError *error, TaskType task) {
        if (!error && response) {
            if ([[response valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Utility showAlertMessage:@"Saved successfully." withTitle:@"My story Answers"];
                    DLog(@"%@ post answer",response);
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else if ([[response valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:@""];
        }
    }];
}


#pragma mark ReportToAWMViewMethods

- (IBAction)reportToAWMButtonPressed:(id)sender {

    if (self.isAlreadyReported) {
        [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Already Reported"];
        return;
    }
    CGRect frame = self.view.frame;
    if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        frame.origin.y -= 130;
    }
    self.reportToAWMView = [[ReportToAWMView alloc] initWithFrame:frame];
    self.reportToAWMView.delegate = self;
    self.reportToAWMView.reportToAWMType = ReportToAWMTypeStory;
    self.reportToAWMView.selectedQuestionId = self.otherUserId;
    [self.view addSubview:self.reportToAWMView];
}


- (void)reportToAWMVDSuccessfullySubmitted {
    self.isAlreadyReported = YES;
    [self.reportToAWMView removeFromSuperview];
}


#pragma mark KeyBoard Show/Hide Delegate

- (void)keyboardWillShow:(NSNotification *)note
{
	CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	CGRect frame = self.otherStoryTableView.frame;
    
	// Start animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    // Get keyboard height
    CGFloat kKeyBoardHeight = keyboardBounds.size.height < keyboardBounds.size.width ? keyboardBounds.size.height : keyboardBounds.size.width;
    
    
    // Reduce size of the Table view
    
    frame.size.height = tableViewHeight - kKeyBoardHeight;
    
	// Apply new size of table view
	self.otherStoryTableView.frame = frame;
    
	// Scroll the table view to see the TextField just above the keyboard
	if (self.activeTextView)
	{
		CGRect textFieldRect = [self.otherStoryTableView convertRect:self.activeTextView.bounds fromView:self.activeTextView];
		textFieldRect.size.height = textFieldRect.size.height + 10;
        
		[self.otherStoryTableView scrollRectToVisible:textFieldRect animated:NO];
	}
    
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{

    [self resignFirstResponders];
	// Get the keyboard size
	CGRect keyboardBounds;
    
	[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
	CGRect frame = self.otherStoryTableView.frame;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
    
    frame.size.height = tableViewHeight;
	self.otherStoryTableView.frame = frame;
	[UIView commitAnimations];
}


-(void)tappedOnView:(id)sender
{
   /* if ([self.activeTextView isFirstResponder]) {
        [self.activeTextView resignFirstResponder];
        
        CGRect frame = self.otherStoryTableView.frame;
       
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        
        frame.size.height = tableViewHeight;
        self.otherStoryTableView.frame = frame;
        [UIView commitAnimations];
    }*/
}

- (void)resignFirstResponders
{
    if ([self.activeTextView isFirstResponder])
        [self.activeTextView resignFirstResponder];
}

@end

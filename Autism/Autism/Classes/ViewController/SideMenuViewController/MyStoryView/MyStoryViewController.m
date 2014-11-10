//
//  MyStoryViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/11/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "MyStoryViewController.h"
#import "CustomStoryView.h"
#import "QuestionsInStory.h"
#import "Utility.h"

@interface MyStoryViewController ()<CustomStoryViewProtocol>

{
    NSString* contentOfTextView;
    NSMutableArray *selections;
    UITextView *activeTextView;
    
}

@property (nonatomic, strong) NSArray *questionsInStory;
@property (nonatomic, strong) NSMutableDictionary *answersDict;
@property(nonatomic,strong)NSString *textLength;
@property(nonatomic,strong)CustomStoryView * cell;
@property (nonatomic, strong) NSArray *storyArray;
@property (nonatomic) BOOL isAlreadyReported;
@property (nonatomic, strong) NSArray *answerArray;

- (IBAction)backAction:(id)sender;
- (IBAction)postAnswers:(id)sender;

@end

@implementation MyStoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
       
    }
    return self;

    
}

-(void)getDyanicStoryQuestions {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    
    NSDictionary *getMemberStoryParameters = @{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               @"other_member_id" : [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                               };
    
    NSString *getMemberStoryUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, WEB_URL_GetMemberStory];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,getMemberStoryUrl,getMemberStoryParameters);
    
    [serviceManager executeServiceWithURL:getMemberStoryUrl andParameters:getMemberStoryParameters forTask:kTaskGetMemberStory completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n Response:%@",__FUNCTION__,getMemberStoryUrl, response);
        if (!error && response) {
            NSDictionary *dataDict = [[NSDictionary alloc]init];
            dataDict = [response objectForKey:@"data"];
            
            DLog(@"%@ story response",response);
            
            if ([[response valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                
                self.arrData =[response objectForKey:@"data"];
                self.storyArray = [self.arrData valueForKey:@"stories"];
                self.arrQuestion =[self.storyArray valueForKey:@"question"];
                self.arrID =[self.storyArray valueForKey:@"question"];
                self.answerArray = [self.storyArray valueForKey:@"answer"];
                
                for (int i = 0; i < self.answerArray.count ; ++i) {
                    DLog(@"%d \n Answer:%@",i, [self.answerArray objectAtIndex:i]);
                    [self.answersDict setValue:[self.answerArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i]];
                }
                [self loadData:self.arrQuestion];
            }
            else if ([[response valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        }
        else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
}


-(void) loadData:id
{
    [self.tableStoryData reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog(@"%s",__FUNCTION__);
    
    [[UITextView appearance] setTintColor:[UIColor blackColor]];
    
    self.title = @"My Story";
    
    self.arrQuestionID = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8", nil];
    UIButton *buttonMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonMenu.frame = CGRectMake(0, 20, 60, 40);
    [buttonMenu setTitle:@"Save" forState:UIControlStateNormal];
    //[buttonMenu setImage:[UIImage imageNamed:@"left-menu-click.png"] forState:UIControlStateNormal];
    [buttonMenu addTarget:self action:@selector(postAnswers:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonMenu];
    
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] init];
    [anotherButton setCustomView:buttonMenu];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    
    self.dict =[NSMutableDictionary new];
    
    self.answersDict = [[NSMutableDictionary alloc]init];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTable)];
    [self.tableStoryData addGestureRecognizer:tapRecognizer];
    
    [self getDyanicStoryQuestions];
    
    self.arrTextViewAnswers = [[NSMutableArray alloc] init];
    selections = [[NSMutableArray alloc] init];
  

	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Register notification when the keyboard will be show
   }

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   }

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	// Remove keyboard notification
   }



- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrID count];
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cell";
    
    CustomStoryView *cell =(CustomStoryView *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell ==  nil) {
        cell = [CustomStoryView cellFromNibNamed:@"CustomStoryView"];
        [cell setDelegate:self];
    }
    [cell setCurrentSection:indexPath.section];
    
    cell.textViewAnswers.text = [self.answerArray objectAtIndex:indexPath.section];
    
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     //UITableViewCell *cell = [self.tableStoryData cellForRowAtIndexPath:indexPath];
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35 ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 316, 40)];
     NSString *title =[self.arrQuestion objectAtIndex:section];
    [titleLable setText:[NSString stringWithString:title]];
    [titleLable setFont:[UIFont systemFontOfSize:13.0f]];
    //[titleLable setFont:[UIFont boldSystemFontOfSize:13.0f]];
    //[titleLable setLineBreakMode:NSLineBreakByClipping];
    [titleLable setNumberOfLines:0];
    [titleLable sizeToFit];
    [customHeader addSubview:titleLable];
    return customHeader;
}


#pragma mark -CustomCellProtocol

-(void) didSelectedTextViewOnSection:(NSString *)answerText sectionNumber:(int)sectionNumber {

    [self.answersDict setValue:answerText forKey:[NSString stringWithFormat:@"%ld",(long)sectionNumber]];

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
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];

}

- (void)didTapTable
{
     [self.tableStoryData endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark KeyBoard Show/Hide Delegate

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint txtFieldOrigin = activeTextView.frame.origin;
    CGFloat txtFieldHeight = activeTextView.frame.size.height;
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height + txtFieldHeight + 25;
    if (!CGRectContainsPoint(visibleRect, txtFieldOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, txtFieldOrigin.y - 180);
        [self.tableStoryData setContentOffset:scrollPoint animated:YES];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableStoryData setContentOffset:CGPointZero animated:YES];
}



@end

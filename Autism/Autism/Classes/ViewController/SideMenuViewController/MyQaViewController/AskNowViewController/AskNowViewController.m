//
//  AskNowViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "AskNowViewController.h"
#import "CustomTextField.h"
#import "QuestionKeywordViewController.h"





@interface AskNowViewController ()<UITextFieldDelegate,QuestionkeywordDelegate>
{
   UITextField *activeTextField;
}

@property (nonatomic,strong) CustomTextField *txtDetail;
@property (nonatomic,strong) CustomTextField *txtEnterKeywords;
@property (nonatomic,strong) CustomTextField *txtQuestion;

@property (nonatomic, strong) NSMutableArray *arrayKeyword;
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;



-(IBAction)backAction:(id)sender;
@end

@implementation AskNowViewController

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
    [self setupFeilds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getKeywordData];
}


-(void) setupFeilds
{
    
    UILabel  * lblQuestion = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 180, 30)];
    lblQuestion.text = @"Question*";
    [self.view addSubview:lblQuestion];
    
    self.txtQuestion = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 110, 280, 30)];
    self.txtQuestion.placeholder = @"Question";
    self.txtQuestion.returnKeyType = UIReturnKeyDefault;
    [self.view addSubview:self.txtQuestion];
    
    
    
    UILabel  * lblKeyword = [[UILabel alloc] initWithFrame:CGRectMake(20,150, 300,100)];
    lblKeyword.text = @"Enter Keyword";
    [self.view addSubview:lblKeyword];
    
    self.txtEnterKeywords = [[CustomTextField alloc] initWithFrame:CGRectMake(20,210,280, 30)];
    self.txtEnterKeywords.placeholder = @"Enter keyword";
    self.txtEnterKeywords.userInteractionEnabled = NO;
    [self.view addSubview:self.txtEnterKeywords];
    
    UIButton *btnEnterKeyword = [UIButton buttonWithType:UIButtonTypeCustom];
    btnEnterKeyword.frame = CGRectMake(260, 210, 30, 30);
    UIImage *buttonImageLocal = [UIImage imageNamed:@"blue-select-drop-down-arrow.png"];
    [btnEnterKeyword setImage:buttonImageLocal forState:UIControlStateNormal];
    [btnEnterKeyword addTarget:self action:@selector(showQuestionKeyword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnEnterKeyword];
    
    
    
    
    UILabel  * lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(20, 280, 300, 30)];
    lblDetail.text = @"Details";
    [self.view addSubview:lblDetail];
    
    self.txtDetail= [[CustomTextField alloc] initWithFrame:CGRectMake(20, 310, 280, 30)];
    self.txtDetail.placeholder = @"Enter Details";
    self.txtDetail.userInteractionEnabled = NO;
    [self.view addSubview:self.txtDetail];
    
    UIButton *btnAskQuestion = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAskQuestion.frame = CGRectMake(30, 400, 270, 30);
    [btnAskQuestion setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnAskQuestion setTitle:@"AskQuestion" forState:UIControlStateNormal];
    btnAskQuestion.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnAskQuestion addTarget:self action:@selector(askQuestion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnAskQuestion];

    
    
    
    
    
    self.txtDetail.delegate=self;
    self.txtEnterKeywords.delegate =self;
    self.txtQuestion.delegate =self;
    
    
}



-(void) getKeywordData
{
    NSString *keywordUrl= [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_QuestionKeywords];
    
    [serviceManager executeServiceWithURL:keywordUrl forTask:kTaskQuestionKeywords completionHandler:^(id response, NSError *error, TaskType task) {
        
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.dictionaryKeyword = parsedData;
                self.arrayKeyword = [[NSMutableArray alloc]init];
                self.arrayKeyword = [parsedData valueForKey:@"data"];
                NSLog(@"%@ tag data",_arrayKeyword);
                for (NSDictionary *localAuthDic in _arrayKeyword) {
                    
                    
                 //[self.roleArray addObject:[localAuthDic valueForKey:@"mr_name"]];
                    
                }
                               //[self.pickerView reloadAllComponents];
                
                
            });
        }
    }];
}



-(void)askQuestion
{
    NSDictionary *askQuestionParameters =@{  @"mq_m_id" :@"24",
                                             @"mq_question" :@"dfda",
                                             @"tags": @"tag3,tag4",
                                             @"mq_details" :@"fdfdsa",
                                          
                                          };

    
    
    NSString *getQuestionUrl = [NSString stringWithFormat:@"http://autism.neuroninc.com/index.php/api/Question/AddQuestion"];
    
    
    [serviceManager executeServiceWithURL:getQuestionUrl andParameters:askQuestionParameters forTask:kTaskPostQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        NSLog(@"askview %@",getQuestionUrl);
    }];
    
  }

-(IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)showQuestionKeyword
{
  
//    OtherLocalAuthorityViewController *otherAuthVc = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherLocalAuthorityViewController"];
//    [otherAuthVc setDelegate:self];
//    [otherAuthVc setSelectedTitle:self.txtLocalAuthority.text];
//    [otherAuthVc setDictionary:self.otherLocalAuthorityArray];
//    [self presentViewController:otherAuthVc animated:YES completion:^{}];

//    KeywordViewController *show = [[KeywordViewController alloc]initWithNibName:@"KeywordViewController" bundle:nil];
//    [show setDelegate:self];
//    [show setDictionary:self.dictionaryKeyword];
//    
//    [self presentViewController:show animated:YES completion:nil];
//    
    
    
   QuestionKeywordViewController *passVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionKeywordViewController"];
    //passVC.passTreatId = idSend;
    [passVC setDelegate:self];
    //[passVC setSelectedTitle:txtTreatment.text];
    [passVC setDictionary:self.dictionaryKeyword];
    
    [self.navigationController pushViewController:passVC animated:YES];
}

@end

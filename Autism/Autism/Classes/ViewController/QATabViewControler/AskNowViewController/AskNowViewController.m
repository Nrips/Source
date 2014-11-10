//
//  AskNowViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "AskNowViewController.h"
#import "CustomTextField.h"

@interface AskNowViewController ()<UITextFieldDelegate>
{
   UITextField *activeTextField;
}

@property (nonatomic,strong) CustomTextField *txtDetail;
@property (nonatomic,strong) CustomTextField *txtEnterKeywords;
@property (nonatomic,strong) CustomTextField *txtQuestion;

@property (nonatomic, strong) NSMutableArray *roleArray;
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
    //[btnEnterKeyword addTarget:self action:@selector(showLocalAuthorityPicker) forControlEvents:UIControlEventTouchUpInside];
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
    
    [serviceManager executeServiceWithURL:keywordUrl forTask:kTaskGetRole completionHandler:^(id response, NSError *error, TaskType task) {
        
        if (!error) {
            id parsedData = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.roleArray = [[NSMutableArray alloc]init];
                NSArray *array = [parsedData valueForKey:@"data"];
                NSLog(@"%@ tag data",array);
                for (NSDictionary *localAuthDic in array) {
                    
                    
                 //[self.roleArray addObject:[localAuthDic valueForKey:@"mr_name"]];
                    
                }
                               //[self.pickerView reloadAllComponents];
                
                
            });
        }
    }];
}





-(void)askQuestion
{
    
  }

-(IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end

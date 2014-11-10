//
//  QuestionKeywordViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/17/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "QuestionKeywordViewController.h"


@interface QuestionKeywordViewController ()
{
    NSMutableArray *arSelectedRows;


}

@property (strong, nonatomic)IBOutlet UITableView *tableView;

@property (strong, nonatomic)NSArray *keywordArray;
@property (strong, nonatomic)NSArray *keywordDataArray;
//@property (strong, nonatomic) NSMutableArray *arSelectedRows;



@property (strong, nonatomic)NSMutableArray *selecteditemArray;

@property (nonatomic, strong) UIBarButtonItem *selectButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;


@end

@implementation QuestionKeywordViewController

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
    
    if (!IS_IPHONE_5) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }

    //[[appDelegate rootNavigationController ]setNavigationBarHidden:YES];
	// Do any additional setup after loading the view.
 
    self.keywordArray = [self.dictionary objectForKey:@"data"];
    //DLog(@"%@tag data2",_keywordArray);
    
    //self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
   self.selecteditemArray = [[NSMutableArray alloc]init];
   // [[appDelegate rootNavigationController ]setNavigationBarHidden:YES];
    
    //self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector()];
    
 
    //[self.navigationItem setRightBarButtonItem:self.doneButton];
     arSelectedRows = [[NSMutableArray alloc] init];
    
    }





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getQuestionKeyword
{
    
    NSString *strStoryQuestions = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_QuestionKeywords];
    
    [serviceManager executeServiceWithURL:strStoryQuestions forTask:kTaskGetStoryQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        if (!error) {
            //id parsedData = [parsingManager parseResponse:response forTask:task];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.keywordDataArray =[NSMutableArray new];
                self.keywordDataArray =[response objectForKey:@"data"];
                
                [self loadData:self.keywordDataArray];
                
            });
        }
    }];
}


-(void) loadData:id
{
    [self.tableView reloadData];
}



-(NSArray *)getSelections {
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    
    for(NSIndexPath *indexPath in arSelectedRows) {
        [selections addObject:[self.keywordArray objectAtIndex:indexPath.row]];
    }
    
    return selections;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    return [self.keywordArray count];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
        
    }

    cell.textLabel.text = [self.keywordArray objectAtIndex:indexPath.row];
    if([arSelectedRows containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     NSString *selectedItem;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType == UITableViewCellAccessoryNone) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        long selectRow =  indexPath.row;
        
        selectedItem = [self.keywordArray objectAtIndex:selectRow];
        
        [arSelectedRows addObject:indexPath];
        [self.selecteditemArray addObject:selectedItem];
        
        DLog(@"%@",arSelectedRows);
        DLog(@" %@",self.selecteditemArray);
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        long selectRow =  indexPath.row;
        
        selectedItem = [self.keywordArray objectAtIndex:selectRow];

        
        [arSelectedRows removeObject:indexPath];
        [self.selecteditemArray removeObject:selectedItem];
        
        DLog(@"%@ remove",arSelectedRows);
        DLog(@"%@ ",self.selecteditemArray);
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(didSelectKeyword:)]) {
        [self.delegate didSelectKeyword:self.selecteditemArray];
                    }
    
       [self.tableView reloadData];
}
-(IBAction)back:(id)sender
{
  if ([self.delegate respondsToSelector:@selector(clickonDone)]) {
        [self.delegate clickonDone];
    }
 [self dismissViewControllerAnimated:YES completion:nil];
  
}

@end

//
//  QuestionKeywordViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/17/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "QuestionKeywordViewController.h"


@interface QuestionKeywordViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSArray *keywordArray;

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
	// Do any additional setup after loading the view.
 
    self.keywordArray = [self.dictionary objectForKey:@"data"];
    //NSLog(@"%@",_keywordArray);
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(editButton:)];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAction)];
    self.doneButton.tintColor = [UIColor redColor];
    [self.navigationItem setRightBarButtonItem:self.selectButton];
    
    
    
    }



- (void)editButton:(id)sender
{
    self.navigationItem.rightBarButtonItem = nil;
    self.doneButton.title = @"Done";
    self.navigationItem.leftBarButtonItem = self.doneButton;
    [self.tableView setEditing:YES animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return cell;
    
    
}



@end

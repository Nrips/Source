//
//  Q+AViewController.m
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "Q+AViewController.h"
#import "Q+ACustomViewCell.h"
#import "AskNowViewController.h"

@interface Q_AViewController ()

-(IBAction)askNow:(id)sender;

@end

@implementation Q_AViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId =@"cell";
    
    Q_ACustomViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        
        NSArray *nibArray =[[NSBundle mainBundle] loadNibNamed:@"MyQaCustomView" owner:self options:nil];
        cell = [nibArray objectAtIndex:0];
    }
    
    //cell.lblAnswerdetail.text =@"Answer  detail";
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(IBAction)backAction:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)askNow:(id)sender{


    AskNowViewController *show = [self.storyboard instantiateViewControllerWithIdentifier:@"AskNowViewController"];
    
    [self presentViewController:show animated:YES completion:nil];
}

@end

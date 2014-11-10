//
//  CirclePeopleListViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 6/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "CirclePeopleListViewController.h"

@interface CirclePeopleListViewController ()
<UITableViewDataSource,UITableViewDelegate>
{
    NSString *strId;
    NSString *strName;
}
@property (strong, nonatomic) IBOutlet UITableView *tableContacts;
@property (nonatomic, strong) NSMutableArray *arrValue;
- (IBAction)cancelEvent:(id)sender;
- (IBAction)doneEvent:(id)sender;


@end

@implementation CirclePeopleListViewController

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
    
    if (!IS_IPHONE_5) {
        self.tableContacts.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    self.arrValue = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelEvent:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneEvent:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.memberNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [self.tableContacts dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [self.memberNameArray objectAtIndex:[indexPath row]];
    if([self.arrValue containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return  cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableContacts cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.arrValue addObject:indexPath];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.arrValue removeObject:indexPath];
    }
    [self.tableContacts deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *selections = [NSMutableArray new];
    NSMutableArray *selectionsIdArray = [NSMutableArray new];
    
    for(NSIndexPath *indexPath in self.arrValue) {
        [selections addObject:[self.memberNameArray objectAtIndex:[indexPath row]]];
        [selectionsIdArray addObject:[self.memberIdArray objectAtIndex:indexPath.row]];
    }
    //DLog(@"Selections %@",selections);
    if ([self.delegate respondsToSelector:@selector(didSelectContactNameAndId::)]) {
        [self.delegate didSelectContactNameAndId:selectionsIdArray :selections];
    }
}

@end

//
//  BehaviourViewController.m
//  Autism
//
//  Created by Neuron-iPhone on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "BehaviourViewController.h"
#import "Behaviour.h"


@interface BehaviourViewController ()

{
    NSString *title;
}


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *array;

- (IBAction)startSelection:(id)sender;


- (IBAction)backEvent:(id)sender;


@end

@implementation BehaviourViewController

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
    if (self.passBehaveId) {
        self.navigationItem.title = @"Select Behaviour";
    }
    else if(self.passTreatId)
    {
        self.navigationItem.title = @"Select Interventions";
    }

    
    self.array = [self.dictionary objectForKey:@"data"];
    
    self.arraytreatment =[self.dictionary objectForKey:@"data"];
    
    DLog(@"Actual Data %@",self.arraytreatment);

    self.arrValue = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    if (self.passBehaveId) {
        DLog(@"%@",self.behaviourArray);
        return  [self.behaviourArray count];
    }
    else if(self.passTreatId)
    {
        return  [self.arraytreatment count];
    }
   return 0;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.passBehaveId) {
        
       /* NSArray *Values = [[self.array objectAtIndex:section] objectForKey:@"value"];
       
        return  [Values count] ;*/
        Behaviour *behaviour = [self.behaviourArray objectAtIndex:section];
        return behaviour.behaviourArray.count;
    }
    else if(self.passTreatId)
    {
       // NSArray *Values = [[self.arraytreatment valueForKey:@"value"] valueForKey:@"subname"];
        NSArray *Values = [[[self.array objectAtIndex:section] objectForKey:@"value"] valueForKey:@"subname"];
        
        return  [Values count] ;
    }
    
       return 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 
    
    if (self.passBehaveId) {
        
        Behaviour *behaviour = [self.behaviourArray objectAtIndex:section];
        NSString *categoryName = behaviour.behaviourCategoryName;
        return categoryName;
    }
    else if(self.passTreatId)
    {
    }
    return 0;
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)] ;
//    
//    [headerView setBackgroundColor:[UIColor colorWithRed:102/255.0f green:247/255.0f blue:133/255.0f alpha:1.0f]];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (self.passBehaveId) {
        
        Behaviour *behaviour = [self.behaviourArray objectAtIndex:indexPath.section];
        NSDictionary *behaviourDict = [behaviour.behaviourArray objectAtIndex:indexPath.row];
        NSString *behaviourName = [behaviourDict objectForKey:@"behaviour_name"];
        [cell.textLabel setText:behaviourName];
        if([self.arrValue containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if(self.passTreatId)
    {
        title = [[[[self.array objectAtIndex:indexPath.section] objectForKey:@"value"] valueForKey:@"subname" ]objectAtIndex:indexPath.row];
        
        [cell.textLabel setText:title];
        
        if([self.arrValue containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

#pragma mark -uitbaleview delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.passBehaveId)
    {
        
        //[cell.textLabel setText:behaviourName];
        if(cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.arrValue addObject:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.arrValue removeObject:indexPath];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSMutableArray *selections = [[NSMutableArray alloc] init];
        NSMutableArray *selectionsIdArray = [[NSMutableArray alloc] init];

        
        for(NSIndexPath *indexPath in self.arrValue) {
            Behaviour *behaviour = [self.behaviourArray objectAtIndex:indexPath.section];
            DLog(@"behaviour:%@",behaviour);
            NSDictionary *behaviourDict = [behaviour.behaviourArray objectAtIndex:indexPath.row];
            NSString *behaviourName = [behaviourDict objectForKey:@"behaviour_name"];
            NSString *behaviourID = [behaviourDict objectForKey:@"behaviour_id"];
            [selections addObject:behaviourName];
            [selectionsIdArray addObject:behaviourID];
        }
        
        if ([self.delegate respondsToSelector:@selector(didSelectedBehaviour::)]) {
            [self.delegate didSelectedBehaviour:selections:selectionsIdArray];
        }
        
        /* if(cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.arrValue addObject:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.arrValue removeObject:indexPath];
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        NSMutableArray *selections = [[NSMutableArray alloc] init];
        
        for(NSIndexPath *indexPath in self.arrValue) {
            
            [selections addObject:[[[[self.array objectAtIndex:indexPath.section] objectForKey:@"value"] valueForKey:@"subname" ]objectAtIndex:indexPath.row]];
            
        }
        self.selectedTitle = [[[[self.array objectAtIndex:indexPath.section] objectForKey:@"value"] valueForKey:@"subname" ]objectAtIndex:indexPath.row];
        
        if ([self.delegate respondsToSelector:@selector(didSelectedBehaviour:)]) {
            [self.delegate didSelectedBehaviour:selections];
        }*/
        //[self.tableView reloadData];
    }
    else if(self.passTreatId)
        
    {
        if(cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.arrValue addObject:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.arrValue removeObject:indexPath];
        }
        NSMutableArray *selections = [[NSMutableArray alloc] init];
        NSMutableArray *selectionsIdInterven = [[NSMutableArray alloc] init];
        
        for(NSIndexPath *indexPath in self.arrValue) {
            [selections addObject:[[[[self.array objectAtIndex:indexPath.section] objectForKey:@"value"] valueForKey:@"subname" ]objectAtIndex:indexPath.row]];
            [selectionsIdInterven addObject:[[[[self.array objectAtIndex:indexPath.section] objectForKey:@"value"] valueForKey:@"id" ]objectAtIndex:indexPath.row]];
        }
        
        DLog(@"Id : %@",selections);
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        self.selectedTitle = [[[[self.array objectAtIndex:indexPath.section] objectForKey:@"value"] valueForKey:@"subname" ]objectAtIndex:indexPath.row];
        self.selectedID = [[[[self.array objectAtIndex:indexPath.section] objectForKey:@"value"] valueForKey:@"id" ]objectAtIndex:indexPath.row];
        
        if ([self.delegate respondsToSelector:@selector(didSelectedBehaviour::)]) {
            [self.delegate didSelectedTreatment:selections :selectionsIdInterven];
        }
        [self.tableView reloadData];
    }
}

- (IBAction)startSelection:(id)sender {
    
    
}

- (IBAction)backEvent:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end

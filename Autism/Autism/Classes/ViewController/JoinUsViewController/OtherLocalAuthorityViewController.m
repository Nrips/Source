//
//  OtherLocalAuthorityViewController.m
//  Autism
//
//  Created by Haider on 09/02/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "OtherLocalAuthorityViewController.h"

@interface OtherLocalAuthorityViewController ()<UITableViewDataSource,UITableViewDelegate>
- (IBAction)backAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *array;
@end

@implementation OtherLocalAuthorityViewController

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
    
    self.array = [self.dictionary objectForKey:@"data"];
    //NSArray *array2 =[self.array valueForKey:@"mla_name"];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  [self.array count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *subNames = [[self.array objectAtIndex:section] objectForKey:@"subname"];
    return  [subNames count] ;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = [[self.array objectAtIndex:section] objectForKey:@"name"];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = [[[self.array objectAtIndex:indexPath.section] objectForKey:@"subname"] objectAtIndex:indexPath.row];
    
    static NSString *cellId = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if ([title isEqualToString:self.selectedTitle]) {
    
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    [cell.textLabel setText:title];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedTitle = [[[self.array objectAtIndex:indexPath.section] objectForKey:@"subname"] objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectedLocalAuthority:)]) {
        [self.delegate didSelectedLocalAuthority:self.selectedTitle];
    }
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

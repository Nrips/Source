//
//  ViewReviewViewController.m
//  Autism
//
//  Created by Neuron Solutions on 5/29/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ViewReviewViewController.h"
#import "Utility.h"
#import "ViewReviewCell.h"
#import "ViewReview.h"
#import "FindProvider.h"
#import "WriteReviewView.h"

@interface ViewReviewViewController ()<ViewReviewCellDelegate,WriteReviewViewDelegate>
{
    float reviewLabelHeight;
    float rowHeight;

}

@property(nonatomic,strong)NSArray *reviewArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong ,nonatomic) UIFont* reviewFont;
//@property(strong,nonatomic) wr *commentView;
@property(nonatomic,strong)NSString * serviceReviewtext;
@property(nonatomic,strong)IBOutlet UILabel * lblNoReview;

@end

@implementation ViewReviewViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.lblNoReview.hidden = YES;
    
    self.title = @"View Review";
    
    self.reviewFont = [UIFont systemFontOfSize:13];
    self.txtviewService.text = self.serviceName;
    if (!IS_IPHONE_5) {
        self.tblViewReview.contentInset = UIEdgeInsetsMake(0, 0, 88, 0); //values passed are - top, left, bottom, right
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(backAction:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    

    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(viewReview) forControlEvents:UIControlEventValueChanged];
    [self.tblViewReview addSubview:self.refreshControl];
    
    [self viewReview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewReview{

    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.serviceId)
    {
        DLog(@"viewReviewAction api call not perform because serviceId is not exist");
        return;
    }
    NSDictionary *serviceReviewParameter =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                             @"service_id":self.serviceId,
                                          };
    
    NSString *serviceReviewlUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ShowReview];
    
    DLog(@"%s, Performing %@ Api \n with Parameter:%@",__FUNCTION__, serviceReviewlUrl, serviceReviewParameter);
    
    [serviceManager executeServiceWithURL:serviceReviewlUrl andParameters:serviceReviewParameter forTask:kTaskShowReview completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s, %@Api \n response:%@",__FUNCTION__, serviceReviewlUrl,response);

        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                self.reviewArray = [parsingManager parseResponse:response forTask:task];
                dispatch_async(dispatch_get_main_queue(), ^{
                  [self.tblViewReview reloadData];
                });
            }
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0002"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.lblNoReview.hidden = NO;
                    self.reviewArray = nil;
                    [self.tblViewReview reloadData];
                });
            }
           else if ([[dict valueForKey:@"is_blocked"] boolValue])
            {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
            }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
           }
        }
        else{
            DLog(@"%s, Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
    }];
    [self.refreshControl endRefreshing];
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
  
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.reviewArray count];
   
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    static NSString * cellId =@"cell";
    
   ViewReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [ViewReviewCell cellFromNibNamed:@"ViewReviewCell"];
        cell.delegate = self;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
    
    [cell configureCell:[self.reviewArray objectAtIndex:indexPath.row] ViewReviewLabelHeight:reviewLabelHeight andCellHeight:cellHeight];
    
       return cell;

}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return [self calculateRowHeightAtIndexPath:indexPath];
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
  ViewReview *review  = [self.reviewArray objectAtIndex:[indexPath row]];
    reviewLabelHeight = [self calculateMessageStringHeight:review.reviewText];
    rowHeight =  reviewLabelHeight + RATING_LABEL_YAXIS + BUTTON_VIEW_HEIGHT;
    rowHeight += CELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(310, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.reviewFont} context:nil];
    return textRect.size.height;
    
}

-(IBAction)backAction:(id)sender{

    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - ViewReviewCustomViewCellDelegate

-(void)editButtonPressedAtRow:(NSString*)reviewText:(NSString*)reviewRating:(NSString*)reviewId;
{
    CGRect frame = self.view.frame;
    frame.origin.y -= 120;

    
    WriteReviewView *writeReviewView = [[WriteReviewView alloc] initWithFrame:frame];
    writeReviewView.serviceId = self.serviceId;
    writeReviewView.delegate = self;
    writeReviewView.serviceReviewId = reviewId;
    writeReviewView.writeReviewTextView.text = reviewText;
    writeReviewView.parentViewController = kCallerViewReview;
    writeReviewView.reviewType = @"Update";
    [writeReviewView.BtnPostData setTitle:@"Update Review" forState:UIControlStateNormal];
    
    BOOL showHalfRating = NO;
    int rating = [reviewRating floatValue];
    writeReviewView.updateRating = rating;
    float floatRating = [reviewRating floatValue];
    
    if (ceilf(floatRating) > floorf(floatRating)) {
        showHalfRating = YES;
    }
    for(int i = 1; i <=5; i++) {
        UIButton *button = (UIButton*)[writeReviewView.writeReviewView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-normal.png"] forState:UIControlStateNormal];
    }
    
    for(int i = 1; i <=rating ; i++) {
        UIButton *button = (UIButton*)[writeReviewView.writeReviewView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"star-active.png"] forState:UIControlStateNormal];
    }
    if (showHalfRating) {
        UIButton *button = (UIButton*)[writeReviewView.writeReviewView viewWithTag: rating+1];
        [button setBackgroundImage:[UIImage imageNamed:@"star-half-selected.png"] forState:UIControlStateNormal];
    }

  [self.view addSubview:writeReviewView];

}

-(void)updateReview
{
    [self viewReview];

}

-(void)reviewDeletedFromReviewView
{
    [self viewReview];
}


@end

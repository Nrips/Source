//
//  HelpfulDetailViewController.m
//  Autism
//
//  Created by Vikrant Jain on 4/12/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "HelpfulDetailViewController.h"
#import "QACircleDetailviewCell.h"
#import "HelpfulAnswer.h"
#import "CustomLabel.h"
#import "Utility.h"
#import "ProfileShowViewController.h"


@interface HelpfulDetailViewController ()<UITableViewDataSource,UITableViewDelegate,QACircleDetailviewCellDelegate>
{
    float helpfulLabelHeight;
    float rowHeight;
    float questionLabelHeight;
    
    int tableViewHeight;
    CGRect topViewFrame;

}

@property(strong,nonatomic)NSArray *arrayGetQuestionDetails;
@property (strong, nonatomic)NSArray *arrHelpfulAnswer;
@property (weak, nonatomic) IBOutlet UIImageView *detailHeaderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *qaIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sepratorImageView;
@property (strong ,nonatomic) UIFont* helpfulFont;
@property (strong, nonatomic) IBOutlet CustomLabel *lblQuestion;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation HelpfulDetailViewController

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
    
   
    self.helpfulFont = [UIFont systemFontOfSize:13];
    [self calculateLableHight];
    
   
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(backAction:)];
    
    //self.navigationItem.rightBarButtonItem = cancelButton;
    
    if (IS_IPHONE_5) {
        
        [self.tblHelpfulView setFrame:CGRectMake(0,87,320,458)];
    }
    else{
        
        [self.tblHelpfulView setFrame:CGRectMake(0,87,320,375)];
    }
    
    
   /* if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        //TODO Apply better approch
        [self updateViewForNotificationScreen];
    }*/
    self.title = @"Helpful View";
    self.lblQuestion.text = self.strgetQuestion;
    [self questionDetail];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)calculateLableHight
{
   questionLabelHeight =[self calculateQuestionStringHeight:self.strgetQuestion];
    
     tableViewHeight = self.tblHelpfulView.frame.size.height;
    
    //DLog(@"label hight%f ",questionLabelHeight);
    
    CGRect labelFrame = self.lblQuestion.frame;
    labelFrame.size.height = questionLabelHeight;
    self.lblQuestion.frame = labelFrame;
    
    CGRect tableFrame = self.tblHelpfulView.frame;
    tableFrame.origin.y = self.lblQuestion.frame.origin.y + questionLabelHeight + 10;
    self.tblHelpfulView.frame = tableFrame;
    
    CGRect frame = self.qaIconImageView.frame;
    frame.origin.y = self.lblQuestion.frame.origin.y;
    self.qaIconImageView.frame = frame;
    
    CGRect frame1 = self.detailHeaderImageView.frame;
    frame1.size.height = questionLabelHeight +20;
    self.detailHeaderImageView.frame = frame1;
    
    
    CGRect frame2 = self.sepratorImageView.frame;
    frame2.origin.y = self.tblHelpfulView.frame.origin.y - 3;
    self.sepratorImageView.frame = frame2;
    
   
    if ([self.replyCount integerValue] == 0) {
        tableFrame.size.height = 0;
    } else {
        tableFrame.size.height = tableViewHeight;
    }
    self.tblHelpfulView.frame = tableFrame;
    
    [self.scrollView setContentSize:CGSizeMake(320, self.tblHelpfulView.frame.origin.y + self.tblHelpfulView.frame.size.height)];
   
   
}

-(IBAction)backAction:(id)sender {
    //*> Navigations Issue
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

//TODO Remove Code
-(void)updateViewForNotificationScreen
{
    CGRect frame;

    frame = self.detailHeaderImageView.frame;
    frame.origin.y -= 64;
    self.detailHeaderImageView.frame = frame;
    
    frame = self.qaIconImageView.frame;
    frame.origin.y -= 64;
    self.qaIconImageView.frame = frame;
    
    frame = self.txtViewQuestion.frame;
    frame.origin.y -= 64;
    self.txtViewQuestion.frame = frame;
    
    
    frame = self.sepratorImageView.frame;
    frame.origin.y -= 64;
    self.sepratorImageView.frame = frame;

    frame = self.tblHelpfulView.frame;
    frame.origin.y -= 64;
    self.tblHelpfulView.frame = frame;
}


//static id ObjectOrNull(id object)
//{
//    return object ? : [NSNull null];
//}

-(void)questionDetail
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }

    NSDictionary *getQuestionParameters =@{@"member_id":ObjectOrNull([userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]),
                                           @"question_id":ObjectOrNull(self.helpfulQuestionId),
                                           
                                           };
    NSString *strQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_HelpfulAnswer];
    DLog(@"%s, Performing %@ api \n with parameter :%@",__FUNCTION__,strQuestionUrl, getQuestionParameters);
    [serviceManager executeServiceWithURL:strQuestionUrl andParameters:getQuestionParameters forTask:kTaskHelpfulAnswer completionHandler:^(id response, NSError *error, TaskType task) {
       
        DLog(@"%s, %@ api \n Response :%@",__FUNCTION__,strQuestionUrl, response);
        
        if (!error) {
            self.arrayGetQuestionDetails = [parsingManager parseResponse:response forTask:task];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self calculateLableHight];
                [self.tblHelpfulView reloadData];
            });
        }
   }];
}

#pragma mark - UItablevie datasource

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrayGetQuestionDetails.count;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateRowHeightAtIndexPath:indexPath];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    QACircleDetailviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [QACircleDetailviewCell cellFromNibNamed:@"QACircleDetailviewCell"];
     }
    float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
    cell.delegate = self;
    [cell configureHelpfulCell:[self.arrayGetQuestionDetails objectAtIndex:indexPath.row] detailLabelHeight:helpfulLabelHeight andCellHeight:cellHeight];
    
    return cell;
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    HelpfulAnswer* helpful= [self.arrayGetQuestionDetails objectAtIndex:[indexPath row]];
    helpfulLabelHeight = [self calculateMessageStringHeight:helpful.answer];
    rowHeight =  helpfulLabelHeight + MESSAGE_DETAIL_LABEL_YAXIS;
    rowHeight += CELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(238, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.helpfulFont} context:nil];
    return textRect.size.height;
    
}

-(float)calculateQuestionStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(284, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.helpfulFont} context:nil];
    return textRect.size.height;
    
}

- (void)clickOnHashTagForHelpful:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(HelpfulAnswer *)question
{
    if ([hashType isEqualToString:kHotWordHashtag] && [Utility getValidString:hotWorldID].length > 0) {
        [self showMemberProfile:hotWorldID];
    }
}

- (void)showMemberProfile:(NSString*)memeberID {
    DLog(@"%s",__FUNCTION__);
    
    ProfileShowViewController *profileVC = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
    profileVC.otherUserId = memeberID;
    if (![memeberID isEqualToString:[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]])
        profileVC.profileType =  kProfileTypeOther;
        profileVC.parentViewControllerName = kCallerViewHelpful;
    //[[appDelegate rootNavigationController] pushViewController:profileVC animated:YES];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)clickOnMemeberName:(NSString*)memeberID {
    if ([Utility getValidString:memeberID].length > 0) {
        [self showMemberProfile:memeberID];
        
        DLog(@"memberid data %@",memeberID);
    }
}


@end

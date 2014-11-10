//
//  ReplyDetailViewController.m
//  Autism
//
//  Created by Vikrant Jain on 4/10/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ReplyDetailViewController.h"
#import "QACircleDetailviewCell.h"
#import "CommentView.h"
#import "CustomLabel.h"
#import "Utility.h"
#import "ProfileShowViewController.h"

@interface ReplyDetailViewController ()<UITableViewDelegate,UITableViewDataSource,QACircleDetailviewCellDelegate>
{
    BOOL isSelected;
    float replyLabelHeight;
    float rowHeight;
    float questionLabelHeight;
    
    int tableViewHeight;
    CGRect topViewFrame;
}

@property (weak, nonatomic) IBOutlet UIImageView *detailHeaderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *qaIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sepratorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


@property(strong,nonatomic)NSArray *arrayGetQuestionDetails;
@property (strong, nonatomic)NSArray *arrHelpfulAnswer;
@property (nonatomic, strong)UIRefreshControl *refreshControl;
@property (strong ,nonatomic)UIFont* replyFont;
@property (strong ,nonatomic)UIFont* questionFont;

@end


@implementation ReplyDetailViewController

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
    self.questionFont = [UIFont systemFontOfSize:13];
    [self calculateLableHight];
    /* if ([self.parentViewControllerName isEqualToString:kTitleNotifications]) {
        //TODO Apply better approch
        [self updateViewForNotificationScreen];
    }*/
    
    if (IS_IPHONE_5)
    {
        
        [self.tblReplyView setFrame:CGRectMake(0,87,320,465)];
    }
    else
    {
        
        [self.tblReplyView setFrame:CGRectMake(0,87,320,375)];
    }

    
    
    DLog(@"reply count value %@",self.replyCount);
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(backAction:)];
    
   //self.navigationItem.rightBarButtonItem = cancelButton;
    
   self.replyFont = [UIFont systemFontOfSize:13.6];
    [self questionDetail];
    self.title = @"Reply View";
    self.lblQuestion.text = self.strgetQuestion;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    [self.refreshControl addTarget:self action:@selector(questionDetail) forControlEvents:UIControlEventValueChanged];
    [self.tblReplyView addSubview:self.refreshControl];
    
}

-(void)calculateLableHight
{
    questionLabelHeight =[self calculateQuestionStringHeight:self.strgetQuestion];
     tableViewHeight = self.tblReplyView.frame.size.height;
   // DLog(@"label hight%f ",questionLabelHeight);
    
     CGRect labelFrame = self.lblQuestion.frame;
     labelFrame.size.height = questionLabelHeight + 5;
     self.lblQuestion.frame = labelFrame;
    
    CGRect tableFrame = self.tblReplyView.frame;
    tableFrame.origin.y = self.lblQuestion.frame.origin.y + questionLabelHeight + 10;
    self.tblReplyView.frame = tableFrame;
    
    CGRect frame = self.qaIconImageView.frame;
    frame.origin.y = self.lblQuestion.frame.origin.y;
    self.qaIconImageView.frame = frame;
    
    CGRect frame1 = self.detailHeaderImageView.frame;
    frame1.size.height = questionLabelHeight +20;
    self.detailHeaderImageView.frame = frame1;
    
    CGRect frame2 = self.detailImageView.frame;
    frame2.size.height = questionLabelHeight;
    self.detailImageView.frame = frame2;
    
    CGRect frame3 = self.sepratorImageView.frame;
    frame3.origin.y = self.detailImageView.frame.origin.y + frame2.size.height;
    self.sepratorImageView.frame = frame3;
    
    if ([self.replyCount integerValue] == 0) {
        tableFrame.size.height = 0;
    } else {
        tableFrame.size.height = tableViewHeight;
    }
    self.tblReplyView.frame = tableFrame;
    
    [self.scrollView setContentSize:CGSizeMake(320, self.tblReplyView.frame.origin.y + self.tblReplyView.frame.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
     //*> Navigations Issue
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)updateViewForNotificationScreen
{
    CGRect frame;
    
    frame = self.detailHeaderImageView.frame;
    frame.origin.y -= 64;
    self.detailHeaderImageView.frame = frame;
    
    frame = self.qaIconImageView.frame;
    frame.origin.y -= 64;
    self.qaIconImageView.frame = frame;
    
    frame = self.lblQuestion.frame;          frame.origin.y -= 64;
    self.lblQuestion.frame = frame;
    
    
    frame = self.sepratorImageView.frame;
    frame.origin.y -= 64;
    self.sepratorImageView.frame = frame;
    
    frame = self.tblReplyView.frame;
    frame.origin.y -= 64;
    self.tblReplyView.frame = frame;
}

-(void)questionDetail
{
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
NSDictionary *getQuestionParameters =@{@"member_id":[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                       @"question_id":self.replyQuestionId,
                                     };

    DLog(@"dictionary reply %@",getQuestionParameters);
   
    NSString *strQuestionUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ReplyQuestion];
    
    [serviceManager executeServiceWithURL:strQuestionUrl andParameters:getQuestionParameters forTask:kTaskReplyQuestion completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s, %@ api \n Response :%@",__FUNCTION__,strQuestionUrl, response);
        
        if (!error) {
            
            self.arrayGetQuestionDetails = [parsingManager parseResponse:response forTask:task];
            
            dispatch_async(dispatch_get_main_queue(), ^{
           
                if (self.arrayGetQuestionDetails == nil || [self.arrayGetQuestionDetails count] == 0) {
                    
                    DLog(@"array is empty");
                }
                else {
                DLog(@"data %@",self.arrayGetQuestionDetails);
                }
                [self calculateLableHight];
                [self.tblReplyView reloadData];
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

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    QACircleDetailviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [QACircleDetailviewCell cellFromNibNamed:@"QACircleDetailviewCell"];
        
    }
     float cellHeight = [self calculateRowHeightAtIndexPath:indexPath];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     cell.delegate = self;
     [cell configureCell:[self.arrayGetQuestionDetails objectAtIndex:indexPath.row] detailLabelHeight:replyLabelHeight andCellHeight:cellHeight];

    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateRowHeightAtIndexPath:indexPath];
   
}

-(float)calculateRowHeightAtIndexPath: (NSIndexPath *)indexPath{
    ReplyQuestion* reply= [self.arrayGetQuestionDetails objectAtIndex:[indexPath row]];
    
    replyLabelHeight = [self calculateMessageStringHeight:reply.answer];
    
    rowHeight =  replyLabelHeight + MESSAGE_DETAIL_LABEL_YAXIS + 5;
    rowHeight += CELL_CONTENT_MARGIN;
    
    return rowHeight;
}

-(float)calculateMessageStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(238, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.replyFont} context:nil];
     return textRect.size.height;
    
}
                 
-(float)calculateQuestionStringHeight:(NSString *)answer
{
    CGRect textRect = [answer boundingRectWithSize: CGSizeMake(279, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.questionFont} context:nil];
    return textRect.size.height;
    
}


- (void)clickOnHashTag:(NSString*)hotWorldID hashType:(NSString *)hashType forQA:(ReplyQuestion *)question
{
    if ([hashType isEqualToString:kHotWordHashtag] && [Utility getValidString:hotWorldID].length > 0) {
        
        DLog(@"hot word id %@",hotWorldID);

        [self showMemberProfile:hotWorldID];
        
        
    }
}

- (void)showMemberProfile:(NSString*)memeberID {
    DLog(@"%s",__FUNCTION__);
    
    ProfileShowViewController *profileVC = [[ProfileShowViewController alloc] initWithNibName:@"ProfileShowViewController" bundle:nil];
    profileVC.otherUserId = memeberID;
    if (![memeberID isEqualToString:[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID]])
        profileVC.profileType =  kProfileTypeOther;
    profileVC.parentViewControllerName = kCallerViewReply;    //[[appDelegate rootNavigationController] pushViewController:profileVC animated:YES];
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)clickOnMemeberName:(NSString*)memeberID {
    if ([Utility getValidString:memeberID].length > 0) {
        [self showMemberProfile:memeberID];
        
        DLog(@"memberid data %@",memeberID);
    }
}



@end

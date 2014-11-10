//
//  ReportToAWMView.m
//  Autism
//
//  Created by Deepak on 12/05/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ReportToAWMView.h"
#import "UIPlaceHolderTextView.h"
#import "Utility.h"

@interface ReportToAWMView()

@property (weak, nonatomic) IBOutlet UIView *reportToAWMView;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *reportToAWMTextView;
- (IBAction)reportToAWMButtonPressed:(id)sender;

@end

@implementation ReportToAWMView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = frame;
        self.reportToAWMTextView.placeholder = @"Please give as much detail as possible to help us deal with this issue.";
        
        self.reportToAWMView.layer.borderColor = [UIColor grayColor].CGColor;
        self.reportToAWMView.layer.borderWidth = 2.0f;
        self.reportToAWMTextView.layer.borderColor = [UIColor colorWithRed:0/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f].CGColor;
        self.reportToAWMTextView.layer.borderWidth = 1.0f;
        self.reportToAWMView.layer.cornerRadius = 5;
        self.reportToAWMView.layer.masksToBounds = YES;
    }
    return self;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//
- (IBAction)reportToAWMButtonPressed:(id)sender {
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (self.reportToAWMType == ReportToAWMTypeQuestion) {
        [self reportToAWMApiCallForQuestions];
    } else if (self.reportToAWMType == ReportToAWMTypeQuestionReplies) {
        [ self reportToAWMApiCallForQuestionsReplies];
    }else if (self.reportToAWMType == ReportToAWMTypeReportActivity) {
        [ self reportToAWMApiCallForReportActivity];
    }else if (self.reportToAWMType == ReportToAWMTypeFamily) {
        [self reportToAWMApiCallForFamily];
    }else if (self.reportToAWMType == ReportToAWMTypeStory) {
        [self reportToAWMApiCallForStory];
    }else if (self.reportToAWMType == ReportToAWMTypeInboxMember) {
        [self reportToAWMApiCallForInboxMember];
    }else if (self.reportToAWMType == ReportToAWMTypeReportEvent) {
        [self reportToAWMApiCallForEvent];
    }
    else if (self.reportToAWMType == ReportToAWMTypeReportService) {
        
        [self reportToAWMApiCallForService];
    }
}

- (void)reportToAWMApiCallForInboxMember
{
    if (![Utility getValidString:self.selectedQuestionId]) {
        DLog(@"Inbox member id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message." withTitle:@"Report Message is blank."];
        return;
    }
    NSDictionary *inboxMemberToAWMParameters = @{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                        @"inbox_member_id" : [Utility getValidString:self.selectedQuestionId],
                                                        @"reason" : self.reportToAWMTextView.text
                                                        };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_InboxMemberReportToAWM];
    DLog(@"%s, Performing %@ api \n with parameter:%@",__FUNCTION__,reportToAWMUrl, inboxMemberToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:inboxMemberToAWMParameters forTask:kTaskReportToAWMReportFamilyMember completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, %@ api \n Response:%@",__FUNCTION__,reportToAWMUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];
        
    }];
}

- (void)reportToAWMApiCallForStory
{
    if (![Utility getValidString:self.selectedQuestionId]) {
        DLog(@"Other member id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message" withTitle:@"Report Message is blank."];
        return;
    }
    NSDictionary *reportFamilyMemberToAWMParameters = @{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                        @"other_member_id" : [Utility getValidString:self.selectedQuestionId],
                                                        @"reason" : self.reportToAWMTextView.text
                                                        };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ReportStoryReportToAWM];
    DLog(@"%s, Performing %@ api \n with parameter:%@",__FUNCTION__,reportToAWMUrl, reportFamilyMemberToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:reportFamilyMemberToAWMParameters forTask:kTaskReportToAWMReportFamilyMember completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s, %@ api \n Response:%@",__FUNCTION__,reportToAWMUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];
        
    }];
}

- (void)reportToAWMApiCallForFamily
{
    if (![Utility getValidString:self.selectedQuestionId]) {
        DLog(@"kid id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message." withTitle:@"Report Message is blank."];
        return;
    }
    NSDictionary *reportFamilyMemberToAWMParameters = @{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"kid_id" : [Utility getValidString:self.selectedQuestionId],
                                                   @"reason" : self.reportToAWMTextView.text
                                                   };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ReportFamilyMemberReportToAWM];
    DLog(@"%s, Performing %@ api \n with parameter:%@",__FUNCTION__,reportToAWMUrl, reportFamilyMemberToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:reportFamilyMemberToAWMParameters forTask:kTaskReportToAWMReportFamilyMember completionHandler:^(id response, NSError *error, TaskType task) {
     DLog(@"%s, %@ api \n Response:%@",__FUNCTION__,reportToAWMUrl,response);
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];
        
    }];
}



- (void)reportToAWMApiCallForQuestions
{
    if (!self.selectedQuestionId) {
        DLog(@"Question id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message." withTitle:@"Report Message is blank."];
        return;
    }
    NSDictionary *questionReportToAWMParameters =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"question_id" : self.selectedQuestionId,
                                                   @"reason" : self.reportToAWMTextView.text
                                                   };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_QuestionReportToAWM];
    DLog(@"Performing QuestionReportToAWM api with parameter:%@",questionReportToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:questionReportToAWMParameters forTask:kTaskQuestionReportToAWMForQuestions completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"QuestionReportToAWM api response :%@",response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];

    }];
}

- (void)reportToAWMApiCallForQuestionsReplies
{
    if (!self.selectedQuestionId) {
        DLog(@"Question id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message." withTitle:@"Report Message is blank."];
        return;
    }
    
    NSDictionary *questionReportToAWMParameters =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"question_answer_id" : self.selectedQuestionId,
                                                   @"reason" : self.reportToAWMTextView.text
                                                   };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_QuestionAnswerReportToAWM];
    DLog(@"Performing %@ api \n with parameter:%@",reportToAWMUrl, questionReportToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:questionReportToAWMParameters forTask:kTaskQuestionReportToAWMForQuestionsReplies completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%@ api \n response :%@",reportToAWMUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            }
            else if ([[dict valueForKey:@"already_reported"] boolValue]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];
        
    }];
}


- (void)reportToAWMApiCallForReportActivity
{
    if (!self.selectedQuestionId) {
        DLog(@"Question id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message." withTitle:@"Report Message is blank."];
        return;
    }
    
    NSDictionary *questionReportToAWMParameters =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"activity_id" : self.selectedQuestionId,
                                                   @"activity_report_reason" : self.reportToAWMTextView.text
                                                   };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_ReportActivityReportToAWM];
    DLog(@"Performing %@ api \n with parameter:%@",reportToAWMUrl, questionReportToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:questionReportToAWMParameters forTask:kTaskQuestionReportToAWMForReportActivity completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%@ api \n response :%@",reportToAWMUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            }else if ([[dict valueForKey:@"already_reported"] boolValue]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];
        
    }];
}

- (void)reportToAWMApiCallForEvent
{
 
    if (!self.selectedQuestionId) {
        DLog(@"Question id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message." withTitle:@"Report Message is blank."];
        return;
    }
    
    NSDictionary *questionReportToAWMParameters =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"event_id" : self.selectedQuestionId,
                                                   @"reason" : self.reportToAWMTextView.text
                                                   };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_EventReportToAWM];
    DLog(@"Performing %@ api \n with parameter:%@",reportToAWMUrl, questionReportToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:questionReportToAWMParameters forTask:kTaskEventReportToAWM completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%@ api \n response :%@",reportToAWMUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            }else if ([[dict valueForKey:@"already_reported"] boolValue]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];
        
    }];
}

- (void)reportToAWMApiCallForService
{
    
    if (!self.selectedQuestionId) {
        DLog(@"Question id is not exist");
        return;
    }
    
    if ([Utility getValidString:self.reportToAWMTextView.text].length < 1) {
        [Utility showAlertMessage:@"You cannot report with blank message." withTitle:@"Report Message is blank."];
        return;
    }
    
    NSDictionary *questionReportToAWMParameters =@{@"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"service_id" : self.selectedQuestionId,
                                                   @"reason" : self.reportToAWMTextView.text
                                                   };
    
    NSString *reportToAWMUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_ServiceDetailReportToAWM
                                ];
    DLog(@"Performing %@ api \n with parameter:%@",reportToAWMUrl, questionReportToAWMParameters);
    [serviceManager executeServiceWithURL:reportToAWMUrl andParameters:questionReportToAWMParameters forTask:kTaskEventReportToAWM completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%@ api \n response :%@",reportToAWMUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
                if ([self.delegate respondsToSelector:@selector(reportToAWMVDSuccessfullySubmitted)]) {
                    [self.delegate reportToAWMVDSuccessfullySubmitted];
                }
            }else if ([[dict valueForKey:@"already_reported"] boolValue]) {
                [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Reported to AWM."];
            }
            else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            } else {
                [Utility showAlertMessage:@"" withTitle:@"Reporting to AWM Failed."];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        [self removeFromSuperview];
        
    }];
}

@end

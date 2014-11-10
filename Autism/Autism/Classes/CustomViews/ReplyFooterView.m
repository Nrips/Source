//
//  ReplyFooterView.m
//  Autism
//
//  Created by Dipak on 5/8/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "ReplyFooterView.h"
#import "Utility.h"

@implementation ReplyFooterView


- (void)resetImage
{
    //self.footerImageView = nil;
    self.footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];

    [self.footerImageView setImage:[UIImage imageNamed:@"comment-box.png"]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)replySubmitButtonPressed:(id)sender
{
    [self.replyText resignFirstResponder];
    
    if([self.delegate respondsToSelector:@selector(replySubmitButtonPressedAtRow:)])
        [self.delegate replySubmitButtonPressedAtRow:self.tag];
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (self.commentType == CommentTypeReplyOnQuestion) {
        [self replyOnQuestiuon];

    } else if (self.commentType == CommentTypeActivity)
    {
        [self commentOnActivity];
    }
    
}

-(void)replyOnQuestiuon {
    
    if (!self.questionID) {
        DLog(@"Question id not exist");
        return;
    }
    
    else if ([self.replyText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 1)
    {
        //TODO ask for message.
        [Utility showAlertMessage:@"You could not post with blank message." withTitle:@"Reply message is blank."];
        return;
    }
    DLog(@"self.relpySubmitButton.tag:%ld", (long)self.relpySubmitButton.tag);
    NSDictionary *postQuestionCommentParameters = @{@"member_id" :[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                    @"question_id" : self.questionID,
                                                    @"comment": self.replyText.text,
                                                    };
    
    NSString *strSignUpUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_PostQuestionComment];
    DLog(@"Performing PostQuestionComment with parameter:%@",postQuestionCommentParameters);
    
    [serviceManager executeServiceWithURL:strSignUpUrl andParameters:postQuestionCommentParameters forTask:kTaskPostQuestionComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"PostQuestionComment api response :%@",response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                DLog(@"PostQuestionComment api Sucessful.");
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];

}

-(void)commentOnActivity {
    
    if (!self.activityCommentId) {
        DLog(@"Question id not exist");
        return;
    }
    
    else if ([self.replyText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 1)
    {
        //TODO ask for message.
        [Utility showAlertMessage:@"You could not post with blank comment." withTitle:@"Comment is blank."];
        return;
    }
    DLog(@"self.relpySubmitButton.tag:%ld",(long)self.relpySubmitButton.tag);
    NSDictionary *postQuestionCommentParameters = @{@"member_id" :[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                    @"activity_comment_id" : self.activityCommentId,
                                                    @"activity_comment_report_reason": self.replyText.text,
                                                    };
    
    NSString *commentOnActivityUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_ReportActivityComment];
    DLog(@"Performing %@ api \n with parameter:%@",commentOnActivityUrl,postQuestionCommentParameters);
    
    [serviceManager executeServiceWithURL:commentOnActivityUrl andParameters:postQuestionCommentParameters forTask:kTaskReportActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%@ api \n with response :%@",commentOnActivityUrl, response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                DLog(@"PostQuestionComment api Sucessful.");
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];
}

@end

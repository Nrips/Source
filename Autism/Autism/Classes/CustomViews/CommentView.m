//
//  CommentView.m
//  Autism
//
//  Created by Dipak on 5/23/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "CommentView.h"
#import "Utility.h"

@interface CommentView()

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;
@end

@implementation CommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = frame;
        self.commentView.layer.borderColor = [UIColor grayColor].CGColor;
        self.commentView.layer.borderWidth = 2.0f;
        self.commentTextView.layer.borderColor = [UIColor colorWithRed:0/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f].CGColor;
        self.commentTextView.layer.borderWidth = 1.0f;
        
        self.commentView.layer.cornerRadius = 5;
        self.commentView.layer.masksToBounds = YES;

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

- (IBAction)cancelButtonPressed:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)submitButtonPressed:(id)sender {
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (self.commentType == CommentTypeReplyOnQuestion) {
        [self replyOnQuestiuon];
        
    } else if (self.commentType == CommentTypeActivity)
    {
        [self postCommentUpdateApiCall];
    }else if (self.commentType == CommentTypeProfile)
    {
        [self postCommentUpdateApiCall];
    }
    [self removeFromSuperview];
}

-(void)replyOnQuestiuon {
    if (![appDelegate isNetworkAvailable]) {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.questionID) {
        DLog(@"Question id not exist");
        return;
    }
    
    else if ([Utility getValidString:self.commentTextView.text].length < 1)
    {
        //TODO ask for message.
        [Utility showAlertMessage:@"You could not post with blank message." withTitle:@"Reply message is blank."];
        return;
    }
    NSDictionary *postQuestionCommentParameters = @{@"member_id" :[userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                    @"question_id" : self.questionID,
                                                    @"comment": self.commentTextView.text,
                                                    };
    
    NSString *strSignUpUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_PostQuestionComment];
    DLog(@"%s %@ api \n with parameter:%@",__FUNCTION__,strSignUpUrl,postQuestionCommentParameters);
    
    [serviceManager executeServiceWithURL:strSignUpUrl andParameters:postQuestionCommentParameters forTask:kTaskPostQuestionComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api response :%@",__FUNCTION__,strSignUpUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"responce_code"] isEqualToString:@"RC0000"]) {
                
                if ([self.delegate respondsToSelector:@selector(commentSuccessfullySubmitted)])
                {
                    [self.delegate commentSuccessfullySubmitted];
                }

            } else if ([[dict valueForKey:@"responce_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];
    
}



- (void)postCommentUpdateApiCall
{
    if (![appDelegate isNetworkAvailable]) {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (!self.selectedActivityId) {
        DLog(@"Activity id does not exist");
        return;
    }
    
    if ([Utility getValidString:self.commentTextView.text].length < 1) {
        [Utility showAlertMessage:@"You comment with blank message." withTitle:@"Comment is black."];
        return;
    }
    
    NSDictionary *activityCommentParameters =@{    @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"activity_id" : self.selectedActivityId,
                                                   @"comment_text" : self.commentTextView.text
                                                   };
    
    NSString *activityCommentUrl = [NSString stringWithFormat:@"%@%@",BASE_URL, Web_URL_ActivityComment];
    DLog(@"%s Performing %@ api \n with parameter:%@",__FUNCTION__,activityCommentUrl, activityCommentParameters);
    [serviceManager executeServiceWithURL:activityCommentUrl andParameters:activityCommentParameters forTask:kTaskActivityComment completionHandler:^(id response, NSError *error, TaskType task) {
        DLog(@"%s %@ api \n response :%@",__FUNCTION__,activityCommentUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(commentSuccessfullySubmitted)]) {
                    [self.delegate commentSuccessfullySubmitted];
                }
            } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                [appDelegate userAutismSessionExpire];
            }
        } else
        {
            DLog(@"%s Error:%@",__FUNCTION__,error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        
    }];
}

@end

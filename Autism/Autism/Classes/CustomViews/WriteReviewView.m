//
//  WriteReviewView.m
//  Autism
//
//  Created by Dipak on 5/31/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "WriteReviewView.h"
#import "UIPlaceHolderTextView.h"
#import "Utility.h"
#import "ViewReviewViewController.h"

@interface WriteReviewView()
{
    long rating;
}

- (IBAction)canceButtonPressed:(id)sender;
- (IBAction)reviewSubmitButtonPressed:(id)sender;
- (IBAction)starButtonPressed:(id)sender;

@end


@implementation WriteReviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.writeReviewTextView.delegate = self;
        
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = frame;
        self.writeReviewTextView.placeholder = @"Enter your message here.";
        
        self.writeReviewView.layer.borderColor = [UIColor grayColor].CGColor;
        self.writeReviewView.layer.borderWidth = 2.0f;
        self.writeReviewTextView.layer.borderColor = [UIColor colorWithRed:0/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f].CGColor;
        self.writeReviewTextView.layer.borderWidth = 1.0f;
        
        self.writeReviewView.layer.cornerRadius = 5;
        self.writeReviewView.layer.masksToBounds = YES;
        
        rating = 0;
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

- (IBAction)canceButtonPressed:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)reviewSubmitButtonPressed:(id)sender {

    if ([self.reviewType isEqualToString:kUpdateReview]) {
        [self updateReview];
    }else {
        [self reviewSubmit];
    }


}

- (void)reviewSubmit{
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    if (!self.serviceId)
    {
        DLog(@"%@ api call not perform because serviceId is not exist",Web_URL_WriteReview);
        return;
    }
    if (![Utility getValidString:self.writeReviewTextView.text].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Review cannot be blank."];
        return;
    }
    if (!rating)
    {
        [Utility showAlertMessage:@"" withTitle:@"Rating cannot be blank."];
        return;
    }
    NSDictionary *serviceWriteReviewParameter =@{  @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"service_id": self.serviceId,
                                                   @"rating" : [NSString stringWithFormat:@"%ld",rating],
                                                   @"service_review_text": self.writeReviewTextView.text
                                                   };
    
    NSString *serviceWriteReviewlUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_WriteReview];
    
    DLog(@"%s Performing %@ Api with Parameter:%@",__FUNCTION__, serviceWriteReviewlUrl, serviceWriteReviewParameter);
    
    [serviceManager executeServiceWithURL:serviceWriteReviewlUrl andParameters:serviceWriteReviewParameter forTask:kTaskWriteReview completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s,  %@ Api Response:%@",__FUNCTION__, serviceWriteReviewlUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                [Utility showAlertMessage:@"Thank you for writing a review for this service." withTitle:@"Thank you!"];
                
                if ([self.delegate respondsToSelector:@selector(reviewSubmittedSuccessfully)]) {
                    [self.delegate reviewSubmittedSuccessfully];
                }
            }
            else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
                
            }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
                [appDelegate userAutismSessionExpire];
            }
        }
        else{
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }];
}

- (IBAction)starButtonPressed:(id)sender
{
    rating = ((UIButton*)sender).tag;
    for(int i = 1; i <=5 ; i++) {
        UIButton *button = (UIButton*)[self.writeReviewView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"big-star-normal.png"] forState:UIControlStateNormal];
    }
    
    for(int i = 1; i <=rating ; i++) {
        UIButton *button = (UIButton*)[self.writeReviewView viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"big-star-active.png"] forState:UIControlStateNormal];
    }
}


-(void)updateReview {
    
    if (![appDelegate isNetworkAvailable])
    {
        [Utility showNetWorkAlert];
        return;
    }
    
    if (rating == 0) {
        
        rating = self.updateRating;
    }
    
    if (!self.serviceReviewId)
    {
        DLog(@"%@ api call not perform because serviceId is not exist",Web_URL_WriteReview);
        return;
    }
    if (![Utility getValidString:self.writeReviewTextView.text].length > 0)
    {
        [Utility showAlertMessage:@"" withTitle:@"Review cannot be blank."];
        return;
    }
    if (!rating)
    {
        [Utility showAlertMessage:@"" withTitle:@"Rating cannot be blank."];
        return;
    }
    NSDictionary *serviceUpdateReviewParameter =@{ @"member_id": [userDefaults stringForKey:KEY_USER_DEFAULTS_USER_ID],
                                                   @"service_review_id": self.serviceReviewId,
                                                   @"rating" : [NSString stringWithFormat:@"%ld",rating],
                                                   @"service_review_text": self.writeReviewTextView.text
                                                   };
    
    NSString *serviceUpdateReviewlUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,Web_URL_EditReview];
    
    DLog(@"%s Performing %@ Api with Parameter:%@",__FUNCTION__, serviceUpdateReviewlUrl, serviceUpdateReviewParameter);
    
    [serviceManager executeServiceWithURL:serviceUpdateReviewlUrl andParameters:serviceUpdateReviewParameter forTask:kTaskEditReview completionHandler:^(id response, NSError *error, TaskType task) {
        
        DLog(@"%s,  %@ Api Response:%@",__FUNCTION__, serviceUpdateReviewlUrl,response);
        
        if (!error && response) {
            NSDictionary *dict = [[NSDictionary alloc]init];
            dict = (NSDictionary *)response;
            if ([[dict objectForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                if ([self.delegate respondsToSelector:@selector(updateReview)]) {
                    [self.delegate updateReview];
                }

                [Utility showAlertMessage:@"Update Review successfully." withTitle:@"Message!"];
                
             }
            else if ([[dict valueForKey:@"is_blocked"] boolValue]) {
                [Utility showAlertMessage:@"" withTitle:kAlertMessageUnblockUser];
                
            }else if([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]){
                [appDelegate userAutismSessionExpire];
            }
        }
        else{
            DLog(@"Error:%@",error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    textView.backgroundColor = [UIColor whiteColor];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //[self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    textView.backgroundColor = [UIColor whiteColor];
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end

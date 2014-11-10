//
//  ProgressView.m
//  Autism
//
//  Created by Dipak on 6/21/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "UploadingProgressView.h"
#import "ServiceManager.h"

@interface UploadingProgressView ()
@property (weak, nonatomic) IBOutlet UIProgressView *postUpdateProgressBar;
@property (weak, nonatomic) IBOutlet UIButton *requestCancelButtonPressed;
- (IBAction)requestCancelButtonPressed:(id)sender;

@end

@implementation UploadingProgressView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = frame;
        self.postUpdateProgressBar.progress = 0.0f;
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

- (void)updateProgressBar:(float)progress
{
    //DLog(@"%s,Uploading progress:%f",__FUNCTION__,progress);
    if (progress >= 0 && progress <= 1)  {
        dispatch_async(dispatch_get_main_queue(), ^{
                self.postUpdateProgressBar.progress = progress;
        });
    }
}

- (IBAction)requestCancelButtonPressed:(id)sender {
    
    if ((serviceManager.postUploadTask.state == NSURLSessionTaskStateRunning) && [self.callerView isEqualToString:kPostUpdateTypePostUpdate])
    {
        DLog(@"postUploadTask canceled!!!");
        [serviceManager.postUploadTask cancel];
    } else if((serviceManager.postUploadMyTask.state == NSURLSessionTaskStateRunning) && [self.callerView isEqualToString:kPostUpdateTypePostUpdateMy]) {
        DLog(@"postUploadMyTask canceled!!!");
        [serviceManager.postUploadMyTask cancel];
    } else if((serviceManager.postUploadOtherTask.state == NSURLSessionTaskStateRunning) && [self.callerView isEqualToString:kPostUpdateTypePostUpdateOther]) {
        DLog(@"postUploadOtherTask canceled!!!");

        [serviceManager.postUploadOtherTask cancel];
    } else if((serviceManager.postUploadInboxMessageTask.state == NSURLSessionTaskStateRunning)  && [self.callerView isEqualToString:kPostUpdateTypeSendMessage]) {
        DLog(@"postUploadInboxMessageTask canceled!!!");

        [serviceManager.postUploadInboxMessageTask cancel];
    }
    else if((serviceManager.postUploadInboxMessageTask.state == NSURLSessionTaskStateRunning)  && [self.callerView isEqualToString:kPostUpdateTypeSendDetailMessage]) {
        DLog(@"postUploadInboxMessageTask canceled!!!");
        
        [serviceManager.postUploadInboxMessageTask cancel];
    }
    self.postUpdateProgressBar.progress = 0.0f;
    [self removeFromSuperview];
}

@end
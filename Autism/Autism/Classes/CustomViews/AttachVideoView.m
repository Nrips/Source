//
//  AttachVideoView.m
//  Autism
//
//  Created by Dipak on 5/17/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "AttachVideoView.h"
#import "CustomTextField.h"
#import "Utility.h"

@interface AttachVideoView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *attachVideoButton;
@property (nonatomic,weak) IBOutlet UITextField *videoUrlTextField;
@property (weak, nonatomic) IBOutlet UILabel *videoUrlLabel;
@property (strong , nonatomic) NSString *videoUrl;
@property (strong , nonatomic) NSString *visibleVideoUrl;

- (IBAction)attachVideoButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)enterVideoButtonPressed:(id)sender;

@end

@implementation AttachVideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.videoUrlTextField.delegate = self;
        self.frame = frame;
        DLog(@"self.frame:%@",NSStringFromCGRect(self.frame));
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

- (IBAction)attachVideoButtonPressed:(id)sender {
    if ([self.videoUrlTextField isFirstResponder]) {
        [self.videoUrlTextField resignFirstResponder];
    }

    if ([self.delegate respondsToSelector:@selector(attachedVideoUrl:visibleUrl:)]) {
        DLog(@"Video url:%@",self.videoUrl);
        [self.delegate attachedVideoUrl:self.videoUrl visibleUrl:self.visibleVideoUrl];
    }
    [self removeFromSuperview];
}

- (IBAction)cancelButtonPressed:(id)sender {
    if ([self.videoUrlTextField isFirstResponder]) {
        [self.videoUrlTextField resignFirstResponder];
    }
    [self removeFromSuperview];
}

- (IBAction)enterVideoButtonPressed:(id)sender

{
    if ([self.videoUrlTextField isFirstResponder]) {
        [self.videoUrlTextField resignFirstResponder];
    }
    NSString *urlString = [Utility getValidString:self.videoUrlTextField.text];
    self.videoUrl = urlString;
    
    if (!([self.videoUrl hasPrefix:@"http://"] || [self.videoUrl hasPrefix:@"https://"])) {
        
        self.videoUrl = [NSString stringWithFormat:@"http://%@",self.videoUrl];
    }
    if (![Utility isValidateUrl:self.videoUrl]) {
        
        [Utility showAlertMessage:@"Please enter valid url." withTitle:@"Invalid url"];
        return;
    }
    
    DLog(@"videoUrl:%@",self.videoUrl);
    self.videoUrlLabel.hidden = NO;
    self.attachVideoButton.hidden = NO;
    self.videoUrlLabel.text = urlString;
    self.visibleVideoUrl = urlString;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.videoUrlTextField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}


@end

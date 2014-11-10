//
//  CustomAttachLink.m
//  Autism
//
//  Created by Neuron-iPhone on 5/17/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "AttachLinkView.h"
#import "CustomTextField.h"
#import "MyImageView.h"
#import "Utility.h"


@interface AttachLinkView () <UITextFieldDelegate>
{
    long selectedImageIndex;
}
@property (strong,nonatomic) NSArray *imageArray;
@property (weak, nonatomic) IBOutlet UIButton *selectImageButton;
@property (nonatomic,weak) IBOutlet UITextField *attachLinkUrlTextField;
@property (weak, nonatomic) IBOutlet UILabel *videoUrlLabel;
@property (strong, nonatomic) IBOutlet MyImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;

@property(strong,nonatomic) NSString *selectedImageUrl;
@property (strong , nonatomic) NSString *enteredAttacedLinkUrl;
@property (strong , nonatomic) NSString *visibleAttacedLinkUrl;

- (IBAction)selectImageButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)enterAttachLinkUrlButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)previousButtonPressed:(id)sender;

@end

@implementation AttachLinkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.attachLinkUrlTextField.delegate = self;
        self.frame = frame;
        selectedImageIndex = 0;
        self.selectedImageUrl = @"";
        self.selectedImageView.layer.cornerRadius = 4;
        [self.selectedImageView.layer setBorderColor:[[UIColor colorWithRed:196/255.0f green:196/255.0f blue:196/255.0f alpha:1.0f] CGColor]];
        [self.selectedImageView.layer setBorderWidth: 2.0];

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

- (IBAction)selectImageButtonPressed:(id)sender {
    if ([self.attachLinkUrlTextField isFirstResponder]) {
        [self.attachLinkUrlTextField resignFirstResponder];
    }

    if ([self.delegate respondsToSelector:@selector(attachedImageUrl:withVisibleUrl:)]) {
        [self.delegate attachedImageUrl:self.selectedImageUrl withVisibleUrl:self.visibleAttacedLinkUrl];
    }
    [self removeFromSuperview];
}

- (IBAction)cancelButtonPressed:(id)sender {
    if ([self.attachLinkUrlTextField isFirstResponder]) {
        [self.attachLinkUrlTextField resignFirstResponder];
    }

    [self removeFromSuperview];
}

- (IBAction)enterAttachLinkUrlButtonPressed:(id)sender
{
    if ([self.attachLinkUrlTextField isFirstResponder]) {
        [self.attachLinkUrlTextField resignFirstResponder];
    }

    self.visibleAttacedLinkUrl= [Utility getValidString:self.attachLinkUrlTextField.text];
    self.enteredAttacedLinkUrl = self.visibleAttacedLinkUrl;
    self.enteredAttacedLinkUrl = [Utility getUrlStringWithHttpVerb:self.enteredAttacedLinkUrl];

    self.imageArray = nil;
    selectedImageIndex = 0;
    self.selectedImageView.image = [UIImage imageNamed:@"default_attached_image.png"];
    self.selectImageButton.hidden = YES;
    self.selectedImageUrl = @"";
        if (![Utility isValidString:[Utility getValidString:self.attachLinkUrlTextField.text]]) {
            [Utility showAlertMessage:@"Please enter valid URL" withTitle:@"Alert"];
        }
        else
        {
            if (![appDelegate isNetworkAvailable]) {
                [Utility showNetWorkAlert];
                return;
            }
            else
            {
                NSDictionary *getImages =@{@"activityUrl":self.enteredAttacedLinkUrl };
                NSString *strImagesFromLink = [NSString stringWithFormat:@"%@%@",BASE_URL,WEB_URL_ActivityGetImages];
                DLog(@"%s Performing %@ api \n with Parameter:%@",__FUNCTION__,strImagesFromLink,getImages);
                [serviceManager executeServiceWithURL:strImagesFromLink andParameters:getImages forTask:kTaskActivityGetImages completionHandler:^(id response, NSError *error, TaskType task) {
                    DLog(@"%s %@ api \n with response: %@",__FUNCTION__,strImagesFromLink,response);

                    if (!error && response) {
                        NSDictionary *dict = (NSDictionary *)response;
                        if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0000"]) {
                            self.imageArray = [[dict valueForKey:@"data"] valueForKey:@"src"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.imageArray.count == 0) {
                                    self.selectedImageView.image = [UIImage imageNamed:@"no-image.png"];
                                    DLog(@"nil array ");
                                } else {
                                    self.imageArray = [[NSSet setWithArray: self.imageArray] allObjects];
                                    [self.selectedImageView configureImageForUrl:[self.imageArray firstObject]];
                                    self.selectedImageUrl = (NSString *)[self.imageArray objectAtIndex:selectedImageIndex];

                                }
                                self.selectImageButton.hidden = NO;
                            });
                        } else if ([[dict valueForKey:@"response_code"] isEqualToString:@"RC0004"]) {
                            [appDelegate userAutismSessionExpire];
                        }
                    }
                    
                }];
                
            }
        }
}

- (IBAction)nextButtonPressed:(id)sender {
    if (self.imageArray == nil || [self.imageArray count] == 0)
        return;
    
    ++selectedImageIndex;
    if (selectedImageIndex == self.imageArray.count) {
        selectedImageIndex = 0;
    }
    [self showSelectedImage];

}

- (IBAction)previousButtonPressed:(id)sender {
    if (self.imageArray == nil || [self.imageArray count] == 0)
        return;

    --selectedImageIndex;
    if (selectedImageIndex < 0) {
        selectedImageIndex = self.imageArray.count -1;
    }
    [self showSelectedImage];
}

- (void)showSelectedImage {
    self.selectedImageUrl = (NSString *)[self.imageArray objectAtIndex:selectedImageIndex];
    [self.selectedImageView  configureImageForUrl:self.selectedImageUrl];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.attachLinkUrlTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end

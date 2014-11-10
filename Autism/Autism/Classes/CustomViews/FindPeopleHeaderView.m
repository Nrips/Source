//
//  FindPeopleHeaderView.m
//  Autism
//
//  Created by Neuron Mac on 10/09/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "FindPeopleHeaderView.h"
#import "Utility.h"

@implementation FindPeopleHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
        
        _txtName.delegate = self;
        _txtMail.delegate = self;
        _txtCity.delegate = self;
        [self.txtLocalAuthority setText:kTitleSelect];

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


-(void)setValueInLocalAuthority:(NSString *)localAuthority
{
    [self.txtLocalAuthority setText:localAuthority];
}

-(IBAction)localAuthorityAction:(id)sender
{
 if ([self.delegate respondsToSelector:@selector(showPickerOnClick)]) {
        [self.delegate showPickerOnClick];
    }
}

-(void)setLocalAuthorityValue:(NSString *)localAuthority
{
    self.txtLocalAuthority.text = localAuthority;
    DLog(@"localAuthority %@", localAuthority);
}

-(IBAction)searchAction:(id)sender
{
    NSString *localAuthorityArea = @"";
    if (![[Utility getValidString:self.txtLocalAuthority.text] isEqualToString:kTitleSelect]) {
        localAuthorityArea = [Utility getValidString:self.txtLocalAuthority.text];
    }

    if ([self.delegate respondsToSelector:@selector(clickOnSearchButton:emailString:cityString:localAuthorityString:)]) {
        [self.delegate clickOnSearchButton:self.txtName.text emailString:self.txtMail.text cityString:self.txtCity.text
                      localAuthorityString:localAuthorityArea];
        
    }
}

#pragma mark - TextFeild Delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(assignActiveTextField:)])
    {
        [self.delegate assignActiveTextField:textField];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.phase == UITouchPhaseBegan) {
        
        [_txtName resignFirstResponder];
        [_txtMail resignFirstResponder];
        [_txtLocalAuthority resignFirstResponder];
        [_txtCity resignFirstResponder];
    }
}

@end

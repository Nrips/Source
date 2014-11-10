//
//  InboxCell.m
//  Autism
//
//  Created by Neuron-iPhone on 6/2/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "InboxCell.h"
#import "Utility.h"

@interface InboxCell() <UIActionSheetDelegate>

@property(nonatomic) BOOL isMemberActivityReported;
@property(nonatomic, strong) UIActionSheet *actionSheet;
@property(nonatomic) BOOL isRecord;



@end

@implementation InboxCell


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (InboxCell *)cellFromNibNamed:(NSString *)nibName{
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    InboxCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[InboxCell class]]) {
            customCell = (InboxCell *)nibItem;
            break; // we have a winner
        }
    }
    return customCell;
}

- (void)configureCell:(MessageInInbox *)member
{
    [self.lblName setText:member.name];
    [self.lblMessegeDetail  setText:member.lastMessage];
    [self.imag configureImageForUrl:member.imageUrl];
    self.inboxMemberId = member.memberId;
    self.isMemberActivityReported = member.isReported;
    self.isRecord = member.isMessageRecord;
}

- (IBAction)reportToAWMButtonPressed:(id)sender
{
    if (!self.isRecord) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kTitleReportToAWM, nil];
         }
   else{
      self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kTitleReportToAWM, kTitleDeleteConversation, nil];
       }
    
    self.actionSheet.delegate = self;
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [self.actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqual:kTitleReportToAWM])
    {
        if (self.isMemberActivityReported) {
            [Utility showAlertMessage:@"This has been reported to AWM. If we need any more information we will contact you." withTitle:@"Already Reported"];
            return;
        }
        if([self.delegate respondsToSelector:@selector(showReportToAWMViewWithReportID:)])
        {
            [self.delegate showReportToAWMViewWithReportID:self.inboxMemberId];
        }
    }else if([title isEqual:kTitleDeleteConversation]) {
        [self.delegate deleteConversationForRow:self.tag];
    }
    [self.actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = appUIGreenColor;
        }
    }
}


@end

//
//  OtherStoryCell.m
//  Autism
//
//  Created by Dipak on 6/5/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "OtherStoryCell.h"
#import "NSDictionary+HasValueForKey.h"
#import "UIPlaceHolderTextView.h"
#import "CustomLabel.h"
#import "OtherStoryViewController.h"

@interface OtherStoryCell()

@property (weak, nonatomic) IBOutlet UILabel *stroryQuestionLabel;

@end

@implementation OtherStoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.otherStoryTextView.delegate = self; 
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


-(void)configureCell:(NSDictionary *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight
{
    self.otherStoryTextView.delegate = self;
    CGRect cellFrame = self.frame;
    cellFrame.size.height = cellHeight;
    self.frame = cellFrame;

    if ([self.profileType isEqualToString:kProfileTypeOther]) {
        
        CGRect frame = self.otherStoryLabel.frame;
        frame.size.height = labelHeight;
        self.otherStoryLabel.frame = frame;
        
        if ([question hasValueForKey:@"question"]) {
            self.stroryQuestionLabel.text = [question objectForKey:@"question"];
        }
        if ([question hasValueForKey:@"answer"]) {
            self.otherStoryLabel.text = [question objectForKey:@"answer"];
        }
    }
else{
    
    
  if ([question hasValueForKey:@"question"]) {
        self.stroryQuestionLabel.text = [question objectForKey:@"question"];
    }
    if ([question hasValueForKey:@"answer"]) {
        self.otherStoryTextView.text = [question objectForKey:@"answer"];
        
        }
    
    if (self.otherStoryTextView.text.length > 251) {
       
        CGRect frame = self.otherStoryTextView.frame;
        frame.size.height = labelHeight + 20;
        self.otherStoryTextView.frame = frame;
        [self.otherStoryTextView sizeThatFits:frame.size];
    }
    else{
    
    CGRect frame = self.otherStoryTextView.frame;
    frame.size.height = labelHeight + 20;
    self.otherStoryTextView.frame = frame;
    [self.otherStoryTextView sizeThatFits:frame.size];
    }
  }
}

- (void)textViewDidChange:(UITextView *)textView {
    DLog(@"%@",textView.text);
    if ([self.delegate respondsToSelector:@selector(didSelectedTextViewOnSection:sectionNumber:)]) {
        [self.delegate didSelectedTextViewOnSection:textView.text sectionNumber:self.currentSection];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(assignActiveTextView:)]) {
        [self.delegate assignActiveTextView:textView];
    }
    
    CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin toView:self.otherStory.otherStoryTableView];
    CGPoint contentOffset = self.otherStory.otherStoryTableView.contentOffset;
    
    
    contentOffset.y = (pointInTable.y - textView.inputAccessoryView.frame.size.height);
    
    DLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
    
    [self.otherStory.otherStoryTableView setContentOffset:contentOffset animated:YES];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        OtherStoryCell *cell = (OtherStoryCell *)textView.superview.superview;
        NSIndexPath *indexPath = [self.otherStory.otherStoryTableView indexPathForCell:cell];
        
        [self.otherStory.otherStoryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    return YES;
}

@end

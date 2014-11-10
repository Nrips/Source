//
//  CustomStoryView.m
//  Autism
//
//  Created by Neuron-iPhone on 2/18/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "CustomStoryView.h"
#import "MyStoryViewController.h"


@implementation CustomStoryView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CustomStoryView *)cellFromNibNamed:(NSString *)nibName {
    
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    CustomStoryView *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[CustomStoryView class]]) {
            customCell = (CustomStoryView *)nibItem;
            break; // we have a winner
        }
    
    }
    return customCell;
}

-(void) configureCell:(QuestionsInStory *)person {
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    DLog(@"%ld",(long)self.currentSection);
    
}

-(void) textViewDidEndEditing:(UITextView *)textView
{

    DLog(@"endediting");
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


@end

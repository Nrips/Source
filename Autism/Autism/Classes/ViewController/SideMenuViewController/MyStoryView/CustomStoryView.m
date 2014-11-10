//
//  CustomStoryView.m
//  Autism
//
//  Created by Neuron-iPhone on 2/18/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "CustomStoryView.h"

@implementation CustomStoryView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textViewAnswers.delegate =self;
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
//    customCell.imageView = [[MyImageView alloc]initWithFrame:CGRectMake(0, 0, 59, 54)];
//    [customCell.imageView setImage:[UIImage imageNamed:@"user-btn.fw.png"]];
//    [customCell addSubview:customCell.imageView];
    return customCell;
}
-(void) configureCell:(QuestionsInStory *)person {
    
       
}


-(void) textViewDidEndEditing:(UITextView *)textView
{
     //[arrTemp replaceObjectAtIndex:textField.tag withObject:textField.text];
    //CustomStoryView *textFieldCell = (CustomStoryView *)[[self.textView superview] superview];
    NSLog(@"currentSection:%d,tag:%d",self.currentSection, self.tag);
    //if ([self.delegate respondsToSelector:@selector(didSelectedTextViewOnSection:)]) {
        [self.delegate didSelectedTextViewOnSection:textView.text sectionNumber:self.tag];
    //}
    
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"%@",textView.text);
}


@end

//
//  CustomStoryView.h
//  Autism
//
//  Created by Neuron-iPhone on 2/18/14.
//  Copyright (c) 2014 Neuron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionsInStory.h"

@protocol CustomStoryViewProtocol <NSObject>

-(void) didSelectedTextViewOnSection:(NSString *)answerText sectionNumber:(int)sectionNumber ;

@end

@interface CustomStoryView : UITableViewCell<UITextViewDelegate>

-(void) configureCell:(QuestionsInStory *)person;
+ (CustomStoryView *)cellFromNibNamed:(NSString *)nibName;

@property (nonatomic, assign) NSInteger currentSection;
@property(nonatomic,strong) IBOutlet UITextView *textViewAnswers;

@property(nonatomic,strong) NSString *feedbackString;

@property (nonatomic, weak) id<CustomStoryViewProtocol> delegate;
@end

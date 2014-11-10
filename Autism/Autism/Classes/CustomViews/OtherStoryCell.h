//
//  OtherStoryCell.h
//  Autism
//
//  Created by Dipak on 6/5/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "OtherStoryViewController.h"
@protocol OtherStoryCellProtocol <NSObject>

-(void) didSelectedTextViewOnSection:(NSString *)answerText sectionNumber:(int)sectionNumber ;

-(void)assignActiveTextView:(UITextView*) textView;
@end

@interface OtherStoryCell : UITableViewCell <UITextViewDelegate>

-(void)configureCell:(NSDictionary *)question detailLabelHeight:(float)labelHeight andCellHeight:(float)cellHeight;

@property(nonatomic,strong)IBOutlet UIImageView *imgQuestion;
@property(nonatomic,strong)IBOutlet UIImageView *imgAnswer;
@property (weak, nonatomic) IBOutlet UITextView *otherStoryTextView;
@property (weak, nonatomic) IBOutlet UILabel *otherStoryLabel;
@property (nonatomic,assign) NSInteger currentSection;
@property (weak, nonatomic)OtherStoryViewController *otherStory;
@property(nonatomic,strong) NSString *profileType;

@property (nonatomic,weak) id<OtherStoryCellProtocol> delegate;

@end

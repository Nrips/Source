//
//  CommentView.h
//  Autism
//
//  Created by Dipak on 5/23/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@protocol CommentViewDelegate <NSObject>

- (void)commentSuccessfullySubmitted;

@optional
- (void)updateRecordsForReplyCountInQA;

@end

@interface CommentView : UIView
@property (nonatomic,weak) id <CommentViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *commentTextView;
@property (strong, nonatomic) NSString *selectedActivityId;
@property (strong, nonatomic) NSString *questionID;
@property (strong, nonatomic) IBOutlet UIView *commentView;

@property (nonatomic) CommentType commentType;

@end

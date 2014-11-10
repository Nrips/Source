//
//  MDViewController.h
//  MJAutoCompleteDemo
//
//  Created by Mazyad Alabduljaleel on 2/18/14.
//  Copyright (c) 2014 ArabianDevs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJAutoCompleteManager.h"
#import "UIPlaceHolderTextView.h"

typedef enum {
    STTweetCommentHandle = 0,
    STTweetCommentHashtag,
    STTweetCommentLink,
    STTweetCommentNotificationType
} STTweetCommentHotWord;


@protocol CommentViewControllerDelegate <NSObject>

@optional
- (void)commentSuccessfullySubmitted;
- (void)updateRecordsForReplyCountInQA;
-(void)updateRecordByPost;

@end

@interface CommentViewController : UIViewController <MJAutoCompleteManagerDataSource, MJAutoCompleteManagerDelegate, UITextViewDelegate>

@property (nonatomic,weak) id <CommentViewControllerDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *textView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet UIButton *btnPost;


@property (strong, nonatomic) NSString *selectedActivityId;
@property (strong, nonatomic) NSString *activityDetailId;
@property (strong, nonatomic) NSString *questionID;
@property (strong, nonatomic) NSString *activityCommentText;
@property (nonatomic, strong) NSString *cleanText;
@property (strong, nonatomic) NSString *answerId;
@property (strong, nonatomic) NSString *answerText;


@property (nonatomic) CommentType commentType;
@property (nonatomic, strong) NSString *parentViewControllerName;
@property (strong) NSMutableArray *rangesOfHotWords;
@property (strong) NSArray *tagArray;
@property (strong) NSLayoutManager *layoutManager;
@property (strong) NSTextContainer *textContainer;
@property (nonatomic, assign) BOOL leftToRight;



@end


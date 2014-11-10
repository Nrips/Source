//
//  STTweetLabel.h
//  STTweetLabel
//
//  Created by Sebastien Thiebaud on 09/29/13.
//  Copyright (c) 2013 Sebastien Thiebaud. All rights reserved.
//

#import "Notification.h"
#import "GetMyActivity.h"
#import "GetAllQuestion.h"
#import "QuestionDetail.h"
#import "GetMyQuestion.h"
#import "HelpfulAnswer.h"
#import "ReplyQuestion.h"
#import "ActivityDetails.h"

typedef enum {
    STTweetHandle = 0,
    STTweetHashtag,
    STTweetLink,
    STTweetNotificationType
} STTweetHotWord;

@interface STTweetLabel : UILabel

@property (nonatomic, strong)Notification *notifcation;
@property (nonatomic, strong)GetMyActivity *getMyActivity;
@property (nonatomic, strong)GetAllQuestion *question;
@property (nonatomic, strong)QuestionDetail *questionDetail;
@property(nonatomic,strong)GetMyQuestion *myQuestion;
@property(nonatomic,strong)HelpfulAnswer *helpfulQuestion;
@property(nonatomic,strong)ReplyQuestion *replyQuestion;
@property(nonatomic,strong)ActivityDetails *acttivityDetail;

@property(nonatomic,strong)NSArray *QATagArray;
@property(nonatomic,strong)NSArray *ActivityTagArray;
@property(nonatomic,strong)NSMutableArray *rangeArray;

@property(nonatomic,strong)NSString *qaDetail;
@property(nonatomic,strong)NSString *eventDetail;
@property(nonatomic,strong)NSString *activityDetail;



@property (nonatomic, strong) NSString *callerView;
@property (nonatomic, strong) NSArray *validProtocols;
@property (nonatomic, assign) BOOL leftToRight;
@property (nonatomic, assign) BOOL textSelectable;
@property (nonatomic, strong) UIColor *selectionColor;
@property (nonatomic, copy) void (^detectionBlock)(STTweetHotWord hotWord, NSString *hotString, NSString *hotWordID, NSString *protocol, NSRange range);

- (void)setAttributes:(NSDictionary *)attributes;
- (void)setAttributes:(NSDictionary *)attributes hotWord:(STTweetHotWord)hotWord;
- (void)setupFontColorOfHashTag;
- (NSDictionary *)attributes;
- (NSDictionary *)attributesForHotWord:(STTweetHotWord)hotWord;

- (CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width;

@end

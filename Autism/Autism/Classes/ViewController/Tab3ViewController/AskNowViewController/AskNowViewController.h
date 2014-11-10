//
//  AskNowViewController.h
//  Autism
//
//  Created by Vikrant Jain on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJAutoCompleteManager.h"
#import "UIPlaceHolderTextView.h"
typedef enum {
    STTweetAskHandle = 0,
    STTweetAskHashtag,
    STTweetAskLink,
    STTweetAskNotificationType
} STTweetAskHotWord;


@protocol AskNowViewDelegate<NSObject>
- (void)reloadQATable;
@end

@interface AskNowViewController : UIViewController<MJAutoCompleteManagerDataSource, MJAutoCompleteManagerDelegate, UITextViewDelegate>
@property (nonatomic, strong) NSDictionary *dictionaryKeyword;

@property (nonatomic,weak) id<AskNowViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *btnAskquestion;
@property (nonatomic, strong) NSString *strQuestionId;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, strong) NSString *cleanText;

@property (nonatomic, strong) NSString *passQuestion;
@property (nonatomic, strong) NSArray  *passQuestionTag;
@property (nonatomic, strong) NSString *passQuestionDetail;
@property (strong) NSArray *memberTagArray;
@property (strong) NSMutableArray *rangesOfHotWords;

@end

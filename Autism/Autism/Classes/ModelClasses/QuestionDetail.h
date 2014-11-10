//
//  QuestionDetail.h
//  Autism
//
//  Created by Vikrant Jain on 4/14/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionDetail : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *getQuestion;
@property (nonatomic, strong) NSString *getQuestionId;
@property (nonatomic, strong) NSString *quetionDetails;
@property (nonatomic, strong) NSString *answer;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *answerTime;
@property (nonatomic, strong) NSArray *memberTagsArray;
@property (nonatomic) BOOL isSelfQuestion;
@property (nonatomic) BOOL isQuestionReported;
@property (nonatomic) BOOL isQuestionBlock;
@property (nonatomic) BOOL isCircleStatus;



@property (nonatomic)BOOL checkReplyHelpfull;
@property (nonatomic)BOOL checkReplyLike;
@property (nonatomic) BOOL isQuestionReplyReported;
@property (nonatomic, strong) NSString *questionReplyID;
@property (nonatomic, strong) NSString *answerMemberID;

@end

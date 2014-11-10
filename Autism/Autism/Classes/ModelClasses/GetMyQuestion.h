//
//  GetMyQuestion.h
//  Autism
//
//  Created by Vikrant Jain on 2/26/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetMyQuestion : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *getQuestion;
@property (nonatomic, strong) NSString *quetionDetails;
@property (nonatomic, strong) NSString *helpfulCount;
@property (nonatomic, strong) NSString *repliesCount;
@property (nonatomic, strong) NSString *questionId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) BOOL isSelfQuestion;
@property (nonatomic) BOOL isQuestionReported;
@property (nonatomic, strong) NSString *addedQuestionMemberID;
@property (nonatomic) BOOL isMemberAlreadyInCircle;
@property (nonatomic, strong) NSArray *tagsArray;
@property (nonatomic) BOOL isHelpful;
@property (nonatomic, strong) NSArray *memberTagsArray;

@end

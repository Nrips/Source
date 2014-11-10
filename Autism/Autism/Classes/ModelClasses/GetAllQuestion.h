//
//  GetAllQuestion.h
//  Autism
//
//  Created by Vikrant Jain on 2/24/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetAllQuestion : NSObject

@property(strong,nonatomic)IBOutlet UIImageView *profilePicture;

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *getQuestion;
@property (nonatomic, strong) NSString *quetionDetails;
@property (nonatomic, strong) NSString *helpfulCount;
@property (nonatomic, strong) NSString *repliesCount;
@property (nonatomic, strong) NSString *questionId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) BOOL isSelfQuestion;
@property (nonatomic, strong) NSString *isQuestionReported;
@property (nonatomic, strong) NSString *addedQuestionMemberID;
@property (nonatomic) BOOL isMemberAlreadyInCircle;
@property (nonatomic, strong) NSArray *tagsArray;
@property (nonatomic) BOOL isHelpful;
@property (nonatomic, strong) NSArray *memberTagsArray;

@end

//
//  ReplyQuestion.h
//  Autism
//
//  Created by Vikrant Jain on 4/22/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplyQuestion : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *answer;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *memberTagsArray;
@property (nonatomic, strong) NSString *addedQuestionMemberID;
@end

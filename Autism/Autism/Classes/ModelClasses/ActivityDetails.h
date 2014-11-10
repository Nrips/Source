//
//  ActivityDetails.h
//  Autism
//
//  Created by Dipak on 5/24/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityDetails : NSObject

@property (nonatomic, strong) NSString *commentUserName;
@property (nonatomic, strong) NSString *commentUserImageUrl;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) NSString *commentTime;
@property (nonatomic, strong) NSString *activityCommentID;
@property (nonatomic, strong) NSString *activityCommentMemberID;
@property (nonatomic, strong) NSString *likeCount;
@property (nonatomic, strong) NSString *hugCount;
@property (nonatomic,strong) NSArray *tagsArray;
@property (nonatomic) BOOL isSelfActivityComment;
@property (nonatomic) BOOL isActivityCommentLiked;
@property(nonatomic) BOOL isMemberActivityLike;
@property(nonatomic) BOOL isMemberActivityHug;


@end

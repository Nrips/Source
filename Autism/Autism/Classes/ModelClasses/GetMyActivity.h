//
//  GetMyActivity.h
//  Autism
//
//  Created by Neuron-iPhone on 3/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetMyActivity : NSObject

@property(nonatomic,strong) NSString *activityId;
@property(nonatomic,strong) NSString *hug;
@property(nonatomic,strong) NSString *like;
@property(nonatomic,strong) NSString *picture;
@property(nonatomic,strong) NSString *detail;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *activityMemberId;
@property(nonatomic,strong) NSString *wallPostUSerId;
@property(nonatomic,strong) NSString *wallPostUSerName;

@property(nonatomic) BOOL isMemberActivityReported;
@property(nonatomic) BOOL isSelfMemberActivity;
@property(nonatomic) BOOL isMemberAlreadyCircle;
@property(nonatomic) BOOL isMemeberBlocked;
@property(nonatomic) BOOL isMemberActivityLike;
@property(nonatomic) BOOL isMemberActivityHug;
@property(nonatomic) BOOL isWallPost;

@property (nonatomic,strong) NSMutableArray *imagesArray;
@property (nonatomic,strong) NSArray *tagsArray;

@property(nonatomic,strong) NSString *attachLinkUrl;
@property(nonatomic,strong) NSString *attachLinkThumbnailImageUrl;

@property(nonatomic,strong) NSString *videoUrl;
@property(nonatomic,strong) NSString *attachVideoUrl;
@property(nonatomic,strong) NSString *videoThumbnailImageUrl;

@property(nonatomic, strong) NSString *activityTime;

@end

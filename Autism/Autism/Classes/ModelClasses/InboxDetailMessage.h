//
//  InboxDetailMessage.h
//  Autism
//
//  Created by Neuron-iPhone on 6/9/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxDetailMessage : NSObject

@property (nonatomic,strong) NSString *memberImageUrl;
@property (nonatomic,strong) NSString *attachLinkUrl;
@property (nonatomic,strong) NSString *attachLinkImageUrl;
@property (nonatomic,strong) NSString *messageLink;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *messageId;
@property (nonatomic,strong) NSMutableArray *imagesArray;
@property (nonatomic,strong) NSString *memberId;
@property (nonatomic,strong) NSString *videoLink;




@end

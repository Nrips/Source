//
//  MessageInInbox.h
//  Autism
//
//  Created by Neuron-iPhone on 6/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageInInbox : NSObject

@property (strong, nonatomic) NSString *memberId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *lastMessage;
@property (strong, nonatomic) NSString *imageUrl;
@property (nonatomic) BOOL isReported;
@property (nonatomic) BOOL isMessageRecord;


@end

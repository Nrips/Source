//
//  ServiceManager.h
//  Autism
//
//  Created by Haider on 03/02/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceManager : NSObject

@property (strong, nonatomic) NSURLSessionUploadTask *postUploadTask;
@property (strong, nonatomic) NSURLSessionUploadTask *postUploadMyTask;
@property (strong, nonatomic) NSURLSessionUploadTask *postUploadInboxMessageTask;
@property (strong, nonatomic) NSURLSessionUploadTask *postUploadOtherTask;
@property (strong, nonatomic) NSURLSessionUploadTask *postPhotosInAlbum;


+ (ServiceManager *)sharedManager;

// Method which doesnt take any post parameters
- (void)executeServiceWithURL:(NSString*)urlString forTask:(TaskType)task completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock;


// Method which take post parameters

- (void)executeServiceWithURL:(NSString*)urlString andParameters:(NSDictionary *)postParameters forTask:(TaskType)task completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock;

- (void)executePostImageServiceWithURL:(NSString*)urlString postParameters:(NSDictionary *)postParameters imageArray:(NSArray *)imageArray object:(id)object forTask:(TaskType)task completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock;

@end

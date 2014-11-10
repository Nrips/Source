//
//  ServiceManager.m
//  Autism
//
//  Created by Haider on 03/02/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "ServiceManager.h"
#import "Utility.h"

static ServiceManager *serviceManagerObj = nil;
@implementation ServiceManager

+ (ServiceManager *)sharedManager{
    static dispatch_once_t predicate;
    if(serviceManagerObj == nil){
        dispatch_once(&predicate,^{
            serviceManagerObj = [[ServiceManager alloc] init];
        });
    }
    return serviceManagerObj;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)executeServiceWithURL:(NSString*)urlString forTask:(TaskType)task completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock{
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *jsonData) {
        
        completionBlock(jsonData, operation.error, task);
        [appSharedData removeLoadingView];
                
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //DLog(@"Error: %@", [error localizedDescription]);
        completionBlock(nil, error, task);
        [appSharedData removeLoadingView];
        DLog(@"error:%@",error);
        [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];

    }];
    
    [op start];
    
    NSString *title = @"Loading...";
    NSString *message = @"";
    if (task == kTaskGetLocalAuthority) {
        message = @"Local Authority";
        
    }
    else if (task == kTaskGetRole) {
        message = @"Role";
        
    }
    else if (task == kTaskGetOtherLocalAuthority) {
        message = @"Other Local Authority";
    }
    else if (task == kTaskEventDetailShowing) {
        message = @"Event Details";
    }
    
    else if (task == kTaskMyQuestion) {
        message = @"MyQuestion";
    }
    else if (task == KTaskGetAllQuestion) {
        message = @"Question";
    }
    [appSharedData showCustomLoaderWithTitle:message message:title];
}


- (void)executePostImageServiceWithURL:(NSString*)urlString postParameters:(NSDictionary *)postParameters imageArray:(NSArray *)imageArray object:(id)object forTask:(TaskType)task completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock
{
    
   // DLog(@"imageArray count:%d",imageArray.count);
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    if (task == kTaskImageUploading) {
        
        //NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"IMG_7.JPG"],[UIImage imageNamed:@"IMG_8.JPG"],nil];
        
        __block int i=1;
        __block NSError *errorTask;
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            long dataLenght = 0.0;
            long realImageData = 0.0;
            for(UIImage *eachImage in imageArray)
            {
                NSData *data = UIImagePNGRepresentation(eachImage);
                realImageData = realImageData + data.length;
                
                NSData *imageData = UIImageJPEGRepresentation(eachImage, .5);
                dataLenght = dataLenght + imageData.length;
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image%d",i] fileName:[NSString stringWithFormat:@"image%d.jpg",i] mimeType:@"image/jpeg"];
                i++;
            }
            //DLog(@"-----realImageData:%ld",realImageData/(1024*1024));
            
            //DLog(@"-----dataLenght:%ld",dataLenght/(1024*1024));
        } error:nil];
        
        
        NSProgress *progress = nil;
        
        self.postUploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            
            errorTask = error;
            [progress removeObserver:object forKeyPath:kProgressFractionCompleted context:kPostUpdateTypePostUpdate];
            completionBlock(responseObject, error, task);
            if (error) {
                DLog(@"Error: %@", error);
            } else {
                DLog(@"response:%@ \n responseObject:%@", response, responseObject);
            }
        }];
        [self.postUploadTask resume];
        
        
        [progress addObserver:object forKeyPath:kProgressFractionCompleted
                      options:NSKeyValueObservingOptionNew
                      context:kPostUpdateTypePostUpdate];
    }else if (task == kTaskPostUpdate) {
        __block int i=1;
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:postParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageArray.count > 0) {
                long dataLenght = 0.0;
                for(UIImage *eachImage in imageArray)
                {
                    NSData *imageData = UIImageJPEGRepresentation(eachImage, .5);
                    dataLenght = dataLenght + imageData.length;
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image%d",i] fileName:[NSString stringWithFormat:@"image%d.jpg",i] mimeType:@"image/jpeg"];
                    i++;
                }
                //DLog(@"%s, Image data Lenght:%ld",__FUNCTION__,dataLenght/(1024*1024));
            }
        } error:nil];
        
        NSProgress *progress = nil;
        self.postUploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [progress removeObserver:object forKeyPath:kProgressFractionCompleted context:kPostUpdateTypePostUpdate];
            completionBlock(responseObject, error, task);
        }];
        [self.postUploadTask resume];
        
        [progress addObserver:object forKeyPath:kProgressFractionCompleted
                      options:NSKeyValueObservingOptionNew
                      context:kPostUpdateTypePostUpdate];
    } else if (task == kTaskPostUpdateMy) {
        __block int i=1;
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:postParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageArray.count > 0) {
                long dataLenght = 0.0;
                for(UIImage *eachImage in imageArray)
                {
                    NSData *imageData = UIImageJPEGRepresentation(eachImage, .5);
                    dataLenght = dataLenght + imageData.length;
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image%d",i] fileName:[NSString stringWithFormat:@"image%d.jpg",i] mimeType:@"image/jpeg"];
                    i++;
                }
            }
        } error:nil];
        
        NSProgress *progress = nil;
        self.postUploadMyTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [progress removeObserver:object forKeyPath:kProgressFractionCompleted context:kPostUpdateTypePostUpdate];
            completionBlock(responseObject, error, task);
        }];
        [self.postUploadMyTask resume];
        
        [progress addObserver:object forKeyPath:kProgressFractionCompleted
                      options:NSKeyValueObservingOptionNew
                      context:kPostUpdateTypePostUpdateMy];
    } else if (task == kTaskPostUpdateOther) {
        __block int i=1;
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:postParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageArray.count > 0) {
                long dataLenght = 0.0;
                for(UIImage *eachImage in imageArray)
                {
                    NSData *imageData = UIImageJPEGRepresentation(eachImage, .5);
                    dataLenght = dataLenght + imageData.length;
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image%d",i] fileName:[NSString stringWithFormat:@"image%d.jpg",i] mimeType:@"image/jpeg"];
                    i++;
                }
               // DLog(@"%s, Image data Lenght:%ld",__FUNCTION__,dataLenght/(1024*1024));
            }
        } error:nil];
        
        NSProgress *progress = nil;
        self.postUploadOtherTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [progress removeObserver:object forKeyPath:kProgressFractionCompleted context:kPostUpdateTypePostUpdateOther];
            completionBlock(responseObject, error, task);
        }];
        [self.postUploadOtherTask resume];
        
        [progress addObserver:object forKeyPath:kProgressFractionCompleted
                      options:NSKeyValueObservingOptionNew
                      context:kPostUpdateTypePostUpdateOther];
    } else if (task == kTaskPostInboxMessage) {
        __block int i=1;
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:postParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageArray.count > 0) {
                long dataLenght = 0.0;
                for(UIImage *eachImage in imageArray)
                {
                    NSData *imageData = UIImageJPEGRepresentation(eachImage, .5);
                    dataLenght = dataLenght + imageData.length;
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image%d",i] fileName:[NSString stringWithFormat:@"image%d.jpg",i] mimeType:@"image/jpeg"];
                    i++;
                }
                //DLog(@"%s, Image data Lenght:%ld",__FUNCTION__,dataLenght/(1024*1024));
            }
        } error:nil];
        
        NSProgress *progress = nil;
        self.postUploadInboxMessageTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [progress removeObserver:object forKeyPath:kProgressFractionCompleted context:kPostUpdateTypeSendMessage];
            completionBlock(responseObject, error, task);
        }];
        [self.postUploadInboxMessageTask resume];
        
        [progress addObserver:object forKeyPath:kProgressFractionCompleted
                      options:NSKeyValueObservingOptionNew
                      context:kPostUpdateTypeSendMessage];
    }
    else if (task == kTaskAddPhotosInAlbum) {
        __block int i=1;
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:postParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageArray.count > 0) {
                long dataLenght = 0.0;
                for(UIImage *eachImage in imageArray)
                {
                    NSData *imageData = UIImageJPEGRepresentation(eachImage, .5);
                    dataLenght = dataLenght + imageData.length;
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image%d",i] fileName:[NSString stringWithFormat:@"image%d.jpg",i] mimeType:@"image/jpeg"];
                    i++;
                }
            }
        } error:nil];
        
        NSProgress *progress = nil;
        self.postPhotosInAlbum = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [progress removeObserver:object forKeyPath:kProgressFractionCompleted context:kPostTypeAddPhotosInAlbum];
            completionBlock(responseObject, error, task);
        }];
        [self.postPhotosInAlbum resume];
        
        [progress addObserver:object forKeyPath:kProgressFractionCompleted
                      options:NSKeyValueObservingOptionNew
                      context:kPostTypeAddPhotosInAlbum];
    }
    
}


- (void)executeServiceWithURL:(NSString*)urlString andParameters:(NSDictionary *)postParameters forTask:(TaskType)task completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock {
    
    NSString *title = @"Loading...";
    NSString *message = @"";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    if (task == kTaskSignUp) {
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

            //DLog(@"JSON: %@", responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
    }
    else if (task == kTaskLogin)
        
    {
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    else if (task == kTaskFbdata )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@ , \n operation.responseString:%@", error, operation.responseString);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    
    else if (task == kTAskPostStoryAnswers)
    {
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // DLog(@"JSON: %@", responseObject);
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    
    else if (task == kTaskPostQuestion )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            DLog(@"%@ post question",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    else if (task == kTaskGetSearchPeople )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // DLog(@"Find people Api response %@",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            //[appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskFindProvider )
    {
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskFindProviderDetail)
    {
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:@""];
            
        }];
        
    }
    
    else if (task == kTaskServiceDetail )
    {
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"Find ServiceDetail Api response %@",responseObject);
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:@""];
            
        }];
        
    }
    
    else if (task == kTaskShowReview )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"ShowReview Api response %@",responseObject);
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskWriteReview)
    {
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"WriteReview Api response %@",responseObject);
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskEditReview)
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"EditReview Api response %@",responseObject);
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }

    
    
    
    else if (task == KTaskGetAllQuestion )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [appSharedData removeLoadingView];
            //DLog(@"KTaskGetAllQuestion responseObject:%@",responseObject);
            completionBlock(responseObject, operation.error, task);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            //DLog(@"Error: %@ , operation.responseString:%@", error, operation.responseString);
        }];
        
    }
    
    else if (task == kTaskGetEventDetails)
        
    {
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // DLog(@"JSON: %@", responseObject);
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskMyQuestion)
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskEventDetailShowing )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager",responseObject);
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskAttendEvent )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager responseObject of attend Event",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    
    else if (task == kTaskGetActivity)
    {

          AFHTTPRequestOperation *getActivityOperation =  [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
        AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
        
        if (appdel.isNeedToSetRequestPriority )
        {
            appdel.isNeedToSetRequestPriority = NO;
            [getActivityOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        } else {
            [getActivityOperation setQueuePriority:NSOperationQueuePriorityNormal];
            
        }
    }
    
    else if (task == kTaskOtherActivity)
    {
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"OtherActivity API from Service Manager %@", responseObject);
            
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
    }
    
    
    else if (task == kTaskLikeHug)
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"JSON: Like in  MyActivity API from Service Manager %@", responseObject);
            
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    
    else if (task == kTaskShareActivity)
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@" Like in  share Activity API from Service Manager %@", responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    else if (task == kTaskMyQuestion )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
    }
    
    else if (task == kTaskMemberInCircle )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
    }
    
    else if (task == kTaskGetUserDetails )
    {
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
    }
    
    
    else if (task == kTaskActivityGetImages){
        
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
        
    }
    
    
    else if (task == kTaskQuestionDetails){
        
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager QA Details",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
        
    }
    
else if (task == kTaskHelpfulAnswer){
        
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // DLog(@"%@ service manager helpful",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
        
    }
    
    
    else if (task == kTaskReplyQuestion){
        
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // DLog(@"%@ service manager reply",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
    }
    
    
    else if (task == kTaskQADetailHelpfull){
        
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager helpfull",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
        
    }
    
    
    else if (task == kTaskQADetailLike){
        
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"%@ service manager like ",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
        
        
    }
    
    else if (task == kTaskPostQuestionComment){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
    }
    
    else if (task == kTaskReportActivityComment){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
            DLog(@"Error: %@", error);
        }];
    }
    
    else if (task == kTaskQuestionReportToAWMForQuestions){
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // DLog(@"%@ service manager reply",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
    }
    else if (task == kTaskQuestionReportToAWMForQuestionsReplies){
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // DLog(@"%@ service manager reply",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
    }
    else if (task == kTaskQuestionReportToAWMForReportActivity){
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // DLog(@"%@ service manager reply",responseObject);
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
    }
    else if (task == kTaskAddMemberInTeam){
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskActivityComment){
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskBlockMember){
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskGetActivityDetailById){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskDeleteActivity){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskActivityCommentLike){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    } else if (task == kTaskEditActivityComment){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    } else if (task == kTaskDeleteActivityComment){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskContactUs){
        //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }  else if (task == kTaskEventReportToAWM){
       // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [appSharedData removeLoadingView];
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskProviderInCircle)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
            
        }];
        
    }
    else if (task == kTaskAddProviderInTeam)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskBlockUserFromQA)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskGetFamilyList)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskAddFamilyMember)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:@""];
        }];
    }else if (task == kTaskEditFamilyMember)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskDeleteFamilyMember)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskGetMemberContact)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskInboxMemberList)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    
    else if (task == kTaskInboxSearchMember)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }

    
    else if (task == kTaskPostMessege)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskReportToAWMReportFamilyMember)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskEventAndCalendar)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }else if (task == kTaskGetMemberStory)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskDeleteConversation)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskGetMessageConversation)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskLogout)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            //[appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            //[appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskGetNotificationCount)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskGetNotificationList)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskDeleteNotification)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskUpdateProfilePicture)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskMessageDetailDelete)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }else if (task == kTaskPushApplicationDownload)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskGetMemberList)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskAddAlbum)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    
    else if (task == kTaskAlbumList)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    
    else if (task == kTaskPictureInAlbum)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskRenameAlbum)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskDeleteAlbum)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskEditCaption)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskDeletePicture)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskMakeAlbumCover)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }
    else if (task == kTaskRemoveAlbumCover)
    {
        [manager POST:urlString parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject, operation.error, task);
            [appSharedData removeLoadingView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            [appSharedData removeLoadingView];
            [appDelegate showSomeThingWentWrongAlert:[error localizedDescription]];
        }];
    }


    if ((task == kTaskGetNotificationCount) || (task == kTaskLogout) || (task == kTaskPushApplicationDownload) || (task == kTaskGetMemberList))
        return;
    
    [appSharedData showCustomLoaderWithTitle:message message:title];
}


@end

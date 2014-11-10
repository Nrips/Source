//
//  PostViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/26/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UploadingProgressView.h"
#import "MJAutoCompleteManager.h"
#import "UIPlaceHolderTextView.h"


@protocol PostViewControlleDelegate <NSObject>
- (void)postUpdatedSuccesfully;

@end

@interface PostViewController : UIViewController<MJAutoCompleteManagerDataSource, MJAutoCompleteManagerDelegate, UITextViewDelegate>

@property (nonatomic,weak) id <PostViewControlleDelegate>delegate;
@property (strong,nonatomic) NSString *strUrl;
@property (strong,nonatomic) NSString *callerView;
@property (strong,nonatomic) NSString *otherMemberId;
@property (nonatomic, strong) UploadingProgressView *postUpdateProgressView;
@property (nonatomic) BOOL isSelfActivityComment;
@property (strong, nonatomic) IBOutlet UITextView *txtViewPost;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *textView;
@end

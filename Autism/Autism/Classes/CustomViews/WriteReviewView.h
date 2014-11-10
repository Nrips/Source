//
//  WriteReviewView.h
//  Autism
//
//  Created by Dipak on 5/31/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@protocol WriteReviewViewDelegate <NSObject>

@optional
-(void)reviewSubmittedSuccessfully;
-(void)updateReview;

@end

@interface WriteReviewView : UIView <UITextViewDelegate>
@property (nonatomic,strong) id <WriteReviewViewDelegate>delegate;
@property(nonatomic, strong)NSString *serviceId;
@property(nonatomic, strong)NSString *serviceReviewId;
@property(nonatomic, strong)NSString *reviewType;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *writeReviewTextView;
@property(nonatomic, strong)IBOutlet UIButton* BtnPostData;
@property (weak, nonatomic) IBOutlet UIView *writeReviewView;
@property (nonatomic) long updateRating;
@property(nonatomic)NSInteger reviewRating;
@property(nonatomic, strong)NSString *parentViewController;
@end
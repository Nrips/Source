//
//  ReplyFooterView.h
//  Autism
//
//  Created by Dipak on 5/8/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "UIPlaceHolderTextView.h"
@protocol ReplyFooterViewDelegate <NSObject>

- (void)replySubmitButtonPressedAtRow :(long)row;

@end

@interface ReplyFooterView : UITableViewHeaderFooterView
@property (nonatomic,weak) id <ReplyFooterViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet MyImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *replyText;
@property (weak, nonatomic) IBOutlet UIButton *relpySubmitButton;
@property (strong, nonatomic)  NSString *questionID;
@property (strong, nonatomic) IBOutlet UIImageView *footerImageView;

@property (strong, nonatomic)  NSString *activityCommentId;

@property (nonatomic) CommentType commentType;

- (IBAction)replySubmitButtonPressed:(id)sender;
- (void)resetImage;
@end

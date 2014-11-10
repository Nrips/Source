//
//  CustomAttachLink.h
//  Autism
//
//  Created by Neuron-iPhone on 5/17/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttachLinkViewDelegate <NSObject>
- (void)attachedImageUrl:(NSString*)imageUrl withVisibleUrl:(NSString*)visibleUrl;

@end

@interface AttachLinkView : UIView
@property (nonatomic,weak) id <AttachLinkViewDelegate>delegate;

@end

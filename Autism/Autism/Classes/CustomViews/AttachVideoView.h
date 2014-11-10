//
//  AttachVideoView.h
//  Autism
//
//  Created by Dipak on 5/17/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttachVideoViewDelegate <NSObject>
- (void)attachedVideoUrl:(NSString*)videoUrl visibleUrl:(NSString*)visibleUrl;

@end

@interface AttachVideoView : UIView

@property (nonatomic, weak) id <AttachVideoViewDelegate>delegate;

@end

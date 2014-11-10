//
//  VideoPlayerViewController.h
//  Autism
//
//  Created by Dipak on 8/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerViewController : UIViewController

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *parentView;

-(void)playVideoWithId:(NSString *)videoId;

@end

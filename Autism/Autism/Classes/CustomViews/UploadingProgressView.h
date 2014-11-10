//
//  ProgressView.h
//  Autism
//
//  Created by Dipak on 6/21/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadingProgressView : UIView

@property (strong,nonatomic) NSString *callerView;

- (void)updateProgressBar:(float)progress;

@end

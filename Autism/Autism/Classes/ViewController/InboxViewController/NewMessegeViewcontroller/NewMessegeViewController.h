//
//  NewMessegeViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 6/4/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewMessageViewDelegate<NSObject>
- (void)didReloadInboxTable;
@end

@interface NewMessegeViewController : UIViewController

@property (nonatomic,weak) id<NewMessageViewDelegate>delegate;

@end

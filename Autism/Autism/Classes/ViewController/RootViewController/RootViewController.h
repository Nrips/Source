//
//  RootViewController.h
//  Autism
//
//  Created by Amit Jain on 24/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>
@protocol RootViewControllerDelegate <NSObject>
- (void)makeTextViewEmpty;
@end


@interface RootViewController : UIViewController

{
   BOOL buttonCurrentStatus;
}

@property (nonatomic,weak) id <RootViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIView *rootView;
@property (strong, nonatomic) UIWindow *window;

-(void)updateBadgeCount;


@end

//
//  AppSharedData.m
//  Autism
//
//  Created by Haider on 01/01/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import "AppSharedData.h"
#import "CustomLoadingView.h"

static AppSharedData *appSharedData_ = nil;

@interface AppSharedData()

@property (nonatomic, strong) CustomLoadingView *loadingView;

@end

@implementation AppSharedData
+ (AppSharedData*)sharedInstance{
    static dispatch_once_t predicate;
    if(appSharedData_ == nil){
        dispatch_once(&predicate,^{
            appSharedData_ = [[AppSharedData alloc] init];
            appSharedData_.imageCacheDictionary = [[NSMutableDictionary alloc]init];
        });
    }
    return appSharedData_;
}

- (void)showCustomLoaderWithTitle:(NSString*)title message:(NSString*)message{

    UIWindow *window = [appDelegate window];
    if(self.loadingView){
        [self removeLoadingView];
    }
    self.loadingView = [[CustomLoadingView alloc] initWithTitle:title message:message];
    [self.loadingView setCenter:window.center];
    [window addSubview:self.loadingView];
    [window setUserInteractionEnabled:NO];
    [self.loadingView startAnimating];
}

- (void)removeLoadingView{
    
    UIWindow *window = [appDelegate window];
    [self.loadingView removeFromSuperview];
    [self.loadingView.superview setUserInteractionEnabled:YES];
    [window setUserInteractionEnabled:YES];
    self.loadingView = nil;
}

@end

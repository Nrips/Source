//
//  OtherLocalAuthorityViewController.h
//  Autism
//
//  Created by Haider on 09/02/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OtherLocalDelegate <NSObject>

-(void)didSelectedLocalAuthority:(NSString *)localAuthority;

@end

@interface OtherLocalAuthorityViewController : UIViewController

@property (nonatomic, weak) id<OtherLocalDelegate> delegate;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *selectedTitle;
@end

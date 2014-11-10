//
//  QuestionKeywordViewController.h
//  Autism
//
//  Created by Vikrant Jain on 2/17/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol QuestionkeywordDelegate <NSObject>

-(void)didSelectedLocalAuthority:(NSString *)localAuthority;

@end


@interface QuestionKeywordViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>

@property (nonatomic, assign) id<QuestionkeywordDelegate> delegate;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *selectedTitle;

@end




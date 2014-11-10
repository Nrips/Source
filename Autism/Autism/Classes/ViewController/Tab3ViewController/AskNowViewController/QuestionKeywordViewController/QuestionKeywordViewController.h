//
//  QuestionKeywordViewController.h
//  Autism
//
//  Created by Vikrant Jain on 2/17/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuestionKeywordDelegate <NSObject>

-(void)didSelectKeyword:(NSMutableArray *)selectKeyword;
-(void)clickonDone;


@end


@interface QuestionKeywordViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) id<QuestionKeywordDelegate> delegate;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *selectedTitle;
@property (nonatomic, strong) NSString *selectedItem;

@end




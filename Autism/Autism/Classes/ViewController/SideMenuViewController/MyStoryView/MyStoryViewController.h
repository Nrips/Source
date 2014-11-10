//
//  MyStoryViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/11/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyStoryViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableStoryData;

@property (strong, nonatomic) NSMutableArray *arrData;
@property (strong, nonatomic) NSMutableArray *arrQuestion;

@property (strong, nonatomic) NSArray *arrID;
@property (strong, nonatomic) NSArray *arrQuestionID;

@property (strong, nonatomic) NSMutableArray *arrTextViewAnswers;


@property (strong, nonatomic) NSMutableDictionary *dict;




@end

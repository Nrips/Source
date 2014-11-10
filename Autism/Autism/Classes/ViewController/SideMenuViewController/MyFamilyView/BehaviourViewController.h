//
//  BehaviourViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 2/14/14.
//  Copyright (c) 2014 Haider. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BehaviourDelegate <NSObject>

-(void)didSelectedBehaviour:(NSMutableArray *)behaviour:(NSMutableArray *)selectionsIdBehav;
-(void)didSelectedTreatment:(NSMutableArray *)treatment:(NSMutableArray *)selectionsIdInterven;

@end

@interface BehaviourViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id<BehaviourDelegate>delegate;

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *selectedTitle;
@property (nonatomic, strong) NSString *selectedID;

@property(strong,nonatomic) NSArray *behaviourArray;


@property (nonatomic, strong) NSDictionary *dictionaryTreatment;
@property (nonatomic, strong) NSString *selectedTitleTreatment;



@property (nonatomic, assign) NSInteger passTreatId;
@property (nonatomic, assign) NSInteger passBehaveId;


@property (nonatomic, strong) NSMutableArray *arrValue;

@property (nonatomic, strong) NSString *behaviourTitle;
@property (nonatomic, strong) NSString *interventionTitle;




@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic,strong) NSArray *arraytreatment;

@end

//
//  CirclePeopleListViewController.h
//  Autism
//
//  Created by Neuron-iPhone on 6/6/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CirclePeopleListDelegate<NSObject>
- (void)didSelectContactNameAndId:(NSMutableArray*)memberId :(NSMutableArray *)name;
@end

@interface CirclePeopleListViewController : UIViewController
@property (nonatomic,strong) NSArray *memberIdArray;
@property (nonatomic,strong) NSArray *memberNameArray;

@property (nonatomic,weak) id<CirclePeopleListDelegate>delegate;
@end

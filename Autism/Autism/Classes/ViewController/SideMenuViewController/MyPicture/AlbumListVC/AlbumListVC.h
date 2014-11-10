//
//  AlbumListVC.h
//  Autism
//
//  Created by Neuron-iPhone on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumListVC : UICollectionViewController

@property (strong,nonatomic) NSString *albumId;
@property (strong,nonatomic) NSString *callerView;
@property (strong,nonatomic) NSString *profileType;


@property (nonatomic, strong) AppDelegate *appDel;

@end

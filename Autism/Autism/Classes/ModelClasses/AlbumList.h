//
//  AlbumList.h
//  Autism
//
//  Created by Neuron-iPhone on 9/1/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumList : NSObject

@property (nonatomic, strong) NSString *albumCover;
@property (nonatomic, strong) NSString *albumId;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *pictureCount;
@property (nonatomic)         BOOL     isDefaultAlbum;
@property (nonatomic)         BOOL     isSelfAlbum;

@end

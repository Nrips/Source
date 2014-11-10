//
//  PicturesInAlbum.h
//  Autism
//
//  Created by Neuron-iPhone on 9/1/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicturesInAlbum : NSObject

@property (nonatomic, strong) NSString *PictureId;
@property (nonatomic, strong) NSString *pictureUrl;
@property (nonatomic, strong) NSString *pictureCaption;
@property (nonatomic, strong) NSString *isCoverImage;
@property (nonatomic, strong) NSString *isSelfAlbumPicture;

@end

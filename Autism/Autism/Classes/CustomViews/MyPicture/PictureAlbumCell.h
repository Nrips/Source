//
//  PictureAlbumCell.h
//  Autism
//
//  Created by Neuron-iPhone on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "AlbumList.h"
#import "SWTableViewCell.h"

@interface PictureAlbumCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet MyImageView *imagAlbumcover;
@property (strong, nonatomic) IBOutlet UILabel     *lblAlbumTitle;
@property (strong, nonatomic) IBOutlet UILabel     *lblPictureInAlbumCount;
@property (strong, nonatomic) NSString             *albumId;
@property (strong, nonatomic) NSString             *albumName;

- (void)configureCell:(AlbumList *)album;
@end

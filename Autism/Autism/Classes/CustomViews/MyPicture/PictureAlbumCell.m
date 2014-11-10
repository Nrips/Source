//
//  PictureAlbumCell.m
//  Autism
//
//  Created by Neuron-iPhone on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "PictureAlbumCell.h"

@implementation PictureAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.imagAlbumcover.layer.borderWidth = 2.0f;
    self.imagAlbumcover.layer.borderColor = [UIColor purpleColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(AlbumList *)album
{
    [self.imagAlbumcover configureImageForUrl:album.albumCover];
    [self.lblAlbumTitle setText:album.albumName];
    [self.lblPictureInAlbumCount setText:album.pictureCount];
    self.albumId = album.albumId;
    self.albumName = album.albumName;
}

@end

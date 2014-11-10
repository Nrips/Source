//
//  PictureListCVCell.m
//  Autism
//
//  Created by Neuron-iPhone on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "PictureListCVCell.h"
#import "EXPhotoViewer.h"

@implementation PictureListCVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)configureCell:(PicturesInAlbum *)pictures
{
    //[self.imagPicture configureImageForUrlWithLoader:pictures.pictureUrl];
    [self.imagPicture configureImageForUrl:pictures.pictureUrl];
    
    [self.lblCaption setText:pictures.pictureCaption];
    
    self.pictureCaption = pictures.pictureCaption;
    self.pictureId      = pictures.PictureId;
    self.isAlbumCover   = pictures.isCoverImage;
    self.isSelfAlbumPicture = pictures.isSelfAlbumPicture;
}

- (IBAction)clickToLargeImage:(id)sender {
    [EXPhotoViewer showImageFrom:self.imagPicture];
}


@end

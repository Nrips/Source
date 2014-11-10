//
//  PictureListCVCell.h
//  Autism
//
//  Created by Neuron-iPhone on 8/28/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"
#import "PicturesInAlbum.h"

@interface PictureListCVCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet MyImageView *imagPicture;
@property (strong, nonatomic)  MyImageView *imag;
@property (strong, nonatomic) IBOutlet UILabel *lblCaption;

@property (strong, nonatomic) NSString *pictureId;
@property (strong, nonatomic) NSString *pictureCaption;
@property (strong, nonatomic) NSString *isAlbumCover;
@property (strong, nonatomic) NSString *isSelfAlbumPicture;


- (void)configureCell:(PicturesInAlbum *)pictures;
- (IBAction)clickToLargeImage:(id)sender;
@end

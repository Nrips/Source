//
//  PostUpdateUICollectionViewCell.h
//  Autism
//
//  Created by Dipak on 6/20/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"

@interface PostUpdateCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet MyImageView *selectedImageView;
@property (strong, nonatomic) IBOutlet UIButton *removePhotoLibraryPicButton;

@end

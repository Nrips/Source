//
//  PostUpdateUICollectionViewCell.m
//  Autism
//
//  Created by Dipak on 6/20/14.
//  Copyright (c) 2014 Neurons Solutions. All rights reserved.
//

#import "PostUpdateCollectionViewCell.h"
#import "EXPhotoViewer.h"

@interface PostUpdateCollectionViewCell()
- (IBAction)clickToLargeImage:(id)sender;
@end

@implementation PostUpdateCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self.selectedImageView.layer setBorderColor: [[UIColor colorWithRed:196/255.0f green:196/255.0f blue:196/255.0f alpha:1.0f] CGColor]];
    [self.selectedImageView.layer setBorderWidth: 2.0];
    self.selectedImageView.layer.cornerRadius = 4;
    self.selectedImageView.layer.masksToBounds = YES;
    self.selectedImageView.contentMode = UIViewContentModeScaleAspectFill;
}



- (IBAction)clickToLargeImage:(id)sender {
    [EXPhotoViewer showImageFrom:self.selectedImageView];
}

@end
